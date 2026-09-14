#!/usr/bin/env python3
"""Composite a Seedream anatomy underlay into a clothed GPT-image master.

The source remains authoritative everywhere except the detected garment area.
This first preset intentionally targets the rust wrap top and indigo shorts in
the bovine cow study. It also writes the feathered mask for visual QA.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import cv2
import numpy as np


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--donor", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--mask-output", type=Path, required=True)
    parser.add_argument("--preset", choices=("cow", "insectkin", "dragon"), default="cow")
    parser.add_argument("--feather", type=int, default=25)
    parser.add_argument("--expand", type=int, default=23)
    return parser.parse_args()


def require_image(path: Path) -> np.ndarray:
    image = cv2.imread(str(path.resolve(strict=True)), cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError(f"Could not decode image: {path}")
    return image


def roi_mask(shape: tuple[int, int], x0: float, y0: float, x1: float, y1: float) -> np.ndarray:
    height, width = shape
    mask = np.zeros((height, width), dtype=np.uint8)
    mask[round(height * y0):round(height * y1), round(width * x0):round(width * x1)] = 255
    return mask


def filled_hull(selection: np.ndarray, minimum_pixels: int = 500) -> np.ndarray:
    points_yx = np.argwhere(selection > 0)
    result = np.zeros_like(selection)
    if len(points_yx) < minimum_pixels:
        return result
    points_xy = points_yx[:, [1, 0]].astype(np.int32)
    hull = cv2.convexHull(points_xy)
    cv2.fillConvexPoly(result, hull, 255)
    return result


def polygon_mask(shape: tuple[int, int], points: list[tuple[float, float]]) -> np.ndarray:
    height, width = shape
    scaled = np.array(
        [[round(x * width), round(y * height)] for x, y in points],
        dtype=np.int32,
    )
    result = np.zeros((height, width), dtype=np.uint8)
    cv2.fillPoly(result, [scaled], 255)
    return result


def finish_mask(mask: np.ndarray, expand: int, feather: int) -> np.ndarray:
    expand = max(1, expand)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (expand * 2 + 1, expand * 2 + 1))
    mask = cv2.dilate(mask, kernel, iterations=1)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

    feather = max(1, feather)
    if feather % 2 == 0:
        feather += 1
    return cv2.GaussianBlur(mask, (feather, feather), 0)


def cow_clothing_mask(source: np.ndarray, expand: int, feather: int) -> np.ndarray:
    height, width = source.shape[:2]
    hsv = cv2.cvtColor(source, cv2.COLOR_BGR2HSV)
    hue, saturation, value = cv2.split(hsv)

    top_roi = roi_mask((height, width), 0.16, 0.18, 0.76, 0.47)
    shorts_roi = roi_mask((height, width), 0.13, 0.41, 0.82, 0.64)

    rust = (((hue <= 14) | (hue >= 173)) & (saturation >= 75) & (value >= 55)).astype(np.uint8) * 255
    indigo = ((hue >= 92) & (hue <= 125) & (saturation >= 40) & (value >= 35)).astype(np.uint8) * 255

    top = filled_hull(cv2.bitwise_and(rust, top_roi))
    shorts = filled_hull(cv2.bitwise_and(indigo, shorts_roi))
    garment = cv2.bitwise_or(top, shorts)
    if not np.any(top):
        raise RuntimeError("Rust wrap-top detection produced an empty mask")
    if not np.any(shorts):
        raise RuntimeError("Indigo shorts detection produced an empty mask")

    return finish_mask(garment, expand, feather)


def insectkin_clothing_mask(shape: tuple[int, int], expand: int, feather: int) -> np.ndarray:
    garment = polygon_mask(
        shape,
        [
            (0.420, 0.282),
            (0.600, 0.286),
            (0.652, 0.390),
            (0.646, 0.500),
            (0.565, 0.588),
            (0.472, 0.596),
            (0.382, 0.548),
            (0.358, 0.420),
            (0.398, 0.312),
        ],
    )
    return finish_mask(garment, expand, feather)


def dragon_clothing_mask(shape: tuple[int, int], expand: int, feather: int) -> np.ndarray:
    upper = polygon_mask(
        shape,
        [
            (0.350, 0.155),
            (0.635, 0.158),
            (0.775, 0.235),
            (0.728, 0.405),
            (0.660, 0.455),
            (0.345, 0.455),
            (0.270, 0.425),
            (0.180, 0.335),
            (0.205, 0.235),
        ],
    )
    lower = polygon_mask(
        shape,
        [
            (0.300, 0.395),
            (0.700, 0.395),
            (0.750, 0.580),
            (0.700, 0.870),
            (0.545, 0.870),
            (0.500, 0.590),
            (0.440, 0.870),
            (0.220, 0.870),
            (0.230, 0.580),
        ],
    )
    return finish_mask(cv2.bitwise_or(upper, lower), expand, feather)


def main() -> int:
    args = parse_args()
    source = require_image(args.source)
    donor = require_image(args.donor)
    height, width = donor.shape[:2]
    source = cv2.resize(source, (width, height), interpolation=cv2.INTER_LANCZOS4)
    if args.preset == "cow":
        mask = cow_clothing_mask(source, args.expand, args.feather)
    elif args.preset == "insectkin":
        mask = insectkin_clothing_mask(source.shape[:2], args.expand, args.feather)
    else:
        mask = dragon_clothing_mask(source.shape[:2], args.expand, args.feather)

    alpha = mask.astype(np.float32)[:, :, None] / 255.0
    composite = np.clip(donor.astype(np.float32) * alpha + source.astype(np.float32) * (1.0 - alpha), 0, 255)
    composite = composite.astype(np.uint8)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.mask_output.parent.mkdir(parents=True, exist_ok=True)
    if not cv2.imwrite(str(args.output), composite):
        raise RuntimeError(f"Could not write composite: {args.output}")
    if not cv2.imwrite(str(args.mask_output), mask):
        raise RuntimeError(f"Could not write mask: {args.mask_output}")
    print(f"wrote {args.output.resolve()}")
    print(f"wrote {args.mask_output.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
