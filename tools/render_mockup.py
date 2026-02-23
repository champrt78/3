"""Render a mockup of what a room looks like with the sprites."""
from PIL import Image, ImageDraw
import os

SPRITE_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
SCALE = 3
BG_COLOR = (12, 12, 20)
VINE_COLOR = (200, 200, 200)

def load(name):
    img = Image.open(os.path.join(SPRITE_DIR, f"{name}.png")).convert("RGBA")
    return img.resize((img.width * SCALE, img.height * SCALE), Image.NEAREST)

def paste(canvas, sprite, x, y):
    canvas.paste(sprite, (x, y), sprite)

# Load sprites
player = load("player_idle")
enemy_bat = load("enemy_bat")
enemy_ghost = load("enemy_ghost")
exit_door = load("exit")
vine_anchor = load("vine_anchor")
switch = load("switch_off")
platform = load("platform_tile")
lava = load("lava_tile")
hud_dot = load("hud_dot")

# Canvas
room = Image.new("RGBA", (640, 480), BG_COLOR)
draw = ImageDraw.Draw(room)

tile_w = platform.width
tile_h = platform.height

# === WALLS (full height, jagged cave feel) ===
for y in range(0, 480, tile_h):
    # Left wall (2 tiles thick at spots)
    paste(room, platform, 0, y)
    if y < 120 or y > 380:
        paste(room, platform, tile_w, y)
    # Right wall
    paste(room, platform, 640 - tile_w, y)
    if y < 140 or y > 340:
        paste(room, platform, 640 - tile_w * 2, y)

# === CEILING ===
for x in range(0, 640, tile_w):
    paste(room, platform, x, 0)
# Ceiling overhangs / stalactites
for x in range(0, 160, tile_w):
    paste(room, platform, x, tile_h)
for x in range(280, 380, tile_w):
    paste(room, platform, x, tile_h)
for x in range(500, 640, tile_w):
    paste(room, platform, x, tile_h)

# === LAVA FLOOR (the whole bottom is lava) ===
for x in range(0, 640, tile_w):
    paste(room, lava, x, 480 - tile_h)
    paste(room, lava, x, 480 - tile_h * 2)

# === START LEDGE (bottom-left, small) ===
for x in range(tile_w, tile_w * 5, tile_w):
    paste(room, platform, x, 360)

# === EXIT LEDGE (right side, higher up) ===
for x in range(640 - tile_w * 5, 640 - tile_w, tile_w):
    paste(room, platform, x, 260)

# === SMALL STEPPING LEDGE (middle, tiny) ===
for x in range(280, 280 + tile_w * 2, tile_w):
    paste(room, platform, x, 320)

# === VINES (hanging from ceiling into the chasm) ===
vine_data = [
    (180, tile_h, 200),      # Left vine, long
    (340, tile_h * 2, 160),  # Middle vine
    (480, tile_h, 180),      # Right vine
]
for vx, vy, length in vine_data:
    paste(room, vine_anchor, vx - vine_anchor.width // 2, vy)
    draw.line([(vx, vy + vine_anchor.height), (vx, vy + length)],
              fill=VINE_COLOR, width=2)

# === PLAYER on start ledge ===
paste(room, player, tile_w * 2, 360 - player.height)

# === ENEMIES in the chasm ===
paste(room, enemy_bat, 260, 180)
paste(room, enemy_ghost, 440, 300)

# === SWITCH floating in chasm ===
paste(room, switch, 400, 200)

# === EXIT DOOR on exit ledge ===
paste(room, exit_door, 640 - tile_w * 3, 260 - exit_door.height)

# === HUD — 0 strikes (fresh room, just dim slots) ===
def tint_dot(color):
    dot = load("hud_dot")
    tinted = Image.new("RGBA", dot.size, (0, 0, 0, 0))
    for x in range(dot.width):
        for y in range(dot.height):
            r, g, b, a = dot.getpixel((x, y))
            if a > 0:
                tinted.putpixel((x, y), color)
    return tinted

dim_dot = tint_dot((60, 60, 60, 80))
dot_h = dim_dot.height + 6
base_y = 56
paste(room, dim_dot, 20, base_y)
paste(room, dim_dot, 20, base_y - dot_h)
paste(room, dim_dot, 20, base_y - dot_h * 2)

out_path = os.path.join(os.path.dirname(__file__), "..", "assets", "room_mockup.png")
room.save(out_path)
print(f"Mockup saved to {os.path.abspath(out_path)}")
