"""Generate 1-bit style pixel art sprites for '3'."""
from PIL import Image, ImageDraw

WHITE = (255, 255, 255, 255)
BLACK = (0, 0, 0, 0)
RED = (230, 60, 60, 255)
GREEN = (60, 230, 60, 255)
YELLOW = (240, 220, 40, 255)
GRAY = (180, 180, 180, 255)
DARK_GRAY = (80, 80, 80, 255)
VINE_COLOR = (200, 200, 200, 255)
ORANGE = (255, 120, 30, 255)
DARK_ORANGE = (200, 80, 10, 255)
BRIGHT_ORANGE = (255, 180, 50, 255)

def px(img, x, y, color=WHITE):
    """Set a pixel if in bounds."""
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)

def make_player_idle():
    """7x10 side view — standing, facing right."""
    img = Image.new("RGBA", (7, 10), BLACK)
    # Head (2x2, small)
    px(img, 3, 0); px(img, 4, 0)
    px(img, 3, 1); px(img, 4, 1)
    # Neck
    px(img, 3, 2)
    # Torso
    px(img, 3, 3); px(img, 3, 4); px(img, 3, 5)
    # Arm (hanging down, front)
    px(img, 4, 3); px(img, 4, 4)
    # Legs (standing)
    px(img, 3, 6)
    px(img, 2, 7); px(img, 4, 7)
    px(img, 2, 8); px(img, 4, 8)
    px(img, 1, 9); px(img, 5, 9)
    return img

def make_player_run1():
    """7x10 side view — run frame 1, legs apart."""
    img = Image.new("RGBA", (7, 10), BLACK)
    # Head
    px(img, 3, 0); px(img, 4, 0)
    px(img, 3, 1); px(img, 4, 1)
    # Neck
    px(img, 3, 2)
    # Torso
    px(img, 3, 3); px(img, 3, 4); px(img, 3, 5)
    # Arms swinging (back arm back, front arm forward)
    px(img, 2, 3); px(img, 5, 4)
    # Legs apart (stride)
    px(img, 3, 6)
    px(img, 1, 7); px(img, 5, 7)
    px(img, 0, 8); px(img, 6, 8)
    return img

def make_player_run2():
    """7x10 side view — run frame 2, legs passing."""
    img = Image.new("RGBA", (7, 10), BLACK)
    # Head
    px(img, 3, 0); px(img, 4, 0)
    px(img, 3, 1); px(img, 4, 1)
    # Neck
    px(img, 3, 2)
    # Torso
    px(img, 3, 3); px(img, 3, 4); px(img, 3, 5)
    # Arms swinging (opposite)
    px(img, 5, 3); px(img, 2, 4)
    # Legs together (passing)
    px(img, 3, 6)
    px(img, 3, 7)
    px(img, 3, 8)
    px(img, 2, 9)
    return img

def make_player_run3():
    """7x10 side view — run frame 3, opposite stride."""
    img = Image.new("RGBA", (7, 10), BLACK)
    # Head
    px(img, 3, 0); px(img, 4, 0)
    px(img, 3, 1); px(img, 4, 1)
    # Neck
    px(img, 3, 2)
    # Torso
    px(img, 3, 3); px(img, 3, 4); px(img, 3, 5)
    # Arms swinging
    px(img, 5, 3); px(img, 2, 4)
    # Legs apart (opposite stride)
    px(img, 3, 6)
    px(img, 5, 7); px(img, 1, 7)
    px(img, 6, 8); px(img, 0, 8)
    return img

def make_player_jump():
    """7x10 side view — in the air, legs tucked."""
    img = Image.new("RGBA", (7, 10), BLACK)
    # Head
    px(img, 3, 0); px(img, 4, 0)
    px(img, 3, 1); px(img, 4, 1)
    # Neck
    px(img, 3, 2)
    # Torso
    px(img, 3, 3); px(img, 3, 4); px(img, 3, 5)
    # Arms up
    px(img, 2, 2); px(img, 5, 2)
    # Legs tucked
    px(img, 3, 6)
    px(img, 2, 7); px(img, 4, 7)
    return img

def make_player_land():
    """7x10 side view — landing impact, crouched."""
    img = Image.new("RGBA", (7, 10), BLACK)
    # Head (lower, crouched)
    px(img, 3, 1); px(img, 4, 1)
    px(img, 3, 2); px(img, 4, 2)
    # Neck
    px(img, 3, 3)
    # Torso (compressed)
    px(img, 3, 4); px(img, 3, 5)
    # Arms out for balance
    px(img, 1, 4); px(img, 2, 4); px(img, 4, 4); px(img, 5, 4)
    # Legs bent wide (crouched)
    px(img, 2, 6); px(img, 4, 6)
    px(img, 1, 7); px(img, 5, 7)
    px(img, 0, 8); px(img, 6, 8)
    return img

def make_player_swing():
    """7x10 side view — hanging from vine, arms up."""
    img = Image.new("RGBA", (7, 10), BLACK)
    # Arms up (gripping vine)
    px(img, 3, 0); px(img, 4, 0)
    # Head
    px(img, 3, 1); px(img, 4, 1)
    px(img, 3, 2); px(img, 4, 2)
    # Neck
    px(img, 3, 3)
    # Torso
    px(img, 3, 4); px(img, 3, 5)
    px(img, 3, 6)
    # Legs dangling
    px(img, 2, 7); px(img, 4, 7)
    px(img, 2, 8); px(img, 4, 8)
    px(img, 1, 9); px(img, 5, 9)
    return img

def make_enemy_ground():
    """8x8 ground enemy — small crawling creature."""
    img = Image.new("RGBA", (8, 8), BLACK)
    # Body
    for x in range(2, 6):
        for y in range(2, 5):
            px(img, x, y, RED)
    px(img, 1, 3, RED); px(img, 6, 3, RED)
    px(img, 1, 4, RED); px(img, 6, 4, RED)
    # Eyes
    px(img, 3, 2, BLACK); px(img, 4, 2, BLACK)
    # Legs
    px(img, 1, 5, RED); px(img, 2, 6, RED)
    px(img, 6, 5, RED); px(img, 5, 6, RED)
    px(img, 0, 6, RED); px(img, 7, 6, RED)
    return img

def make_enemy_bat():
    """10x8 flying enemy — bat with spread wings."""
    img = Image.new("RGBA", (10, 8), BLACK)
    c = RED
    # Body center
    px(img, 4, 2, c); px(img, 5, 2, c)
    px(img, 4, 3, c); px(img, 5, 3, c)
    px(img, 4, 4, c); px(img, 5, 4, c)
    # Eyes
    px(img, 4, 2, WHITE); px(img, 5, 2, WHITE)
    # Left wing
    px(img, 3, 1, c); px(img, 2, 0, c); px(img, 1, 0, c); px(img, 0, 1, c)
    px(img, 3, 2, c); px(img, 2, 2, c); px(img, 1, 3, c); px(img, 0, 3, c)
    # Right wing
    px(img, 6, 1, c); px(img, 7, 0, c); px(img, 8, 0, c); px(img, 9, 1, c)
    px(img, 6, 2, c); px(img, 7, 2, c); px(img, 8, 3, c); px(img, 9, 3, c)
    # Fangs
    px(img, 4, 5, c); px(img, 5, 5, c)
    return img

def make_enemy_ghost():
    """8x10 flying enemy — small ghost, floats up and down."""
    img = Image.new("RGBA", (8, 10), BLACK)
    c = (200, 200, 255, 255)  # Pale blue-white
    # Head dome
    px(img, 3, 0, c); px(img, 4, 0, c)
    px(img, 2, 1, c); px(img, 3, 1, c); px(img, 4, 1, c); px(img, 5, 1, c)
    # Body
    for y in range(2, 7):
        for x in range(1, 7):
            px(img, x, y, c)
    # Eyes (dark)
    px(img, 3, 3, BLACK); px(img, 5, 3, BLACK)
    # Mouth
    px(img, 3, 5, BLACK); px(img, 4, 5, BLACK); px(img, 5, 5, BLACK)
    # Wavy bottom
    px(img, 1, 7, c); px(img, 2, 8, c); px(img, 3, 7, c)
    px(img, 4, 8, c); px(img, 5, 7, c); px(img, 6, 8, c)
    return img

def make_lava_tile():
    """8x8 lava tile — bubbling, instant death."""
    img = Image.new("RGBA", (8, 8), BLACK)
    # Base lava fill
    for x in range(8):
        for y in range(2, 8):
            px(img, x, y, DARK_ORANGE)
    # Bright surface / bubbles on top
    for x in range(8):
        px(img, x, 0, BRIGHT_ORANGE)
        px(img, x, 1, ORANGE)
    # Bubble highlights
    px(img, 2, 3, BRIGHT_ORANGE)
    px(img, 5, 4, BRIGHT_ORANGE)
    px(img, 1, 5, ORANGE)
    px(img, 6, 6, ORANGE)
    px(img, 3, 6, BRIGHT_ORANGE)
    return img

def make_enemy_jumper():
    """8x8 ground jumper — squat monster that hops."""
    img = Image.new("RGBA", (8, 8), BLACK)
    c = RED
    # Wide squat body
    for x in range(1, 7):
        px(img, x, 3, c)
        px(img, x, 4, c)
    for x in range(2, 6):
        px(img, x, 2, c)
        px(img, x, 5, c)
    # Eyes (angry, wide set)
    px(img, 2, 2, WHITE); px(img, 5, 2, WHITE)
    # Horns / spikes on top
    px(img, 2, 1, c); px(img, 5, 1, c)
    px(img, 1, 0, c); px(img, 6, 0, c)
    # Stubby legs
    px(img, 1, 5, c); px(img, 6, 5, c)
    px(img, 0, 6, c); px(img, 7, 6, c)
    px(img, 0, 7, c); px(img, 7, 7, c)
    return img

def make_enemy_jumper_air():
    """8x8 ground jumper — mid-jump, legs tucked."""
    img = Image.new("RGBA", (8, 8), BLACK)
    c = RED
    # Same body but shifted up, legs tucked
    for x in range(1, 7):
        px(img, x, 2, c)
        px(img, x, 3, c)
    for x in range(2, 6):
        px(img, x, 1, c)
        px(img, x, 4, c)
    # Eyes
    px(img, 2, 1, WHITE); px(img, 5, 1, WHITE)
    # Horns
    px(img, 1, 0, c); px(img, 6, 0, c)
    # Legs tucked under
    px(img, 2, 5, c); px(img, 5, 5, c)
    return img

def make_arrow():
    """9x5 arrow projectile — proper arrowhead + fletching."""
    img = Image.new("RGBA", (9, 5), BLACK)
    # Shaft (thin center line)
    for x in range(1, 7):
        px(img, x, 2)
    # Arrowhead (triangle pointing right)
    px(img, 7, 1); px(img, 7, 2); px(img, 7, 3)
    px(img, 8, 2)
    # Fletching (V at the back)
    px(img, 0, 0); px(img, 1, 1)
    px(img, 0, 4); px(img, 1, 3)
    return img

def make_platform_tile():
    """8x8 platform tile."""
    img = Image.new("RGBA", (8, 8), BLACK)
    for x in range(8):
        for y in range(8):
            if y == 0:
                px(img, x, y, WHITE)
            elif y == 1:
                px(img, x, y, GRAY)
            else:
                px(img, x, y, DARK_GRAY)
    return img

def make_vine_anchor():
    """5x3 vine anchor point (ceiling mount) — small hook, no ball."""
    img = Image.new("RGBA", (5, 3), BLACK)
    px(img, 1, 0, VINE_COLOR); px(img, 2, 0, VINE_COLOR); px(img, 3, 0, VINE_COLOR)
    px(img, 2, 1, VINE_COLOR)
    px(img, 2, 2, VINE_COLOR)
    return img

def make_exit():
    """8x16 exit door/portal."""
    img = Image.new("RGBA", (8, 16), BLACK)
    # Door frame
    for y in range(16):
        px(img, 0, y, GREEN); px(img, 7, y, GREEN)
    for x in range(8):
        px(img, x, 0, GREEN)
    # Inner glow
    for y in range(1, 16):
        for x in range(2, 6):
            px(img, x, y, (40, 180, 40, 120))
    # Arrow hint
    px(img, 3, 7); px(img, 4, 7); px(img, 5, 8); px(img, 4, 9); px(img, 3, 9)
    return img

def make_switch_off():
    """6x6 switch (inactive)."""
    img = Image.new("RGBA", (6, 6), BLACK)
    for x in range(1, 5):
        for y in range(1, 5):
            px(img, x, y, YELLOW)
    px(img, 0, 3, YELLOW); px(img, 5, 3, YELLOW)
    px(img, 3, 0, YELLOW); px(img, 3, 5, YELLOW)
    return img

def make_switch_on():
    """6x6 switch (activated)."""
    img = Image.new("RGBA", (6, 6), BLACK)
    for x in range(1, 5):
        for y in range(1, 5):
            px(img, x, y, GREEN)
    px(img, 0, 3, GREEN); px(img, 5, 3, GREEN)
    px(img, 3, 0, GREEN); px(img, 3, 5, GREEN)
    return img

def make_death_particles():
    """12x12 explosion/death burst."""
    img = Image.new("RGBA", (12, 12), BLACK)
    burst = [(6,0),(5,1),(7,1),(3,2),(9,2),(1,3),(11,3),
             (0,5),(11,6),(1,8),(10,9),(3,10),(8,10),
             (5,11),(7,11),(6,6),(4,4),(8,4),(4,8),(8,8)]
    for x, y in burst:
        px(img, x, y)
    return img

def make_hud_dot():
    """6x6 circle for HUD dots."""
    img = Image.new("RGBA", (6, 6), BLACK)
    pixels = [(2,0),(3,0),(1,1),(2,1),(3,1),(4,1),
              (0,2),(1,2),(2,2),(3,2),(4,2),(5,2),
              (0,3),(1,3),(2,3),(3,3),(4,3),(5,3),
              (1,4),(2,4),(3,4),(4,4),(2,5),(3,5)]
    for x, y in pixels:
        px(img, x, y)
    return img


# Generate all sprites
sprites = {
    "player_idle": make_player_idle(),
    "player_run1": make_player_run1(),
    "player_run2": make_player_run2(),
    "player_run3": make_player_run3(),
    "player_jump": make_player_jump(),
    "player_land": make_player_land(),
    "player_swing": make_player_swing(),
    "enemy_ground": make_enemy_ground(),
    "enemy_bat": make_enemy_bat(),
    "enemy_ghost": make_enemy_ghost(),
    "arrow": make_arrow(),
    "platform_tile": make_platform_tile(),
    "vine_anchor": make_vine_anchor(),
    "exit": make_exit(),
    "switch_off": make_switch_off(),
    "switch_on": make_switch_on(),
    "death_particles": make_death_particles(),
    "enemy_jumper": make_enemy_jumper(),
    "enemy_jumper_air": make_enemy_jumper_air(),
    "lava_tile": make_lava_tile(),
    "hud_dot": make_hud_dot(),
}

# Save individual sprites
import os
out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
os.makedirs(out_dir, exist_ok=True)

for name, img in sprites.items():
    img.save(os.path.join(out_dir, f"{name}.png"))

# Create preview sheet (scaled up 8x)
SCALE = 8
PADDING = 16
COLS = 4

items = list(sprites.items())
rows = (len(items) + COLS - 1) // COLS
max_w = max(img.width for img in sprites.values())
max_h = max(img.height for img in sprites.values())
cell_w = max_w * SCALE + PADDING * 2
cell_h = max_h * SCALE + PADDING * 2 + 20

sheet = Image.new("RGBA", (cell_w * COLS, cell_h * rows), (10, 10, 15, 255))
draw = ImageDraw.Draw(sheet)

for idx, (name, img) in enumerate(items):
    col = idx % COLS
    row = idx // COLS
    x = col * cell_w + PADDING
    y = row * cell_h + PADDING

    scaled = img.resize((img.width * SCALE, img.height * SCALE), Image.NEAREST)
    sheet.paste(scaled, (x, y), scaled)
    draw.text((x, y + max_h * SCALE + 4), name, fill=(180, 180, 180, 255))

preview_path = os.path.join(out_dir, "..", "sprite_preview.png")
sheet.save(preview_path)
print(f"Preview saved to {os.path.abspath(preview_path)}")
print(f"Sprites saved to {os.path.abspath(out_dir)}")
