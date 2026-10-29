#!/usr/bin/env python3

import argparse
import random
from pathlib import Path

try:
    from PIL import Image, ImageChops, ImageDraw, ImageFilter
except ImportError:
    raise SystemExit("Pillow is required to generate the wallpaper.")


PROJECT_DIR = Path(__file__).resolve().parent.parent
DEFAULT_OUTPUT = PROJECT_DIR / "assets/wallpaper.webp"
DEFAULT_SIZE = (2560, 1440)
RANDOM_SEED = 20261030


def mix_color(start, end, amount):
    return tuple(
        round(start[channel] + (end[channel] - start[channel]) * amount)
        for channel in range(3)
    )


def make_gradient(size):
    width, height = size
    top = (24, 19, 38)
    middle = (76, 58, 96)
    bottom = (34, 27, 51)
    image = Image.new("RGB", size)
    draw = ImageDraw.Draw(image)

    for y in range(height):
        position = y / max(1, height - 1)
        if position < 0.58:
            color = mix_color(top, middle, position / 0.58)
        else:
            color = mix_color(middle, bottom, (position - 0.58) / 0.42)
        draw.line((0, y, width, y), fill=color)

    return image


def add_soft_light(image):
    width, height = image.size
    glow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)

    draw.ellipse(
        (width * 0.47, -height * 0.34, width * 1.16, height * 0.76),
        fill=(224, 190, 216, 190),
    )
    draw.ellipse(
        (width * 0.30, height * 0.18, width * 0.92, height * 1.28),
        fill=(129, 119, 174, 150),
    )
    draw.ellipse(
        (-width * 0.18, height * 0.50, width * 0.46, height * 1.24),
        fill=(151, 92, 143, 115),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=width * 0.075))
    return Image.alpha_composite(image.convert("RGBA"), glow)


def add_geometry(image):
    width, height = image.size
    geometry = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(geometry)

    draw.polygon(
        [
            (width * 0.58, 0),
            (width * 0.88, 0),
            (width * 0.53, height),
            (width * 0.29, height),
        ],
        fill=(235, 214, 235, 20),
    )
    draw.polygon(
        [
            (width * 0.78, 0),
            (width * 0.93, 0),
            (width * 0.72, height),
            (width * 0.58, height),
        ],
        fill=(255, 246, 255, 12),
    )

    ring_box = (
        width * 0.70,
        -height * 0.48,
        width * 1.29,
        height * 0.79,
    )
    draw.ellipse(ring_box, outline=(255, 244, 255, 36), width=max(2, width // 960))
    inner_ring = tuple(value * 0.92 for value in ring_box)
    draw.ellipse(
        inner_ring,
        outline=(224, 199, 222, 24),
        width=max(2, width // 1280),
    )

    geometry = geometry.filter(ImageFilter.GaussianBlur(radius=width * 0.0025))
    return Image.alpha_composite(image, geometry)


def add_grain(image):
    width, height = image.size
    rng = random.Random(RANDOM_SEED)
    noise = Image.frombytes("L", image.size, rng.randbytes(width * height))
    noise = noise.point(lambda value: 118 + value * 20 // 255)
    grain = Image.merge("RGBA", (noise, noise, noise, Image.new("L", image.size, 10)))
    grained = Image.alpha_composite(image, grain)
    return ImageChops.blend(
        image.convert("RGB"),
        grained.convert("RGB"),
        0.08,
    ).convert("RGBA")


def generate(output, size):
    image = make_gradient(size)
    image = add_soft_light(image)
    image = add_geometry(image)
    image = add_grain(image).convert("RGB")
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, "WEBP", quality=92, method=6)


def main():
    parser = argparse.ArgumentParser(
        description="Generate Lily SDDM's project-owned wallpaper."
    )
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--width", type=int, default=DEFAULT_SIZE[0])
    parser.add_argument("--height", type=int, default=DEFAULT_SIZE[1])
    args = parser.parse_args()

    if args.width < 320 or args.height < 180:
        raise SystemExit("Wallpaper dimensions must be at least 320x180.")

    generate(args.output, (args.width, args.height))
    print(args.output)


if __name__ == "__main__":
    main()
