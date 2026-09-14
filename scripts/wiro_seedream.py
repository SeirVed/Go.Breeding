#!/usr/bin/env python3
"""Run a Wiro Seedream image-to-image task without exposing credentials.

The supported model slugs are deliberately restricted to the three Seedream
variants used by the Go.Breeding art-pipeline comparison. Credentials are
loaded through the same environment/file convention as wiro_seedance.py.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import mimetypes
from pathlib import Path
import re
import sys
import time
from typing import Any

import requests

from wiro_seedance import API_BASE, auth_headers, checked_json, collect_urls, load_credentials


MODELS = (
    "seedream-v4-5-uncensored",
    "seedream-v5-lite-uncensored",
    "seedream-v5-pro-uncensored",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", choices=MODELS, required=True)
    parser.add_argument("--input", type=Path, required=True, action="append")
    prompt_group = parser.add_mutually_exclusive_group(required=True)
    prompt_group.add_argument("--prompt")
    prompt_group.add_argument("--prompt-file", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--receipt", type=Path)
    parser.add_argument("--resolution", choices=("auto", "1k", "2k", "3k"), default="2k")
    parser.add_argument(
        "--aspect-ratio",
        choices=("auto", "1:1", "2:3", "3:2", "3:4", "4:3", "16:9", "9:16", "21:9"),
        default="auto",
    )
    parser.add_argument("--output-format", choices=("png", "jpeg"), default="png")
    parser.add_argument("--watermark", action="store_true")
    parser.add_argument(
        "--credential-file",
        type=Path,
        default=Path.home() / ".codex" / "secrets" / "wiro-go-breeding.txt",
    )
    parser.add_argument("--poll-seconds", type=float, default=8.0)
    parser.add_argument("--timeout-seconds", type=float, default=900.0)
    parser.add_argument("--task-id", help="Resume an already-submitted task ID")
    parser.add_argument("--task-token", help="Resume an already-submitted task token")
    return parser.parse_args()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_receipt(
    *,
    args: argparse.Namespace,
    inputs: list[Path],
    task_id: str | None,
    task: dict[str, Any],
    source_url: str,
    output_path: Path,
    content_type: str,
) -> dict[str, Any]:
    return {
        "model": f"bytedance/{args.model}",
        "taskid": task_id,
        "status": task.get("status"),
        "pexit": task.get("pexit"),
        "totalcost": task.get("totalcost"),
        "prompt": args.prompt,
        "prompt_sha256": hashlib.sha256(args.prompt.encode("utf-8")).hexdigest(),
        "inputs": [
            {"path": str(path), "sha256": sha256_file(path)}
            for path in inputs
        ],
        "settings": {
            "resolution": args.resolution,
            "aspectRatio": args.aspect_ratio,
            "outputFormat": args.output_format,
            "watermark": args.watermark,
            "maxImages": 1,
        },
        "output": str(output_path.resolve()),
        "content_type": content_type,
        "source_url": source_url,
    }


def main() -> int:
    args = parse_args()
    if args.prompt_file:
        args.prompt = args.prompt_file.read_text(encoding="utf-8-sig").strip()
    api_key, api_secret = load_credentials(args.credential_file)
    inputs = [path.resolve(strict=True) for path in args.input]
    if len(inputs) > (10 if args.model == "seedream-v5-pro-uncensored" else 14):
        raise ValueError("Too many input images for the selected Seedream model")
    if args.model == "seedream-v5-pro-uncensored" and args.resolution == "3k":
        raise ValueError("Seedream V5 Pro supports 1k or 2k, not 3k")
    if args.model != "seedream-v5-pro-uncensored" and args.resolution == "1k":
        raise ValueError("Seedream V4.5 and V5 Lite support auto, 2k or 3k")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    task_token = args.task_token
    task_id = args.task_id

    if task_token or task_id:
        print(json.dumps({"event": "resumed", "model": args.model, "taskid": task_id}), flush=True)
    else:
        fields = {
            "prompt": args.prompt,
            "resolution": args.resolution,
            "aspectRatio": args.aspect_ratio,
            "maxImages": "1",
            "watermark": str(args.watermark).lower(),
        }
        if args.model == "seedream-v5-pro-uncensored":
            fields["outputFormat"] = args.output_format

        handles = []
        try:
            files = []
            for path in inputs:
                handle = path.open("rb")
                handles.append(handle)
                mime = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
                files.append(("inputImage", (path.name, handle, mime)))
            response = requests.post(
                f"{API_BASE}/Run/bytedance/{args.model}",
                headers=auth_headers(api_key, api_secret),
                data=fields,
                files=files,
                timeout=180,
            )
            run = checked_json(response)
        finally:
            for handle in handles:
                handle.close()

        task_token = run.get("socketaccesstoken") or run.get("tasktoken")
        task_id = run.get("taskid")
        if not task_token and not task_id:
            raise RuntimeError("Wiro accepted the request but returned no task token or task ID")
        print(json.dumps({"event": "submitted", "model": args.model, "taskid": task_id}), flush=True)

    deadline = time.monotonic() + args.timeout_seconds
    last_status = None
    task: dict[str, Any] = {}
    urls: list[str] = []
    while time.monotonic() < deadline:
        lookup = {"tasktoken": task_token} if task_token else {"taskid": task_id}
        response = requests.post(
            f"{API_BASE}/Task/Detail",
            headers={**auth_headers(api_key, api_secret), "Content-Type": "application/json"},
            json=lookup,
            timeout=60,
        )
        detail = checked_json(response)
        tasklist = detail.get("tasklist") or []
        if not tasklist:
            raise RuntimeError("Wiro Task Detail returned no matching task")
        task = tasklist[0]
        status = str(task.get("status") or task.get("taskstatus") or "unknown")
        pexit = task.get("pexit")
        if status != last_status:
            print(
                json.dumps({"event": "status", "model": args.model, "status": status, "pexit": pexit}),
                flush=True,
            )
            last_status = status
        urls = collect_urls(task.get("outputs"))
        if str(pexit) == "0" and urls:
            break
        if pexit not in (None, "", "0", 0):
            raise RuntimeError(
                f"Seedream task failed with pexit={pexit}: "
                f"{task.get('debugoutput') or task.get('debugerror')}"
            )
        if status == "task_cancel":
            raise RuntimeError("Seedream task was cancelled")
        time.sleep(args.poll_seconds)
    else:
        raise TimeoutError(f"Seedream task did not finish within {args.timeout_seconds:g} seconds")

    image_urls = [url for url in urls if re.search(r"\.(?:png|jpe?g|webp)(?:\?|$)", url, re.I)]
    source_url = image_urls[0] if image_urls else urls[0]
    download = requests.get(source_url, timeout=180)
    download.raise_for_status()
    content_type = download.headers.get("Content-Type", "").split(";", 1)[0].lower()
    extension_by_type = {
        "image/jpeg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
    }
    output_path = args.output
    actual_extension = extension_by_type.get(content_type)
    if actual_extension and output_path.suffix.lower() not in (
        {".jpg", ".jpeg"} if actual_extension == ".jpg" else {actual_extension}
    ):
        output_path = output_path.with_suffix(actual_extension)
        print(
            json.dumps(
                {
                    "event": "output_extension_adjusted",
                    "model": args.model,
                    "content_type": content_type,
                    "output": str(output_path.resolve()),
                }
            ),
            flush=True,
        )
    output_path.write_bytes(download.content)

    receipt = safe_receipt(
        args=args,
        inputs=inputs,
        task_id=task_id,
        task=task,
        source_url=source_url,
        output_path=output_path,
        content_type=content_type,
    )
    if args.receipt:
        args.receipt.parent.mkdir(parents=True, exist_ok=True)
        args.receipt.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(
        json.dumps(
            {
                "event": "downloaded",
                "model": args.model,
                "taskid": task_id,
                "output": str(output_path.resolve()),
                "bytes": len(download.content),
                "pexit": task.get("pexit"),
                "totalcost": task.get("totalcost"),
            }
        ),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1)
