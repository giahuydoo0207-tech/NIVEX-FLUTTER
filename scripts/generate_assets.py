import os
import subprocess
from PIL import Image

# 1. Authoritative Vector Definitions
SVG_MARK_INNER = '''<defs>
    <!-- Cyan gradient for left lower column & right column -->
    <linearGradient id="novaCyan" x1="0" y1="1" x2="0" y2="0">
      <stop offset="0%" stop-color="#00F2FE"/>
      <stop offset="100%" stop-color="#06D6D4"/>
    </linearGradient>

    <!-- Violet / purple facet gradient -->
    <linearGradient id="novaPurple" x1="0" y1="1" x2="1" y2="0">
      <stop offset="0%" stop-color="#7C3AED"/>
      <stop offset="40%" stop-color="#8B5CF6"/>
      <stop offset="100%" stop-color="#A78BFA"/>
    </linearGradient>

    <!-- Upper diagonal ribbon: electric blue -->
    <linearGradient id="novaUpperBlue" x1="0.1" y1="0" x2="0.9" y2="1">
      <stop offset="0%" stop-color="#0099FF"/>
      <stop offset="50%" stop-color="#0066FF"/>
      <stop offset="100%" stop-color="#004AD8"/>
    </linearGradient>

    <!-- Lower diagonal bar: deep vibrant blue -->
    <linearGradient id="novaLowerBlue" x1="0.1" y1="0" x2="0.9" y2="1">
      <stop offset="0%" stop-color="#0072FF"/>
      <stop offset="100%" stop-color="#0044CC"/>
    </linearGradient>
  </defs>

  <!-- 1. Left Lower Pillar (Cyan) -->
  <circle cx="41" cy="146" r="19" fill="#00F2FE"/>
  <path d="M 22 146 L 22 93 L 60 69 L 60 146 Z" fill="url(#novaCyan)"/>

  <!-- 2. Left Upper Facet (Purple) -->
  <path d="M 22 93 L 22 44 L 60 20 L 60 69 Z" fill="url(#novaPurple)"/>

  <!-- 3. Upper Diagonal Ribbon (Electric Blue) -->
  <path d="M 60 20 L 145 88 L 145 136 L 60 68 Z" fill="url(#novaUpperBlue)"/>

  <!-- 4. Lower Diagonal Bar (Deep Blue) -->
  <path d="M 68 100 L 145 161.6 L 145 188 L 68 126.4 Z" fill="url(#novaLowerBlue)"/>

  <!-- 5. Right Pillar (Cyan) -->
  <path d="M 145 24 L 178 24 L 178 161.6 L 145 188 Z" fill="url(#novaCyan)"/>

  <!-- 6. Top Right Circle (Lilac / Violet) -->
  <circle cx="161.5" cy="24" r="16.5" fill="#A78BFA"/>'''

SVG_MARK_STANDALONE = f'''<svg
  width="200"
  height="200"
  viewBox="0 0 200 200"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
>
{SVG_MARK_INNER}
</svg>'''

# App icon: Squircle on dark navy #071425
SVG_APP_ICON = f'''<svg
  width="512"
  height="512"
  viewBox="0 0 512 512"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
>
  <rect width="512" height="512" rx="115" fill="#071425" />
  <rect x="2" y="2" width="508" height="508" rx="113" fill="none" stroke="#2563EB" stroke-width="2" opacity="0.3" />
  <g transform="translate(256, 256) scale(2.05) translate(-100, -100)">
    {SVG_MARK_INNER}
  </g>
</svg>'''

def main():
    print("Writing SVG assets...")
    os.makedirs(r"D:\NIVEX-FLUTTER\assets\logo", exist_ok=True)
    os.makedirs(r"D:\NIVEX-FLUTTER\assets\icons", exist_ok=True)
    os.makedirs(r"D:\NIVEX-BUSINESS\public\images", exist_ok=True)

    # 1. Save nova_logo.svg in Flutter and Web
    with open(r"D:\NIVEX-FLUTTER\assets\logo\nova_logo.svg", "w", encoding="utf-8") as f:
        f.write(SVG_MARK_STANDALONE)
    with open(r"D:\NIVEX-BUSINESS\public\images\nova_logo.svg", "w", encoding="utf-8") as f:
        f.write(SVG_MARK_STANDALONE)

    # 2. Favicon SVG on dark navy
    with open(r"D:\NIVEX-BUSINESS\public\favicon.svg", "w", encoding="utf-8") as f:
        f.write(SVG_APP_ICON)

    # 3. Render 512x512 App Icon PNG with headless Chrome
    chrome_exe = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    tmp_html = r"D:\NIVEX-FLUTTER\assets\icons\tmp_app_icon.html"
    with open(tmp_html, "w", encoding="utf-8") as f:
        f.write(f'''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
  body {{ margin: 0; padding: 0; background: transparent; }}
  svg {{ width: 512px; height: 512px; }}
</style></head>
<body>{SVG_APP_ICON}</body></html>''')

    app_icon_512 = r"D:\NIVEX-FLUTTER\assets\icons\nova-app-icon-512.png"
    cmd = [
        chrome_exe,
        "--headless",
        "--disable-gpu",
        "--window-size=512,512",
        "--default-background-color=00000000",
        f"--screenshot={app_icon_512}",
        f"file:///{tmp_html.replace(os.sep, '/')}"
    ]
    subprocess.run(cmd, check=True)
    if os.path.exists(tmp_html):
        os.remove(tmp_html)

    base_app_icon = Image.open(app_icon_512)

    # 4. Generate Web Favicons
    print("Generating Web Favicons...")
    fav_16 = base_app_icon.resize((16, 16), Image.Resampling.LANCZOS)
    fav_32 = base_app_icon.resize((32, 32), Image.Resampling.LANCZOS)
    fav_48 = base_app_icon.resize((48, 48), Image.Resampling.LANCZOS)
    fav_180 = base_app_icon.resize((180, 180), Image.Resampling.LANCZOS)
    fav_192 = base_app_icon.resize((192, 192), Image.Resampling.LANCZOS)
    fav_512 = base_app_icon.resize((512, 512), Image.Resampling.LANCZOS)

    fav_16.save(r"D:\NIVEX-BUSINESS\public\favicon.ico", format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])
    fav_180.save(r"D:\NIVEX-BUSINESS\public\apple-touch-icon.png")
    fav_192.save(r"D:\NIVEX-BUSINESS\public\images\icon-192.png")
    fav_512.save(r"D:\NIVEX-BUSINESS\public\images\icon-512.png")
    fav_512.save(r"D:\NIVEX-BUSINESS\app\icon.png")
    fav_180.save(r"D:\NIVEX-BUSINESS\app\apple-icon.png")

    # 5. Generate Android Launcher Icons
    print("Generating Android Launcher Icons...")
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
        resized = base_app_icon.resize(size, Image.Resampling.LANCZOS)
        out_path = os.path.join(out_folder, "ic_launcher.png")
        resized.save(out_path)
        print(f"Saved {out_path} ({size[0]}x{size[1]})")

    # 6. Render Horizontal Logos (onDark and onLight)
    print("Rendering Horizontal Logos...")
    def render_horizontal(text_color, filename):
        h_html = f'''<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@700;800&display=swap');
  body {{
    margin: 0; padding: 0; background: transparent;
    display: inline-flex; align-items: center; gap: 18px;
    height: 120px;
    font-family: 'Plus Jakarta Sans', Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  }}
  .mark {{ width: 104px; height: 104px; flex-shrink: 0; }}
  .text {{
    color: {text_color};
    font-size: 80px;
    font-weight: 800;
    letter-spacing: -2.5px;
    line-height: 1;
    padding-bottom: 2px;
  }}
</style></head>
<body>
  <svg class="mark" viewBox="0 0 200 200" fill="none">
    {SVG_MARK_INNER}
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
            "--window-size=540,140",
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
            padded = Image.new("RGBA", (cropped.width + 16, cropped.height + 16), (0, 0, 0, 0))
            padded.paste(cropped, (8, 8))
            padded.save(out_path)
            # Copy to web
            web_copy = f"D:/NIVEX-BUSINESS/public/images/{filename}.png"
            padded.save(web_copy)
            print(f"Generated {filename}.png: {padded.size}")

    render_horizontal("#FFFFFF", "nova-logo-horizontal")
    render_horizontal("#0B1220", "nova-logo-horizontal-dark")

    # 7. Render Standalone Mark PNG
    print("Rendering Standalone Mark...")
    tmp_m_file = r"D:\NIVEX-FLUTTER\assets\icons\tmp_mark.html"
    with open(tmp_m_file, "w", encoding="utf-8") as f:
        f.write(f'''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
  body {{ margin: 0; padding: 0; background: transparent; }}
  svg {{ width: 256px; height: 256px; }}
</style></head>
<body>{SVG_MARK_STANDALONE}</body></html>''')

    mark_256 = r"D:\NIVEX-FLUTTER\assets\icons\nova-mark.png"
    cmd_m = [
        chrome_exe,
        "--headless",
        "--disable-gpu",
        "--window-size=256,256",
        "--default-background-color=00000000",
        f"--screenshot={mark_256}",
        f"file:///{tmp_m_file.replace(os.sep, '/')}"
    ]
    subprocess.run(cmd_m, check=True)
    if os.path.exists(tmp_m_file):
        os.remove(tmp_m_file)

    im_m = Image.open(mark_256)
    bbox_m = im_m.getbbox()
    if bbox_m:
        crop_m = im_m.crop(bbox_m)
        max_dim = max(crop_m.width, crop_m.height)
        sq_m = Image.new("RGBA", (max_dim, max_dim), (0, 0, 0, 0))
        sq_m.paste(crop_m, ((max_dim - crop_m.width)//2, (max_dim - crop_m.height)//2))
        sq_m.resize((256, 256), Image.Resampling.LANCZOS).save(mark_256)
        sq_m.resize((128, 128), Image.Resampling.LANCZOS).save(r"D:\NIVEX-FLUTTER\assets\icons\nova-mark-128.png")
        sq_m.resize((256, 256), Image.Resampling.LANCZOS).save(r"D:\NIVEX-BUSINESS\public\images\nova-mark.png")

    print("\n[SUCCESS] Generated all branding assets with 100% fidelity!")

if __name__ == "__main__":
    main()
