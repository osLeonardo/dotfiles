#!/usr/bin/env python3
"""Blurred, darkened copy of a wallpaper for the vscode-background extension.

Mimics what GNOME Terminal shows: the Blur My Shell default pipeline (radius 25,
brightness 0.5) behind the Atom profile with 25% background transparency.

vscode-background draws the image over the whole UI with `mix-blend-mode: screen`
(dark themes), which only lightens. Over a base color `a`, a pixel `x` at opacity `o`
becomes `a + o * x * (1 - a/255)`, while the terminal shows `0.75 * bg + t * blur`.
The image is scaled so both add the same amount of wallpaper on top of the base.

Usage: make-background.py <wallpaper> [output] [--opacity 0.6] [--base 26]
"""
import argparse
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

parser = argparse.ArgumentParser()
parser.add_argument("wallpaper", type=Path)
parser.add_argument("output", type=Path, nargs="?", default=Path(__file__).with_name("background.jpg"))
parser.add_argument("--radius", type=float, default=25, help="Blur My Shell pipeline radius")
parser.add_argument("--brightness", type=float, default=0.5, help="Blur My Shell pipeline brightness")
parser.add_argument("--terminal-transparency", type=float, default=0.25, help="GNOME Terminal profile background transparency")
parser.add_argument("--opacity", type=float, default=0.6, help="background.fullscreen.opacity in VS Code")
parser.add_argument("--base", type=int, default=0x1A, help="gray level of the VS Code theme base (editor.background)")
parser.add_argument("--width", type=int, default=1920, help="screen width, so the blur radius matches screen pixels")
args = parser.parse_args()

screen_gain = args.opacity * (1 - args.base / 255)
brightness = args.brightness * args.terminal_transparency / screen_gain

image = Image.open(args.wallpaper).convert("RGB")
height = round(image.height * args.width / image.width)
image = image.resize((args.width, height), Image.LANCZOS)
image = image.filter(ImageFilter.GaussianBlur(args.radius))
image = ImageEnhance.Brightness(image).enhance(brightness)
image.save(args.output, quality=92)
print(f"{args.output} ({image.width}x{image.height}, brightness {brightness:.3f})")
