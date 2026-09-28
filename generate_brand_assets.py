"""
Master Brand Asset Generator for Nova.
Produces pixel-perfect geometric vector assets matching the official brand identity:
- Folded Isometric Ribbon 'N' Mark (Cyan #06D6D4, Electric Blue #3B82F6, Violet #8B5CF6)
- Modern Geometric 'Nova' Wordmark
- Multi-resolution Android Launcher Icons (mipmap-mdpi..xxxhdpi)
- Next.js Favicons (favicon.ico, favicon.svg, apple-touch-icon.png, icon.png)
- Mobile and Web horizontal logos (onDark, onLight)
"""

import os
import subprocess
from PIL import Image

# 1. Master Geometric N Mark SVG (viewBox 0 0 160 160)
SVG_MARK_CONTENT = '''<defs>
    <!-- Left column gradient: Cyan up into Blue -->
    <linearGradient id="leftPillarGrad" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" stop-color="#06D6D4" />
      <stop offset="65%" stop-color="#00A3FF" />
      <stop offset="100%" stop-color="#3B82F6" />
    </linearGradient>

    <!-- Top-left violet facet -->
    <linearGradient id="topFacetGrad" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#8B5CF6" />
      <stop offset="100%" stop-color="#A78BFA" />
    </linearGradient>

    <!-- Diagonal band: Electric Blue to Deep Blue -->
    <linearGradient id="diagBandGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0075FF" />
      <stop offset="45%" stop-color="#1D4ED8" />
      <stop offset="100%" stop-color="#0052CC" />
    </linearGradient>

    <!-- Right column: Vibrant Cyan -->
    <linearGradient id="rightPillarGrad" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" stop-color="#00D2D3" />
      <stop offset="50%" stop-color="#00E5FF" />
      <stop offset="100%" stop-color="#06D6D4" />
    </linearGradient>

    <filter id="cyanGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="3" result="blur" />
      <feComposite in="SourceGraphic" in2="blur" operator="over" />
    </filter>
    <filter id="violetGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="3" result="blur" />
      <feComposite in="SourceGraphic" in2="blur" operator="over" />
    </filter>
  </defs>

  <g transform="translate(6, 7)">
    <!-- 1. Diagonal Band -->
    <polygon points="54,12 115,65 115,111 54,51" fill="url(#diagBandGrad)" />

    <!-- 2. Left Column Stem -->
    <rect x="25" y="51" width="29" height="62" fill="url(#leftPillarGrad)" />

    <!-- 3. Left Top Facet (Violet) -->
    <polygon points="25,31 54,12 54,51 25,67" fill="url(#topFacetGrad)" />

    <!-- 4. Left Bottom Cyan Node -->
    <circle cx="39.5" cy="113" r="14.5" fill="#06D6D4" filter="url(#cyanGlow)" />

    <!-- 5. Right Column with Bottom Fold Point -->
    <polygon points="115,111 115,137 147,116 147,36 115,36" fill="url(#rightPillarGrad)" />

    <!-- 6. Right Top Violet Node -->
    <circle cx="131" cy="25" r="15" fill="#A78BFA" filter="url(#violetGlow)" />
  </g>'''

SVG_STANDALONE_MARK = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 160" width="100%" height="100%" fill="none">
{SVG_MARK_CONTENT}
</svg>'''

SVG_APP_ICON = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0E1726" />
      <stop offset="100%" stop-color="#070C16" />
    </linearGradient>
    <linearGradient id="borderGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3B82F6" stop-opacity="0.5" />
      <stop offset="50%" stop-color="#8B5CF6" stop-opacity="0.3" />
      <stop offset="100%" stop-color="#06D6D4" stop-opacity="0.5" />
    </linearGradient>
  </defs>

  <!-- Dark Background Squircle -->
  <rect width="512" height="512" rx="115" fill="url(#bgGrad)" />
  <rect x="2" y="2" width="508" height="508" rx="113" fill="none" stroke="url(#borderGrad)" stroke-width="3.5" opacity="0.85" />

  <!-- Mark scaled and centered -->
  <g transform="translate(256, 256) scale(2.6) translate(-80, -80)">
    {SVG_MARK_CONTENT}
  </g>
</svg>'''

def main():
    print("Step 1: Writing SVG vector assets...")
    os.makedirs(r"D:\NIVEX-FLUTTER\assets\icons", exist_ok=True)
    os.makedirs(r"D:\NIVEX-BUSINESS\public\images", exist_ok=True)

    with open(r"D:\NIVEX-FLUTTER\assets\icons\nova-mark.svg", "w", encoding="utf-8") as f:
        f.write(SVG_STANDALONE_MARK)
    with open(r"D:\NIVEX-BUSINESS\public\images\nova-mark.svg", "w", encoding="utf-8") as f:
        f.write(SVG_STANDALONE_MARK)

    with open(r"D:\NIVEX-BUSINESS\public\favicon.svg", "w", encoding="utf-8") as f:
        f.write(SVG_APP_ICON)
    with open(r"D:\NIVEX-FLUTTER\assets\icons\nova-app-icon.svg", "w", encoding="utf-8") as f:
        f.write(SVG_APP_ICON)
    with open(r"D:\NIVEX-BUSINESS\public\images\nova-app-icon.svg", "w", encoding="utf-8") as f:
        f.write(SVG_APP_ICON)

    print("Step 2: Rendering 512x512 Master App Icon PNG with Chrome headless...")
    html_file = r"D:\NIVEX-FLUTTER\assets\icons\render_app_icon.html"
    with open(html_file, "w", encoding="utf-8") as f:
        f.write(f'''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>
  body {{ margin: 0; padding: 0; background: transparent; overflow: hidden; }}
  svg {{ width: 512px; height: 512px; }}
</style></head>
<body>{SVG_APP_ICON}</body>
</html>''')

    chrome_exe = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    output_png = r"D:\NIVEX-FLUTTER\assets\icons\nova-app-icon-512.png"
    cmd = [
        chrome_exe,
        "--headless",
        "--disable-gpu",
        "--window-size=512,512",
        "--default-background-color=00000000",
        f"--screenshot={output_png}",
        f"file:///{html_file.replace(os.sep, '/')}"
    ]
    subprocess.run(cmd, check=True)
    if os.path.exists(html_file):
        os.remove(html_file)

    base_img = Image.open(output_png)

    # 1. Web Favicons
    print("Step 3: Generating Web Favicons...")
    fav_16 = base_img.resize((16, 16), Image.Resampling.LANCZOS)
    fav_32 = base_img.resize((32, 32), Image.Resampling.LANCZOS)
    fav_48 = base_img.resize((48, 48), Image.Resampling.LANCZOS)
    fav_180 = base_img.resize((180, 180), Image.Resampling.LANCZOS)
    fav_192 = base_img.resize((192, 192), Image.Resampling.LANCZOS)
    fav_512 = base_img.resize((512, 512), Image.Resampling.LANCZOS)

    fav_16.save(r"D:\NIVEX-BUSINESS\public\favicon.ico", format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])
    fav_180.save(r"D:\NIVEX-BUSINESS\public\apple-touch-icon.png")
    fav_192.save(r"D:\NIVEX-BUSINESS\public\images\icon-192.png")
    fav_512.save(r"D:\NIVEX-BUSINESS\public\images\icon-512.png")
    fav_512.save(r"D:\NIVEX-BUSINESS\app\icon.png")
    fav_180.save(r"D:\NIVEX-BUSINESS\app\apple-icon.png")

    # 2. Android Mipmap Icons
    print("Step 4: Generating Android Mipmap Icons...")
    res_dir = r"D:\NIVEX-FLUTTER\android\app\src\main\res"
    densities = {
        "mipmap-mdpi": (48, 48),
        "mipmap-hdpi": (72, 72),
        "mipmap-xhdpi": (96, 96),
        "mipmap-xxhdpi": (144, 144),
        "mipmap-xxxhdpi": (192, 192),
    }
    for folder, size in densities.items():
        out_folder = os.path.join(res_dir, folder)
        os.makedirs(out_folder, exist_ok=True)
        resized = base_img.resize(size, Image.Resampling.LANCZOS)
        out_path = os.path.join(out_folder, "ic_launcher.png")
        resized.save(out_path)
        print(f"Saved {out_path} ({size[0]}x{size[1]})")

    # 3. Flutter standalone mark PNGs
    print("Step 5: Generating Standalone Mark PNGs for Flutter...")
    # Render standalone mark without background
    mark_html = r"D:\NIVEX-FLUTTER\assets\icons\render_mark.html"
    with open(mark_html, "w", encoding="utf-8") as f:
        f.write(f'''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>
  body {{ margin: 0; padding: 0; background: transparent; overflow: hidden; }}
  svg {{ width: 256px; height: 256px; }}
</style></head>
<body>{SVG_STANDALONE_MARK}</body>
</html>''')

    mark_256_png = r"D:\NIVEX-FLUTTER\assets\icons\nova-mark.png"
    cmd_mark = [
        chrome_exe,
        "--headless",
        "--disable-gpu",
        "--window-size=256,256",
        "--default-background-color=00000000",
        f"--screenshot={mark_256_png}",
        f"file:///{mark_html.replace(os.sep, '/')}"
    ]
    subprocess.run(cmd_mark, check=True)
    if os.path.exists(mark_html):
        os.remove(mark_html)

    mark_img = Image.open(mark_256_png)
    mark_img.resize((128, 128), Image.Resampling.LANCZOS).save(r"D:\NIVEX-FLUTTER\assets\icons\nova-mark-128.png")

    # 4. Horizontal Logos
    print("Step 6: Rendering Horizontal Logos (onDark and onLight)...")
    def render_horizontal(text_color, filename):
        h_html = f'''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>
  body {{
    margin: 0; padding: 0; background: transparent;
    display: inline-flex; align-items: center; gap: 14px;
    height: 120px;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  }}
  .mark {{ width: 110px; height: 110px; flex-shrink: 0; }}
  .text {{
    color: {text_color};
    font-size: 76px;
    font-weight: 800;
    letter-spacing: -0.02em;
    line-height: 1;
    padding-bottom: 2px;
  }}
</style></head>
<body>
  <svg class="mark" viewBox="0 0 160 160" fill="none">
    {SVG_MARK_CONTENT}
  </svg>
  <span class="text">Nova</span>
</body>
</html>'''
        tmp_h_file = f"D:/NIVEX-FLUTTER/assets/icons/tmp_{filename}.html"
        with open(tmp_h_file, "w", encoding="utf-8") as f:
            f.write(h_html)

        out_path = f"D:/NIVEX-FLUTTER/assets/icons/{filename}.png"
        cmd_h = [
            chrome_exe,
            "--headless",
            "--disable-gpu",
            "--window-size=460,120",
            "--default-background-color=00000000",
            f"--screenshot={out_path}",
            f"file:///{tmp_h_file}"
        ]
        subprocess.run(cmd_h, check=True)
        if os.path.exists(tmp_h_file):
            os.remove(tmp_h_file)

        im_h = Image.open(out_path)
        bbox = im_h.getbbox()
        if bbox:
            cropped = im_h.crop(bbox)
            padded = Image.new("RGBA", (cropped.width + 12, cropped.height + 12), (0, 0, 0, 0))
            padded.paste(cropped, (6, 6))
            padded.save(out_path)
            # Copy to web
            web_copy = f"D:/NIVEX-BUSINESS/public/images/{filename}.png"
            padded.save(web_copy)
            print(f"Generated and copied {filename}.png: {padded.size}")

    render_horizontal("#FFFFFF", "nova-logo-horizontal")
    render_horizontal("#0B1220", "nova-logo-horizontal-dark")

    print("\n[SUCCESS] All Nova brand assets generated and distributed!")

if __name__ == "__main__":
    main()
