#!/usr/bin/env python3
"""Extract and composite reusable local anatomy patches.

Explicit raster assets belong under the git-ignored artifacts tree. This tool
contains no model integration and performs no generation; it turns approved
research renders or locally-authored images into reusable RGBA patches with
feather masks and provenance metadata.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageChops, ImageDraw, ImageFilter


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_bbox(value: str) -> tuple[float, float, float, float]:
    parts = tuple(float(part.strip()) for part in value.split(","))
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("bbox must be x0,y0,x1,y1")
    x0, y0, x1, y1 = parts
    if x0 < 0 or y0 < 0 or x1 <= x0 or y1 <= y0:
        raise argparse.ArgumentTypeError("bbox must have non-negative ordered coordinates")
    return parts


def pixel_bbox(
    bounds: tuple[float, float, float, float], width: int, height: int
) -> tuple[int, int, int, int]:
    if max(bounds) <= 1.0:
        x0, y0, x1, y1 = bounds
        result = (
            round(x0 * width),
            round(y0 * height),
            round(x1 * width),
            round(y1 * height),
        )
    else:
        result = tuple(round(value) for value in bounds)
    x0, y0, x1, y1 = result
    if not (0 <= x0 < x1 <= width and 0 <= y0 < y1 <= height):
        raise ValueError(f"bbox {result} falls outside {width}x{height} source")
    return result


def normalized_bbox(
    bounds: tuple[int, int, int, int], width: int, height: int
) -> list[float]:
    x0, y0, x1, y1 = bounds
    return [x0 / width, y0 / height, x1 / width, y1 / height]


def make_mask(width: int, height: int, shape: str, feather: float) -> Image.Image:
    if not 0.0 <= feather <= 0.25:
        raise ValueError("feather must be between 0 and 0.25")
    mask = Image.new("L", (width, height), 0)
    draw = ImageDraw.Draw(mask)
    inset = max(2, round(min(width, height) * max(feather, 0.01) * 1.5))
    box = (inset, inset, width - 1 - inset, height - 1 - inset)
    if shape == "ellipse":
        draw.ellipse(box, fill=255)
    else:
        radius = max(2, round(min(width, height) * 0.18))
        draw.rounded_rectangle(box, radius=radius, fill=255)
    radius = max(0.0, min(width, height) * feather)
    return mask.filter(ImageFilter.GaussianBlur(radius=radius)) if radius else mask


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def extract(args: argparse.Namespace) -> None:
    source_path = args.input.resolve(strict=True)
    source = Image.open(source_path).convert("RGBA")
    bounds = pixel_bbox(args.bbox, source.width, source.height)
    patch = source.crop(bounds)
    feather_mask = make_mask(patch.width, patch.height, args.shape, args.feather)
    source_alpha = patch.getchannel("A")
    alpha = ImageChops.multiply(source_alpha, feather_mask)
    patch.putalpha(alpha)

    args.output_rgba.parent.mkdir(parents=True, exist_ok=True)
    args.output_mask.parent.mkdir(parents=True, exist_ok=True)
    patch.save(args.output_rgba)
    alpha.save(args.output_mask)

    payload = {
        "$schema": args.schema,
        "asset_id": args.asset_id,
        "revision": args.revision,
        "module_kind": args.module_kind,
        "presentation": args.presentation,
        "anatomy_family": args.anatomy_family,
        "body_plans": args.body_plan,
        "size": args.size,
        "view": args.view,
        "deformation": args.deformation,
        "surface_families": args.surface,
        "anchors": {"root": [0.5, 0.5]},
        "normalized_bounds": normalized_bbox(bounds, source.width, source.height),
        "files": {
            "rgba": str(args.output_rgba.resolve()),
            "mask": str(args.output_mask.resolve()),
        },
        "provenance": {
            "method": "approved-source crop with deterministic feather mask",
            "created_at": datetime.now(timezone.utc).isoformat(),
            "source_asset_ids": args.source_asset_id,
            "provider_task_ids": args.provider_task_id,
            "source_path": str(source_path),
            "source_sha256": sha256_file(source_path),
            "notes": args.notes,
        },
    }
    write_json(args.metadata, payload)
    print(json.dumps({"event": "extracted", "asset_id": args.asset_id, "bounds": bounds}))


def composite(args: argparse.Namespace) -> None:
    target = Image.open(args.target.resolve(strict=True)).convert("RGBA")
    patch = Image.open(args.patch.resolve(strict=True)).convert("RGBA")
    bounds = pixel_bbox(args.bbox, target.width, target.height)
    x0, y0, x1, y1 = bounds
    patch = patch.resize((x1 - x0, y1 - y0), Image.Resampling.LANCZOS)
    if args.opacity < 1.0:
        alpha = patch.getchannel("A").point(lambda value: round(value * args.opacity))
        patch.putalpha(alpha)
    layer = Image.new("RGBA", target.size, (0, 0, 0, 0))
    layer.alpha_composite(patch, dest=(x0, y0))
    result = Image.alpha_composite(target, layer)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    result.save(args.output)
    print(json.dumps({"event": "composited", "output": str(args.output.resolve()), "bounds": bounds}))


def add_common_patch_tags(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--asset-id", required=True)
    parser.add_argument("--revision", type=int, default=1)
    parser.add_argument(
        "--module-kind",
        required=True,
        choices=("chest_form", "chest_detail", "pelvis_form", "pelvis_detail"),
    )
    parser.add_argument("--presentation", choices=("sfw", "explicit"), required=True)
    parser.add_argument(
        "--anatomy-family",
        required=True,
        choices=("neutral", "breasts", "vulva", "penis_testes", "cloacal", "species_specific"),
    )
    parser.add_argument("--body-plan", action="append", required=True)
    parser.add_argument("--size", choices=("small", "regular", "large"), required=True)
    parser.add_argument(
        "--view",
        choices=("front", "three_quarter_left", "three_quarter_right", "side_left", "side_right", "rear"),
        required=True,
    )
    parser.add_argument("--deformation", choices=("neutral", "compressed", "stretched", "active"), default="neutral")
    parser.add_argument("--surface", action="append", required=True)
    parser.add_argument("--source-asset-id", action="append", default=[])
    parser.add_argument("--provider-task-id", action="append", default=[])
    parser.add_argument("--notes", default="")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    extract_parser = subparsers.add_parser("extract", help="Extract a feathered RGBA patch and metadata")
    extract_parser.add_argument("--input", type=Path, required=True)
    extract_parser.add_argument("--bbox", type=parse_bbox, required=True)
    extract_parser.add_argument("--shape", choices=("ellipse", "rounded_rect"), default="ellipse")
    extract_parser.add_argument("--feather", type=float, default=0.06)
    extract_parser.add_argument("--output-rgba", type=Path, required=True)
    extract_parser.add_argument("--output-mask", type=Path, required=True)
    extract_parser.add_argument("--metadata", type=Path, required=True)
    extract_parser.add_argument("--schema", default="../../../schemas/anatomy_patch.schema.json")
    add_common_patch_tags(extract_parser)
    extract_parser.set_defaults(run=extract)

    composite_parser = subparsers.add_parser("composite", help="Resize and alpha-composite a patch into a target bbox")
    composite_parser.add_argument("--target", type=Path, required=True)
    composite_parser.add_argument("--patch", type=Path, required=True)
    composite_parser.add_argument("--bbox", type=parse_bbox, required=True)
    composite_parser.add_argument("--opacity", type=float, default=1.0)
    composite_parser.add_argument("--output", type=Path, required=True)
    composite_parser.set_defaults(run=composite)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    args.run(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
