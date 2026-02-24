# Project State — Game "3"

## 2026-02-23 — Gameplay Polish
- Vine swing: momentum-based (no L/R input), bezier rope bending, 0.15s grab immunity
- Arrow: L/R aim angle, room-spanning range, kills Area2D enemies
- Lava: 3-layer particle system (blobs, sparks, pops), random red/orange/yellow
- Switch: _draw()-based, 6x12px, flashes red/yellow → green on hit
- Bat enemy: oval patrol + flutter jitter, death burst particles
- Fixed invisible vine grab bug (VineDrop monitoring)
- Deleted room_02, single room focus

## 2026-02-22 — Core Systems
- Player: CharacterBody2D with jump, wall slide, vine grab, arrow shooting
- Vine: pendulum physics, rope rendering, grab/release with velocity transfer
- Room 01: platforms, stalactites, walls, lava floor, exit zone, switch + vine drop
- Ghost enemy: patrol + alert on arrow wall hit
- GameManager: room progression, death/respawn
- AudioManager: random variant playback (placeholder sounds)
- HUD + title screen
