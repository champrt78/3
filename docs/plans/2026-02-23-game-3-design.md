# "3" — Game Design Document

**Date:** 2026-02-23
**Status:** Approved
**Engine:** Godot (GDScript)

---

## Concept

A monochromatic, retro-styled single-screen platformer. Cross each room to reach the exit. You have **3**. Every floor touch and every arrow costs 1. Run out and touch the floor = death. Restart the room.

## Core Rules — Strike System

- **Strikes count UP from 0 to 3** — you start each room clean
- **Floor touch** — adds a strike
- **Arrow** — adds a strike. Hold to aim (trajectory arc), release to fire (gravity arc)
- **Vines/Ropes** — FREE to grab, but they **snap** after a short time
- **At 3 strikes** — can't shoot. Touch the floor = death.
- **Lava / pits** — instant death regardless of strikes
- **Enemy contact** = instant death
- **Death** = instant restart, same room, strikes reset to 0

## HUD — Traffic Light

Strikes display as dots stacking bottom to top, each keeping its own color:
- 1 strike: green dot (bottom)
- 2 strikes: green + yellow dot
- 3 strikes: green + yellow + red dot (full — next floor touch = dead)

## The Decision

Rooms present choices:

- 3 floor touches, no arrows — dodge everything, pure platforming
- 1 arrow + 2 touches — remove one obstacle
- 2 arrows + 1 touch — clear the path, nail that one landing
- Vine-only run if the room allows — save your whole pool

Every action costs the same, but they solve different problems.

## Player Movement

- **On the floor:** run left/right, jump
- **In the air:** gravity, momentum carries
- **On a vine:** pendulum swing, release to fling. Vine snaps after ~2-3 seconds.
- **Arrow:** aim and shoot from air or floor. Pool must be > 0.

## Room Elements

### Vines / Ropes
- Fixed anchor points
- Grab on contact, swing as pendulum
- **Snap** after short duration — visual/audio warning before break
- Free to use (the lifeline mechanic)

### Enemies (4 types)

All enemies: one-hit kill with arrow, touch = player death. Hazards, not combat targets.

| Enemy | Behavior |
|-------|----------|
| **Ground Crawler** | Slow patrol back and forth on a platform |
| **Ground Jumper** | Sits in one spot, jumps up and down, blocks vertical space |
| **Bat** | Hovers/bobs in a small area, blocking a zone |
| **Ghost** | Floats idle, then swoops downward in an arc. Telegraphed (flashes before swooping) so player can time around it |

### Lava / Pits
- Instant death on contact, regardless of strike count
- Lava fills the bottom of most rooms — the floor IS the danger
- Forces vine swinging as the primary traversal method

### Switches
- Arrow-activated
- Move platforms, open doors, extend bridges, retract spikes
- Some timed (activate then revert)

### Colored Rooms (Progressive Difficulty)

| Color | Modifier | Effect |
|-------|----------|--------|
| White | None | Base gameplay |
| Blue | Ice | Slippery floor, momentum carries |
| Green | Wind | Constant horizontal push |
| Red | Heat | Vines snap faster |
| Purple | Dark | Limited visibility |

## Aesthetic

- Monochromatic — single accent color per room type, dark background
- Retro minimal — Downwell, LOVE, Intellivision inspired
- Small pixel art or geometric shapes
- Screen shake, particles for juice (death, snap, arrow hit)
- Simple chiptune or minimal audio

## Room Design Principles

- Every room fits on one screen, no scrolling
- **Fixed start position: bottom-left ledge. Fixed exit: upper-right ledge. Always.**
- Player immediately knows the goal — the challenge is the path between
- "Star Wars Death Star chasm" feel — small ledges, big void, vines across
- Lava/pit fills the bottom of most rooms
- Entire puzzle visible before moving
- Difficulty from layout and placement, not strike count
- Multiple solutions emerge from the shared pool
- **Progression**: early rooms have generous ledges, later rooms shrink platforms to slivers

## Progression

- Linear room sequence
- Difficulty ramps through:
  - More enemies / switches per room
  - Tighter vine placement
  - Shorter vine snap timers
  - Colored room modifiers
  - Rooms requiring all 3 spent perfectly

## Technical Notes (Godot)

- Each room = a Godot Scene
- Player = CharacterBody2D (Godot 4)
- Vines = Area2D with pendulum logic + snap timer
- Enemies = path-following nodes
- Switches = Area2D triggers linked to platform AnimationPlayers
- Pool = single integer, UI shows 3 dots/icons that disappear
- Room transition = load next scene on exit trigger

## UI

- **In-game:** pool counter (3 dots that dim/disappear). Minimal.
- **Death:** instant restart, no menu
- **Room clear:** brief flash, next room loads immediately
- **Pause:** resume, restart room, quit

## Future Ideas (Not v1)

- Loadout screen: pick how to split your 3 before a room
- Arrow-created rope anchors (shoot wall, vine appears)
- **Orb enemies** — special glowing enemies that drop an orb when shot. Catch the orb mid-air to recover a strike. Risk/reward: spend a strike (arrow) to potentially gain one back, but miss the catch and you wasted it. Skilled players can chain orb catches to stretch their 3.
- Boss rooms
- Speedrun timer / par times
- Room editor / level sharing
- "3 of each" alternate mode (3 touches + 3 arrows + 3 vines)

---

## v1 Scope

Build this and nothing more:

1. Player movement (run, jump, gravity, momentum)
2. Shared pool of 3 (floor touch -1, arrow -1, can't shoot at 0)
3. Vines with swing + snap
4. Enemies (patrol, die to arrow, kill player on touch)
5. Switches (arrow-activated, move platforms)
6. 10-20 hand-designed rooms, white/default color
7. Death = instant restart
8. Simple monochromatic art
9. Basic sound effects
