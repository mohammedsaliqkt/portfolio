#!/usr/bin/env python3
"""
Icon Generator for Mohammed Saliq KT Portfolio
This script generates custom favicon and app icons with the initials "MS"
"""

try:
    import os

    from PIL import Image, ImageDraw, ImageFont

    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("PIL (Pillow) is not installed. Installing...")
    import subprocess
    import sys

    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image, ImageDraw, ImageFont


def create_icon(
    size, output_path, text="KTMS", bg_color="#000000", text_color="#00E676"
):
    """Create a squircle icon with initials"""
    # Create image with transparent background first
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Create squircle shape (rounded square)
    corner_radius = size // 4  # 25% of size for nice rounded corners
    squircle_coords = [0, 0, size, size]
    draw.rounded_rectangle(squircle_coords, radius=corner_radius, fill=bg_color)

    # Try to use a nice font, fall back to default if not available
    try:
        # Try to find system fonts
        # Adjust font size for 4 characters instead of 2
        font_size = int(size * 0.25)  # 25% of icon size for 4 characters

        # Common font paths for different operating systems
        font_paths = [
            "/System/Library/Fonts/Arial.ttf",  # macOS
            "/System/Library/Fonts/Helvetica.ttc",  # macOS
            "C:/Windows/Fonts/arial.ttf",  # Windows
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",  # Linux
            "/usr/share/fonts/TTF/arial.ttf",  # Linux
        ]

        font = None
        for font_path in font_paths:
            if os.path.exists(font_path):
                font = ImageFont.truetype(font_path, font_size)
                break

        if font is None:
            font = ImageFont.load_default()

    except Exception:
        font = ImageFont.load_default()

    # Calculate text position for center alignment
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (size - text_width) // 2
    y = (size - text_height) // 2 - bbox[1]  # Adjust for font baseline

    # Add a subtle border to the squircle
    border_width = max(1, size // 48)  # Thinner border for squircle
    if border_width > 0:
        border_coords = [
            border_width,
            border_width,
            size - border_width,
            size - border_width,
        ]
        draw.rounded_rectangle(
            border_coords,
            radius=corner_radius - border_width,
            outline=text_color,
            width=border_width,
        )

    # Draw the text
    draw.text((x, y), text, fill=text_color, font=font)

    # Save with transparent background
    img.save(output_path, "PNG", optimize=True)
    print(f"Created: {output_path} ({size}x{size})")


def create_favicon(output_path, text="KTMS"):
    """Create a favicon.ico file with multiple sizes"""
    sizes = [16, 32, 48, 64]
    images = []

    for size in sizes:
        # Create squircle favicon
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        corner_radius = max(2, size // 6)  # Smaller radius for favicon
        squircle_coords = [0, 0, size, size]
        draw.rounded_rectangle(squircle_coords, radius=corner_radius, fill="#000000")

        # For small sizes, use a simpler design
        if size <= 32:
            # Smaller font for 4 characters
            font_size = max(6, size // 4)
            try:
                font = ImageFont.load_default()
            except:
                font = None

            if font:
                bbox = draw.textbbox((0, 0), text, font=font)
                text_width = bbox[2] - bbox[0]
                text_height = bbox[3] - bbox[1]
                x = (size - text_width) // 2
                y = (size - text_height) // 2 - bbox[1]
                draw.text((x, y), text, fill="#00E676", font=font)
            else:
                # Fallback: just a colored squircle
                inner_coords = [2, 2, size - 2, size - 2]
                draw.rounded_rectangle(
                    inner_coords, radius=corner_radius - 1, fill="#00E676"
                )
        else:
            # For larger sizes, use the full design
            create_icon(size, f"temp_{size}.png", text)
            temp_img = Image.open(f"temp_{size}.png")
            img = temp_img.convert("RGBA")
            os.remove(f"temp_{size}.png")

        # Convert to RGB for ICO compatibility but keep transparency info
        if img.mode == "RGBA":
            # Create white background for ICO (since ICO doesn't support transparency well)
            final_img = Image.new("RGB", (size, size), "#FFFFFF")
            final_img.paste(img, (0, 0), img)
            images.append(final_img)
        else:
            images.append(img)

    # Save as ICO file
    images[0].save(
        output_path, format="ICO", sizes=[(img.width, img.height) for img in images]
    )
    print(f"Created: {output_path}")


def create_svg_icon(output_path, text="KTMS", bg_color="#000000", text_color="#00E676"):
    """Create an SVG version of the icon for maximum clarity"""
    svg_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style>
      .squircle {{
        fill: {bg_color};
        stroke: {text_color};
        stroke-width: 2;
      }}
      .text {{
        fill: {text_color};
        font-family: Arial, Helvetica, sans-serif;
        font-size: 120px;
        font-weight: bold;
        text-anchor: middle;
        dominant-baseline: central;
      }}
    </style>
  </defs>
  
  <!-- Squircle background -->
  <rect x="0" y="0" width="512" height="512" rx="128" ry="128" class="squircle"/>
  
  <!-- Text -->
  <text x="256" y="256" class="text">{text}</text>
</svg>"""

    with open(output_path, "w") as f:
        f.write(svg_content)
    print(f"Created: {output_path} (SVG)")


def main():
    """Generate all required icons"""
    # Create web directory if it doesn't exist
    web_dir = "web"
    icons_dir = os.path.join(web_dir, "icons")

    if not os.path.exists(web_dir):
        os.makedirs(web_dir)
    if not os.path.exists(icons_dir):
        os.makedirs(icons_dir)

    print("Generating custom icons for Mohammed Saliq KT Portfolio...")
    print("=" * 50)

    # Generate favicon.png (32x32)
    create_icon(32, os.path.join(web_dir, "favicon.png"))

    # Generate app icons
    create_icon(192, os.path.join(icons_dir, "Icon-192.png"))
    create_icon(512, os.path.join(icons_dir, "Icon-512.png"))

    # Generate maskable icons (with padding for safe area)
    create_icon(192, os.path.join(icons_dir, "Icon-maskable-192.png"), text="KTMS")
    create_icon(512, os.path.join(icons_dir, "Icon-maskable-512.png"), text="KTMS")

    # Generate favicon.ico
    create_favicon(os.path.join(web_dir, "favicon.ico"))

    # Generate SVG icons for maximum clarity
    create_svg_icon(os.path.join(web_dir, "favicon.svg"))
    create_svg_icon(os.path.join(icons_dir, "Icon.svg"))

    print("=" * 50)
    print("✅ Icon generation complete!")
    print("\nGenerated files:")
    print("- web/favicon.png (32x32) - Transparent PNG")
    print("- web/favicon.ico (multi-size)")
    print("- web/favicon.svg (Vector - Best Quality)")
    print("- web/icons/Icon.svg (Vector - Best Quality)")
    print("- web/icons/Icon-192.png (Transparent PNG)")
    print("- web/icons/Icon-512.png (Transparent PNG)")
    print("- web/icons/Icon-maskable-192.png (Transparent PNG)")
    print("- web/icons/Icon-maskable-512.png (Transparent PNG)")
    print("\nTo apply changes:")
    print("1. Run 'flutter clean'")
    print("2. Run 'flutter build web'")
    print("3. Test in browser")


if __name__ == "__main__":
    main()
