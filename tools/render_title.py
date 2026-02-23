"""Render title screen mockup — big 3, bottomless pit, glowing switch, press start."""
from PIL import Image, ImageDraw
import os, math

SPRITE_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
BG_COLOR = (8, 8, 14)

def load(name, scale=3):
    img = Image.open(os.path.join(SPRITE_DIR, f"{name}.png")).convert("RGBA")
    return img.resize((img.width * scale, img.height * scale), Image.NEAREST)

def paste(canvas, sprite, x, y):
    canvas.paste(sprite, (x, y), sprite)

def draw_char(draw, ch, x, y, scale, color):
    """Draw a tiny pixel font character."""
    chars = {
        'P': [(0,0),(1,0),(2,0),(0,1),(3,1),(0,2),(1,2),(2,2),(0,3),(0,4)],
        'R': [(0,0),(1,0),(2,0),(0,1),(3,1),(0,2),(1,2),(2,2),(0,3),(3,3),(0,4),(3,4)],
        'E': [(0,0),(1,0),(2,0),(3,0),(0,1),(0,2),(1,2),(2,2),(0,3),(0,4),(1,4),(2,4),(3,4)],
        'S': [(1,0),(2,0),(3,0),(0,1),(1,2),(2,2),(3,3),(0,4),(1,4),(2,4)],
        'T': [(0,0),(1,0),(2,0),(3,0),(1,1),(1,2),(1,3),(1,4)],
        'A': [(1,0),(2,0),(0,1),(3,1),(0,2),(1,2),(2,2),(3,2),(0,3),(3,3),(0,4),(3,4)],
    }
    pixels = chars.get(ch, [])
    for px_x, px_y in pixels:
        rx = x + px_x * scale
        ry = y + px_y * scale
        draw.rectangle([rx, ry, rx + scale - 1, ry + scale - 1], fill=color)

# Load sprites
player = load("player_idle", scale=2)
exit_door = load("exit", scale=2)
platform = load("platform_tile", scale=3)
vine_anchor = load("vine_anchor", scale=2)
switch_off = load("switch_off", scale=3)
lava = load("lava_tile", scale=3)

# Canvas
screen = Image.new("RGBA", (640, 480), BG_COLOR)
draw = ImageDraw.Draw(screen)

tile_w = platform.width
tile_h = platform.height
lava_w = lava.width
lava_h = lava.height

# === Lava at the very bottom — just barely visible ===
lava_y = 456
for x in range(0, 640, lava_w):
    paste(screen, lava, x, lava_y)

# === Bottomless pit — fade to near-black above lava ===
for y in range(360, 456):
    t = (y - 360) / 96.0
    fade = max(0, int(14 * (1.0 - t)))
    # Blend toward a very faint orange glow near lava
    r = fade + int(12 * t)
    g = fade + int(4 * t)
    b = fade + 2
    draw.line([(0, y), (640, y)], fill=(r, g, b))

# === Left ledge (player) — small, mid-height ===
ledge_y = 320
for x in range(0, tile_w * 2, tile_w):
    paste(screen, platform, x, ledge_y)
for y in range(ledge_y + tile_h, 480, tile_h):
    paste(screen, platform, 0, y)

# === Right ledge (exit) — small, higher up ===
exit_ledge_y = 260
for x in range(640 - tile_w * 2, 640, tile_w):
    paste(screen, platform, x, exit_ledge_y)
for y in range(exit_ledge_y + tile_h, 480, tile_h):
    paste(screen, platform, 640 - tile_w, y)

# === Player on left ledge ===
paste(screen, player, tile_w // 2 + 2, ledge_y - player.height)

# === Exit on right ledge ===
paste(screen, exit_door, 640 - tile_w - exit_door.width // 2, exit_ledge_y - exit_door.height)

# === Tiny platform in the middle with pillar underneath ===
# Thin slab — squash the platform tile vertically to ~8px tall
thin_platform = platform.resize((tile_w, 8), Image.NEAREST)
mid_x = (640 - tile_w) // 2
mid_y = 344
paste(screen, thin_platform, mid_x, mid_y)

# Pillar — 1/4 the width of platform, going down into the void
pillar_w = tile_w // 4
pillar_x = mid_x + (tile_w - pillar_w) // 2
pillar_top = mid_y + 8
for y in range(pillar_top, 456):
    # Fade the pillar into darkness as it goes down
    t = (y - pillar_top) / (456 - pillar_top)
    brightness = int(80 * (1.0 - t * 0.8))
    draw.rectangle(
        [pillar_x, y, pillar_x + pillar_w - 1, y],
        fill=(brightness, brightness, brightness)
    )

# === Enemies in the void ===
enemy_bat = load("enemy_bat", scale=2)
enemy_ghost = load("enemy_ghost", scale=2)
paste(screen, enemy_bat, 260, 240)
paste(screen, enemy_ghost, 420, 310)

# === Glowing switch — small rectangular push button on the right wall ===
sw_w = 6
sw_h = 10
switch_x = 640 - tile_w - sw_w
switch_y = exit_ledge_y + tile_h + 10  # just below the exit platform
# Rectangular push button, taller than wide
draw.rectangle(
    [switch_x, switch_y, switch_x + sw_w - 1, switch_y + sw_h - 1],
    fill=(240, 140, 30)
)
# Subtle glow halo
glow_radius = 10
scx = switch_x + sw_w // 2
scy = switch_y + sw_h // 2
for gy in range(-glow_radius, glow_radius + 1):
    for gx in range(-glow_radius, glow_radius + 1):
        dist = math.sqrt(gx * gx + gy * gy)
        if dist <= glow_radius and dist > 4:
            alpha = int(45 * (1.0 - dist / glow_radius))
            sx = scx + gx
            sy = scy + gy
            if 0 <= sx < 640 and 0 <= sy < 480:
                existing = screen.getpixel((sx, sy))
                r = min(255, existing[0] + int(alpha * 1.0))
                g = min(255, existing[1] + int(alpha * 0.4))
                b = existing[2]
                screen.putpixel((sx, sy), (r, g, b, 255))

# === HUD — traffic light dots, upper left, empty (0 strikes at start) ===
# Squiggly blob shape (like the switch sprite) — imperfect, organic
# Each blob is ~6x6 pixels drawn at 2x
blob_pixels = [
    (1,0),(2,0),(3,0),
    (0,1),(1,1),(2,1),(3,1),(4,1),
    (0,2),(1,2),(2,2),(3,2),(4,2),
    (0,3),(1,3),(2,3),(3,3),(4,3),(5,3),
    (1,4),(2,4),(3,4),(4,4),
    (2,5),(3,5),
]
hud_x = 10
hud_blob_scale = 2
hud_spacing = 16
hud_dim_colors = [
    (50, 180, 50),    # green — dim
    (180, 170, 30),   # yellow — dim
    (180, 50, 50),    # red — dim
]
for i in range(3):
    dot_y = 10 + (2 - i) * hud_spacing
    col = hud_dim_colors[i]
    for bx, by in blob_pixels:
        rx = hud_x + bx * hud_blob_scale
        ry = dot_y + by * hud_blob_scale
        draw.rectangle([rx, ry, rx + hud_blob_scale - 1, ry + hud_blob_scale - 1], fill=col)

# === BIG "3" — centered, chunky ===
PX = 14
ox = (640 - 7 * PX) // 2
oy = 50

three_pixels = [
    # Top bar
    (1,0),(2,0),(3,0),(4,0),(5,0),
    (0,1),(5,1),
    # Right arm
    (5,2),
    # Middle bar
    (2,3),(3,3),(4,3),(5,3),
    # Right arm
    (5,4),
    (0,5),(5,5),
    # Bottom bar
    (1,6),(2,6),(3,6),(4,6),(5,6),
]

for px_x, px_y in three_pixels:
    x = ox + px_x * PX
    y = oy + px_y * PX
    draw.rectangle([x, y, x + PX - 2, y + PX - 2], fill=(255, 255, 255))

# === "PRESS START" — near the bottom, emerging from darkness ===
press_color = (120, 120, 120)
text = "PRESS START"
total_w = 0
for ch in text:
    total_w += 10 if ch == ' ' else 12
cx = (640 - total_w) // 2
for ch in text:
    if ch == ' ':
        cx += 10
        continue
    draw_char(draw, ch, cx, 430, 2, press_color)
    cx += 12

out_path = os.path.join(os.path.dirname(__file__), "..", "assets", "title_mockup.png")
screen.save(out_path)
print(f"Title mockup saved to {os.path.abspath(out_path)}")
