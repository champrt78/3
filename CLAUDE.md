# Game "3" — Godot 4.4 Platformer

## Architecture
- GDScript with warnings-as-errors, Godot 4.4
- 640x480 viewport, 1-bit pixel art at 3x scale
- Autoloads: GameManager, AudioManager
- Physics layers: 1=player, 2=world, 3=enemies, 4=vines, 5=exit

## Key Patterns
- All sprites: `texture_filter = 0`, `scale = Vector2(3, 3)` (or 2 for small enemies)
- Platform tile is 8x8 native, 24x24 at 3x scale
- Never set `global_position` directly on CharacterBody2D — use velocity + `move_and_slide()`
- Area2D `visible = false` does NOT disable monitoring — must set `monitoring = false` separately
- For Area2D-to-Area2D detection, collision_layer/mask must overlap on at least one side
- Vine grab immunity: 0.15s after release (shorter blocks vine-to-vine, longer causes re-grab)

## Sound Effects
- All sounds in `assets/sounds/final/` as .wav files
- AudioManager.play("sound_name") picks random variant from mapped arrays
- Sound files need replacement — current ones are placeholder quality

## Scene Editing (.tscn)
- Update `load_steps` count when adding ext_resources
- Get texture UIDs from `.import` files (e.g., `uid="uid://xxx"`)
- Godot may not reload externally edited scripts — user may need to restart editor

## Session Documentation (Auto — do not skip)
At the end of every session (before final commit), automatically:
1. **Session log**: Create/update `docs/sessions/YYYY-MM-DD.md` with summary, changes, files modified
2. **Project state**: Append a dated entry to `docs/project-state.md` with milestone-level summary
3. Commit these docs with the session's final push
