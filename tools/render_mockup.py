"""Render a mockup — taller, scarier, smaller character."""
from PIL import Image, ImageDraw
import os

SPRITE_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
SCALE = 2  # Smaller scale = smaller character, bigger world
BG_COLOR = (12, 12, 20)
VINE_COLOR = (180, 180, 180)

def load(name, scale=SCALE):
    img = Image.open(os.path.join(SPRITE_DIR, f"{name}.png")).convert("RGBA")
    return img.resize((img.width * scale, img.height * scale), Image.NEAREST)

def paste(canvas, sprite, x, y):
    canvas.paste(sprite, (x, y), sprite)

# Load sprites (smaller scale)
player = load("player_idle")
enemy_bat = load("enemy_bat")
enemy_ghost = load("enemy_ghost")
exit_door = load("exit")
vine_anchor = load("vine_anchor")
switch = load("switch_off")
platform = load("platform_tile", scale=3)  # Platforms stay chunkier
lava = load("lava_tile", scale=3)
hud_dot = load("hud_dot")

# Canvas — taller aspect ratio for more vertical feel
room = Image.new("RGBA", (640, 480), BG_COLOR)
draw = ImageDraw.Draw(room)

tile_w = platform.width
tile_h = platform.height

# === CEILING ===
for x in range(0, 640, tile_w):
    paste(room, platform, x, 0)

# Ceiling stalactites / overhangs
for x in range(40, 140, tile_w):
    paste(room, platform, x, tile_h)
    paste(room, platform, x, tile_h * 2)
for x in range(300, 370, tile_w):
    paste(room, platform, x, tile_h)
for x in range(520, 640, tile_w):
    paste(room, platform, x, tile_h)

# === WALLS ===
for y in range(0, 480, tile_h):
    # Left wall — thick at top and bottom
    paste(room, platform, 0, y)
    if y < 80 or y > 380:
        paste(room, platform, tile_w, y)
    if y > 420:
        paste(room, platform, tile_w * 2, y)

    # Right wall — thick at top and bottom
    paste(room, platform, 640 - tile_w, y)
    if y < 100 or y > 340:
        paste(room, platform, 640 - tile_w * 2, y)
    if y > 400:
        paste(room, platform, 640 - tile_w * 3, y)

# === LAVA FLOOR (thick, menacing) ===
for x in range(0, 640, tile_w):
    paste(room, lava, x, 480 - tile_h)
    paste(room, lava, x, 480 - tile_h * 2)
    paste(room, lava, x, 480 - tile_h * 3)

# === START LEDGE (bottom-left, small, low) ===
start_y = 380
for x in range(tile_w, tile_w + tile_w * 3, tile_w):
    paste(room, platform, x, start_y)

# === EXIT LEDGE (upper-right, small, high) ===
exit_y = 100
for x in range(640 - tile_w * 4, 640 - tile_w, tile_w):
    paste(room, platform, x, exit_y)

# === TINY MID LEDGE (optional stepping stone) ===
mid_y = 260
paste(room, platform, 280, mid_y)
paste(room, platform, 280 + tile_w, mid_y)

# === VINES (long drops from ceiling) ===
vine_data = [
    (160, tile_h, 260),      # Left vine — long
    (330, tile_h * 2, 180),  # Middle vine
    (470, tile_h, 220),      # Right vine — long
]
for vx, vy, length in vine_data:
    paste(room, vine_anchor, vx - vine_anchor.width // 2, vy)
    draw.line([(vx, vy + vine_anchor.height), (vx, vy + length)],
              fill=VINE_COLOR, width=1)

# === PLAYER on start ledge (tiny) ===
paste(room, player, tile_w * 2, start_y - player.height)

# === ENEMIES ===
paste(room, enemy_bat, 240, 140)
paste(room, enemy_ghost, 420, 200)

# === SWITCH ===
paste(room, switch, 380, 170)

# === EXIT DOOR ===
paste(room, exit_door, 640 - tile_w * 3, exit_y - exit_door.height)

# === HUD — 0 strikes ===
def tint_dot(color):
    dot = load("hud_dot")
    tinted = Image.new("RGBA", dot.size, (0, 0, 0, 0))
    for x in range(dot.width):
        for y in range(dot.height):
            r, g, b, a = dot.getpixel((x, y))
            if a > 0:
                tinted.putpixel((x, y), color)
    return tinted

dim_dot = tint_dot((50, 50, 50, 60))
dot_h = dim_dot.height + 4
base_y = 46
paste(room, dim_dot, 16, base_y)
paste(room, dim_dot, 16, base_y - dot_h)
paste(room, dim_dot, 16, base_y - dot_h * 2)

out_path = os.path.join(os.path.dirname(__file__), "..", "assets", "room_mockup.png")
room.save(out_path)
print(f"Mockup saved to {os.path.abspath(out_path)}")
