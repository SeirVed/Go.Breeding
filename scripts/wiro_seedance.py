#!/usr/bin/env python3
"""Submit and download a Wiro Seedance job without exposing credentials.

Credentials are read from WIRO_API_KEY/WIRO_API_SECRET or from a protected
four-line file containing labels followed by their values, for example:

    Key
    <api key>
    Secret
    <api secret>
"""

from __future__ import annotations

import argparse
import hashlib
import hmac
import json
import mimetypes
import os
from pathlib import Path
import re
import sys
import time
from typing import Any

import requests


API_BASE = "https://api.wiro.ai/v1"
DEFAULT_CREDENTIAL_FILE = Path.home() / ".codex" / "secrets" / "wiro-go-breeding.txt"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, help="First-frame image")
    parser.add_argument("--last-input", type=Path, help="Optional last-frame image")
    parser.add_argument(
        "--reference",
        type=Path,
        action="append",
        help="Ordered reference image (repeat 1-30 times; cannot be combined with first/last frame)",
    )
    prompt_group = parser.add_mutually_exclusive_group()
    prompt_group.add_argument("--prompt")
    prompt_group.add_argument("--prompt-file", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--receipt", type=Path)
    parser.add_argument("--duration", choices=tuple(str(i) for i in range(4, 31)), default="4")
    parser.add_argument("--resolution", choices=("480p", "720p"), default="480p")
    parser.add_argument(
        "--ratio",
        choices=("adaptive", "16:9", "4:3", "1:1", "3:4", "9:16", "21:9"),
        default="16:9",
    )
    parser.add_argument("--audio", action="store_true")
    parser.add_argument("--watermark", action="store_true")
    parser.add_argument("--prompt-enhancement", action="store_true")
    parser.add_argument("--credential-file", type=Path, default=DEFAULT_CREDENTIAL_FILE)
    parser.add_argument("--poll-seconds", type=float, default=10.0)
    parser.add_argument("--timeout-seconds", type=float, default=900.0)
    parser.add_argument("--task-id", help="Resume polling an already-submitted task ID")
    parser.add_argument("--task-token", help="Resume polling an already-submitted task token")
    parser.add_argument("--list-recent", type=int, metavar="N", help="List recent Seedance task summaries")
    return parser.parse_args()


def credentials_from_file(path: Path) -> tuple[str, str]:
    lines = [line.strip() for line in path.read_text(encoding="utf-8-sig").splitlines() if line.strip()]
    labelled: dict[str, str] = {}
    for index, line in enumerate(lines[:-1]):
        label = re.sub(r"[^a-z]", "", line.lower())
        if label in {"key", "apikey", "wiroapikey"}:
            labelled["key"] = lines[index + 1]
        elif label in {"secret", "apisecret", "wiroapisecret"}:
            labelled["secret"] = lines[index + 1]
    if labelled.get("key") and labelled.get("secret"):
        return labelled["key"], labelled["secret"]

    values = [line.split("=", 1)[-1].split(":", 1)[-1].strip() for line in lines]
    likely_key = next((value for value in values if len(value) == 32), "")
    likely_secret = next((value for value in values if len(value) == 64), "")
    if not likely_key or not likely_secret:
        raise ValueError(f"Could not identify Wiro key and secret in {path}")
    return likely_key, likely_secret


def load_credentials(path: Path) -> tuple[str, str]:
    api_key = os.environ.get("WIRO_API_KEY", "").strip()
    api_secret = os.environ.get("WIRO_API_SECRET", "").strip()
    if api_key and api_secret:
        return api_key, api_secret
    return credentials_from_file(path)


def auth_headers(api_key: str, api_secret: str) -> dict[str, str]:
    nonce = str(time.time_ns())
    message = f"{api_secret}{nonce}".encode("utf-8")
    signature = hmac.new(api_key.encode("utf-8"), message, hashlib.sha256).hexdigest()
    return {
        "x-api-key": api_key,
        "x-nonce": nonce,
        "x-signature": signature,
    }


def checked_json(response: requests.Response) -> dict[str, Any]:
    try:
        payload = response.json()
    except ValueError as exc:
        raise RuntimeError(f"Wiro returned HTTP {response.status_code} with non-JSON content") from exc
    if not response.ok or payload.get("result") is False:
        errors = payload.get("errors") or payload.get("error") or payload
        raise RuntimeError(f"Wiro request failed (HTTP {response.status_code}): {errors}")
    return payload


def collect_urls(value: Any) -> list[str]:
    urls: list[str] = []
    if isinstance(value, str):
        if value.startswith(("https://", "http://")):
            urls.append(value)
    elif isinstance(value, list):
        for item in value:
            urls.extend(collect_urls(item))
    elif isinstance(value, dict):
        for item in value.values():
            urls.extend(collect_urls(item))
    return urls


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def download_with_retry(url: str, *, timeout_seconds: float = 180.0) -> requests.Response:
    """Download a completed task output while Wiro's file edge catches up.

    Task Detail can report a successful output several seconds before the file
    endpoint stops returning 404. Retrying the same URL preserves the paid task
    instead of accidentally submitting a duplicate generation.
    """
    deadline = time.monotonic() + timeout_seconds
    last_status: int | None = None
    while time.monotonic() < deadline:
        response = requests.get(url, timeout=60)
        last_status = response.status_code
        if response.ok:
            return response
        if response.status_code not in {404, 408, 425, 429, 500, 502, 503, 504}:
            response.raise_for_status()
        time.sleep(5.0)
    raise TimeoutError(
        f"Wiro output file was not downloadable within {timeout_seconds:g} seconds "
        f"(last HTTP status {last_status})"
    )


def main() -> int:
    args = parse_args()
    if args.prompt_file:
        args.prompt = args.prompt_file.read_text(encoding="utf-8-sig").strip()
    api_key, api_secret = load_credentials(args.credential_file)
    references = [path.resolve(strict=True) for path in (args.reference or [])]
    if len(references) > 30:
        raise ValueError("Seedance supports at most 30 reference images")
    if references and (args.input or args.last_input):
        raise ValueError("Reference images replace first/last-frame guidance; choose one mode")
    if args.last_input and not args.input:
        raise ValueError("--last-input requires --input")
    if args.list_recent:
        response = requests.post(
            f"{API_BASE}/Task/List",
            headers={**auth_headers(api_key, api_secret), "Content-Type": "application/json"},
            json={"start": 0, "limit": max(1, min(args.list_recent, 100)), "model": "seedance-2-5"},
            timeout=60,
        )
        payload = checked_json(response)
        tasks = payload.get("tasklist") or []
        safe = [
            {
                "id": task.get("id"),
                "status": task.get("status"),
                "pexit": task.get("pexit"),
                "model": f"{task.get('modelslugowner')}/{task.get('modelslugproject')}",
                "starttime": task.get("starttime"),
                "endtime": task.get("endtime"),
                "totalcost": task.get("totalcost"),
            }
            for task in tasks
        ]
        print(json.dumps(safe, indent=2))
        return 0
    if not args.output:
        raise ValueError("--output is required unless --list-recent is used")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    task_token = args.task_token
    task_id = args.task_id

    if task_token or task_id:
        print(json.dumps({"event": "resumed", "taskid": task_id}), flush=True)
    else:
        if not args.prompt:
            raise ValueError("--prompt or --prompt-file is required when submitting a new task")
        first = args.input.resolve(strict=True) if args.input else None
        last = args.last_input.resolve(strict=True) if args.last_input else None
        fields = {
            "prompt": args.prompt,
            "resolution": args.resolution,
            "ratio": args.ratio,
            "duration": args.duration,
            "generateAudio": str(args.audio).lower(),
            "outputFormat": "mp4",
            "promptEnhancement": str(args.prompt_enhancement).lower(),
            "watermark": str(args.watermark).lower(),
        }

        handles = []
        try:
            files: list[tuple[str, tuple[str, Any, str]]] = []
            if first:
                first_handle = first.open("rb")
                handles.append(first_handle)
                first_mime = mimetypes.guess_type(first.name)[0] or "application/octet-stream"
                files.append(("inputImage", (first.name, first_handle, first_mime)))
            for reference in references:
                reference_handle = reference.open("rb")
                handles.append(reference_handle)
                reference_mime = mimetypes.guess_type(reference.name)[0] or "application/octet-stream"
                files.append(
                    ("inputImageReference", (reference.name, reference_handle, reference_mime))
                )
            if last:
                last_handle = last.open("rb")
                handles.append(last_handle)
                last_mime = mimetypes.guess_type(last.name)[0] or "application/octet-stream"
                files.append(("inputImageLast", (last.name, last_handle, last_mime)))
            run_response = requests.post(
                f"{API_BASE}/Run/bytedance/seedance-2-5",
                headers=auth_headers(api_key, api_secret),
                data=fields,
                files=files,
                timeout=120,
            )
            run = checked_json(run_response)
        finally:
            for handle in handles:
                handle.close()

        task_token = run.get("socketaccesstoken") or run.get("tasktoken")
        task_id = run.get("taskid")
        if not task_token and not task_id:
            raise RuntimeError("Wiro accepted the request but returned no task token or task ID")
        print(json.dumps({"event": "submitted", "taskid": task_id}), flush=True)

    deadline = time.monotonic() + args.timeout_seconds
    last_status = None
    detail: dict[str, Any] = {}
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
            print(json.dumps({"event": "status", "status": status, "pexit": pexit}), flush=True)
            last_status = status

        urls = collect_urls(task.get("outputs"))
        if str(pexit) == "0" and urls:
            break
        if pexit not in (None, "", "0", 0):
            raise RuntimeError(
                f"Seedance task failed with pexit={pexit}: {task.get('debugoutput') or task.get('debugerror')}"
            )
        time.sleep(args.poll_seconds)
    else:
        raise TimeoutError(f"Seedance task did not finish within {args.timeout_seconds:g} seconds")

    video_urls = [url for url in urls if re.search(r"\.(?:mp4|mov)(?:\?|$)", url, re.I)]
    source_url = video_urls[0] if video_urls else urls[0]
    download = download_with_retry(source_url)
    args.output.write_bytes(download.content)
    if args.receipt:
        source_inputs = []
        if args.input:
            first = args.input.resolve(strict=True)
            source_inputs.append({"role": "first", "path": str(first), "sha256": sha256_file(first)})
        if args.last_input:
            last = args.last_input.resolve(strict=True)
            source_inputs.append({"role": "last", "path": str(last), "sha256": sha256_file(last)})
        for index, reference in enumerate(references, start=1):
            source_inputs.append(
                {
                    "role": "reference",
                    "reference_index": index,
                    "prompt_label": f"[Image {index}]",
                    "path": str(reference),
                    "sha256": sha256_file(reference),
                }
            )
        receipt = {
            "model": "bytedance/seedance-2-5",
            "taskid": task_id,
            "status": task.get("status"),
            "pexit": task.get("pexit"),
            "totalcost": task.get("totalcost"),
            "prompt": args.prompt,
            "prompt_sha256": hashlib.sha256((args.prompt or "").encode("utf-8")).hexdigest(),
            "inputs": source_inputs,
            "settings": {
                "duration": args.duration,
                "resolution": args.resolution,
                "ratio": args.ratio,
                "generateAudio": args.audio,
                "watermark": args.watermark,
                "promptEnhancement": args.prompt_enhancement,
            },
            "output": str(args.output.resolve()),
            "source_url": source_url,
        }
        args.receipt.parent.mkdir(parents=True, exist_ok=True)
        args.receipt.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(
        json.dumps(
            {
                "event": "downloaded",
                "taskid": task_id,
                "output": str(args.output.resolve()),
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
    except Exception as exc:  # concise CLI failure; credentials are never interpolated
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1)
