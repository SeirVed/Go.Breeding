#!/usr/bin/env python3
"""Validate, rasterize and label the offline crash-dummy SVG catalog.

SVG masters and generated PNGs intentionally live under art/offline and are
excluded from Git, Godot imports and playable exports. This public tool and the
semantic catalog are the reproducible contract around those local media files.
"""

from __future__ import annotations

import argparse
import json
import math
import shutil
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = PROJECT_ROOT / "data" / "crash_dummy_part_catalog.json"
DEFAULT_SOURCE = PROJECT_ROOT / "art" / "offline" / "crash_dummy_v01" / "svg"
DEFAULT_OUTPUT = PROJECT_ROOT / "art" / "offline" / "crash_dummy_v01" / "generated"
VALID_FORMS = {"neutral", "masc", "femm"}
VALID_VIEWS = {"front", "back", "side", "three_quarter"}
REQUIRED_FIELDS = {"display_name", "family", "views", "mirrorable", "repeatable", "mount", "status"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--source-dir", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--scale", type=int, default=4)
    parser.add_argument("--validate-only", action="store_true")
    parser.add_argument("--require-initial", action="store_true", help="Fail when an initial_svg entry has no source SVG.")
    return parser.parse_args()


def expanded_id(part_id: str, form: str | None, view: str) -> str:
    tokens = [part_id]
    if form is not None:
        tokens.append(form)
    tokens.append(view)
    return "_".join(tokens)


def load_and_validate(path: Path) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    catalog = json.loads(path.read_text(encoding="utf-8"))
    errors: list[str] = []
    for field in ("schema_version", "forms", "views", "morph_contract", "foundations", "part_definitions"):
        if field not in catalog:
            errors.append(f"catalog missing {field}")
    if set(catalog.get("forms", [])) - VALID_FORMS:
        errors.append("catalog declares an unknown form")
    if set(catalog.get("views", [])) - VALID_VIEWS:
        errors.append("catalog declares an unknown view")

    definitions = catalog.get("part_definitions", {})
    expanded: list[dict[str, Any]] = []
    seen: set[str] = set()
    for part_id, definition in definitions.items():
        missing = REQUIRED_FIELDS - set(definition)
        if missing:
            errors.append(f"{part_id} missing {', '.join(sorted(missing))}")
            continue
        forms = definition.get("forms", [None])
        if forms != [None] and set(forms) - VALID_FORMS:
            errors.append(f"{part_id} declares an unknown form")
        views = definition.get("views", [])
        if not views or set(views) - VALID_VIEWS:
            errors.append(f"{part_id} declares an invalid view set")
        for form in forms:
            for view in views:
                entry_id = expanded_id(part_id, form, view)
                if entry_id in seen:
                    errors.append(f"duplicate expanded entry {entry_id}")
                    continue
                seen.add(entry_id)
                expanded.append(
                    {
                        "id": entry_id,
                        "part_id": part_id,
                        "display_name": definition["display_name"],
                        "family": definition["family"],
                        "form": form,
                        "view": view,
                        "mirrorable": definition["mirrorable"],
                        "repeatable": definition["repeatable"],
                        "mount": definition["mount"],
                        "status": definition["status"],
                        "replaces": definition.get("replaces", []),
                    }
                )

    for foundation_id, foundation in catalog.get("foundations", {}).items():
        for part_id in foundation.get("required_parts", []):
            if part_id not in definitions:
                errors.append(f"foundation {foundation_id} references unknown part {part_id}")
        for part_id in foundation.get("replaces", []):
            if part_id not in definitions:
                errors.append(f"foundation {foundation_id} replaces unknown part {part_id}")

    morph_contract = catalog.get("morph_contract", {})
    for channel_id, channel in morph_contract.get("channels", {}).items():
        value_range = channel.get("range", [])
        if len(value_range) != 2 or value_range[0] > value_range[1]:
            errors.append(f"morph channel {channel_id} declares an invalid range")
        elif not value_range[0] <= channel.get("default", 0) <= value_range[1]:
            errors.append(f"morph channel {channel_id} default is outside its range")
        for part_id in channel.get("target_parts", []):
            if part_id not in definitions:
                errors.append(f"morph channel {channel_id} references unknown part {part_id}")

    if errors:
        raise ValueError("\n".join(errors))
    expanded.sort(key=lambda item: (item["family"], item["part_id"], item["form"] or "", item["view"]))
    return catalog, expanded


def find_magick() -> str:
    executable = shutil.which("magick") or shutil.which("magick.exe")
    if executable is None:
        raise RuntimeError("ImageMagick 7 (magick) is required to rasterize SVG masters.")
    return executable


def rasterize_svg(magick: str, source: Path, destination: Path, scale: int) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    command = [
        magick,
        "-background",
        "none",
        "-density",
        str(96 * scale),
        str(source),
        "-colorspace",
        "sRGB",
        "-type",
        "TrueColorAlpha",
        "-strip",
        "-define",
        "png:exclude-chunks=date,time",
        "-define",
        "png:color-type=6",
        str(destination),
    ]
    subprocess.run(command, check=True, capture_output=True, text=True)


def load_font(size: int) -> ImageFont.ImageFont:
    candidates = [
        Path("C:/Windows/Fonts/consolab.ttf"),
        Path("C:/Windows/Fonts/consola.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


def fit_thumbnail(image: Image.Image, box: tuple[int, int]) -> Image.Image:
    result = image.copy()
    result.thumbnail(box, Image.Resampling.LANCZOS)
    return result


def render_labelled_family_pages(entries: list[dict[str, Any]], chunks: dict[str, Path], output_dir: Path) -> list[Path]:
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for entry in entries:
        grouped[entry["family"]].append(entry)

    cell_width, cell_height, columns = 360, 400, 4
    label_font = load_font(22)
    note_font = load_font(16)
    results: list[Path] = []
    labelled_dir = output_dir / "labelled"
    labelled_dir.mkdir(parents=True, exist_ok=True)
    for family, family_entries in sorted(grouped.items()):
        rows = math.ceil(len(family_entries) / columns)
        page = Image.new("RGBA", (cell_width * columns, cell_height * rows), (5, 7, 8, 255))
        draw = ImageDraw.Draw(page)
        for index, entry in enumerate(family_entries):
            column, row = index % columns, index // columns
            x, y = column * cell_width, row * cell_height
            border = (245, 245, 238, 255)
            draw.rectangle((x + 6, y + 6, x + cell_width - 6, y + cell_height - 6), outline=border, width=3)
            label_y = y + cell_height - 74
            draw.line((x + 6, label_y, x + cell_width - 6, label_y), fill=border, width=3)
            chunk_path = chunks.get(entry["id"])
            if chunk_path is not None:
                chunk = Image.open(chunk_path).convert("RGBA")
                thumb = fit_thumbnail(chunk, (cell_width - 44, cell_height - 112))
                page.alpha_composite(thumb, (x + (cell_width - thumb.width) // 2, y + 18 + (cell_height - 112 - thumb.height) // 2))
                state = "SVG READY"
                state_colour = (105, 229, 194, 255)
            else:
                state = "PLANNED · NO SVG" if entry["status"] != "initial_svg" else "INITIAL SVG MISSING"
                state_colour = (181, 172, 151, 255) if entry["status"] != "initial_svg" else (255, 168, 92, 255)
                draw.rectangle((x + 42, y + 62, x + cell_width - 42, label_y - 34), outline=state_colour, width=2)
                draw.line((x + 42, y + 62, x + cell_width - 42, label_y - 34), fill=state_colour, width=2)
                draw.line((x + cell_width - 42, y + 62, x + 42, label_y - 34), fill=state_colour, width=2)
            label = entry["id"].upper()
            draw.text((x + 18, label_y + 10), label, font=label_font, fill=(255, 255, 255, 255))
            draw.text((x + 18, label_y + 42), state, font=note_font, fill=state_colour)
        destination = labelled_dir / f"crash_dummy_{family}_labelled.png"
        page.save(destination, format="PNG", optimize=False)
        results.append(destination)
    return results


def pack_runtime_atlas(catalog: dict[str, Any], entries: list[dict[str, Any]], chunks: dict[str, Path], output_dir: Path) -> tuple[Path | None, Path]:
    metadata: dict[str, Any] = {
        "schema_version": 1,
        "morph_contract": catalog["morph_contract"],
        "entries": {},
    }
    ready: list[tuple[dict[str, Any], Image.Image]] = []
    for entry in entries:
        chunk_path = chunks.get(entry["id"])
        if chunk_path is None:
            metadata["entries"][entry["id"]] = {**entry, "art_state": "missing", "rect": None}
            continue
        image = Image.open(chunk_path).convert("RGBA")
        ready.append((entry, image))

    metadata_path = output_dir / "crash_dummy_runtime_atlas.json"
    if not ready:
        metadata_path.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
        return None, metadata_path

    max_width, padding = 4096, 12
    placements: list[tuple[dict[str, Any], Image.Image, int, int]] = []
    x = y = padding
    row_height = 0
    used_width = 0
    for entry, image in ready:
        if x + image.width + padding > max_width and x > padding:
            x = padding
            y += row_height + padding
            row_height = 0
        placements.append((entry, image, x, y))
        x += image.width + padding
        row_height = max(row_height, image.height)
        used_width = max(used_width, x)
    used_height = y + row_height + padding
    atlas = Image.new("RGBA", (max(1, used_width), max(1, used_height)), (0, 0, 0, 0))
    for entry, image, px, py in placements:
        atlas.alpha_composite(image, (px, py))
        metadata["entries"][entry["id"]] = {
            **entry,
            "art_state": "offline_svg",
            "rect": [px, py, image.width, image.height],
        }
    atlas_path = output_dir / "crash_dummy_runtime_atlas.png"
    atlas.save(atlas_path, format="PNG", optimize=False)
    metadata["atlas"] = {"file": atlas_path.name, "size": list(atlas.size), "padding": padding}
    metadata_path.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    return atlas_path, metadata_path


def main() -> int:
    args = parse_args()
    catalog, entries = load_and_validate(args.catalog.resolve())
    print(f"CRASH_DUMMY_CATALOG: {len(catalog['part_definitions'])} definitions · {len(entries)} expanded entries")
    if args.validate_only:
        return 0

    source_dir = args.source_dir.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    chunks_dir = output_dir / "chunks"
    chunks_dir.mkdir(parents=True, exist_ok=True)
    magick = find_magick()
    chunks: dict[str, Path] = {}
    missing_initial: list[str] = []
    for entry in entries:
        source = source_dir / f"{entry['id']}.svg"
        if not source.exists():
            if entry["status"] == "initial_svg":
                missing_initial.append(entry["id"])
            continue
        destination = chunks_dir / f"{entry['id']}.png"
        rasterize_svg(magick, source, destination, args.scale)
        chunks[entry["id"]] = destination

    pages = render_labelled_family_pages(entries, chunks, output_dir)
    atlas_path, metadata_path = pack_runtime_atlas(catalog, entries, chunks, output_dir)
    print(f"CRASH_DUMMY_ATLAS: {len(chunks)} SVGs · {len(entries) - len(chunks)} catalog-only · {len(pages)} labelled family pages")
    print(f"CRASH_DUMMY_METADATA: {metadata_path}")
    if atlas_path is not None:
        print(f"CRASH_DUMMY_RUNTIME_ATLAS: {atlas_path}")
    if missing_initial:
        print("CRASH_DUMMY_INITIAL_MISSING: " + ", ".join(missing_initial))
        if args.require_initial:
            return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
