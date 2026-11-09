# Game Plan: 空谷回响 HollowEcho

## Goal

A playable 2D side-scrolling Metroidvania in Godot 4.7 (GDScript) following Hollow Knight's design: nail combat, soul healing/spells, ability-gated exploration, benches, shade death recovery, a boss, and a hand-drawn-inspired dark cave world.

## Risk Tasks

### 1. Player Controller & Procedural Character Animation
- **Why isolated:** platformer feel plus a fully procedural drawn character has many state transitions (idle/run/jump/fall/dash/wall-slide/wall-jump/double-jump/attack-up/side/down/pogo/focus/hurt/death). Wrong frames, popping poses, or direction mismatches are the classic failure.
- **Approach:** `CharacterBody2D` with accel/decel, variable jump, coyote time, jump buffering, dash with cooldown and afterimages, wall slide/jump, double jump. A single `PlayerVisual` Node2D draws the knight from state parameters (run phase, velocity, cloak sway, nail arc). Horizontal flip via `scale.x`. Attack hitboxes are Area2D rectangles enabled during active frames; down-attack on enemy sets upward pogo velocity.
- **Verify:** scripted input capture shows idle→run→jump→fall→land→dash→wall slide→wall jump→double jump→side/up/down attack→pogo→focus; direction matches movement; no pose snapping at transitions; hitboxes only active during swings.

### 2. Room World, Camera & Ability Gates
- **Why isolated:** runtime-built rooms, door transitions, camera clamping/smoothing and relic gates interact; failures produce wrong spawns, camera drift, or softlocks.
- **Approach:** data-driven rooms (`room_data.gd`) built by `Room` (static bodies, visuals, entities). `World` swaps rooms, positions the player at the target door, sets camera limits to room bounds with smoothing and look-ahead. Doors/gates check `Game.relics`; locked gates show a barrier and a hint. Bench respawn data recorded in `Game`.
- **Verify:** walking through each door lands the player at the paired door inside the next room; camera never shows outside room bounds; gate blocks movement and shows hint without the relic, opens after pickup; respawn returns to bench room.

## Main Build

- **Systems:** soul meter (nail hits fill, heal 33, spell 33), 5-mask health with i-frames, geo drops/pickup, mask shard, dash/wall-cling/double-jump relics, bench save/heal, shade death+recovery, spell projectile, crawler/flyer/husk enemies, boss with phases and boss bar, room name banners, HUD, map screen (Tab), pause, title and ending screens, hit shake, glow/dust/particles, Chinese UI via SystemFont.
- **Rooms:** R1 遗忘十字路 (bench, tutorial) → R2 苔藓甬道 (hub) → R3 沉眠圣所 (dash relic) / R4 回响深井 (mask shard, dash gap) → R5 石壁回廊 (wall-cling relic, vertical) → R6 王座前厅 (double-jump relic, bench) → R7 破碎王座 (boss, ending).
- **Verify:**
  - Movement direction and character facing agree; attacks aim with W/S; soul increases on hit; heal costs soul and restores a mask; spell damages enemies.
  - Enemies patrol/chase/telegraph and deal contact damage with i-frames; geo pickups increment counter.
  - Dash/wall/double jump gates block before relics and work after; boss arena locks, phases change at 50%, victory triggers ending.
  - HUD readable, no overlap or overflow; Chinese glyphs render; no missing visuals.
  - reference.png consistency: dark indigo palette, cyan rim light, ivory mask knight, layered caves, HUD top-left masks + soul, top-right geo.
  - **Presentation proof bundle:** `screenshots/result/1/video.mp4` (30 fps, ≥15 s) + raw `frameXXX.png` sequence showing movement, combat, relic pickup, gate crossing, boss.

## Notes

- No audio (pipeline does not ship audio).
- No image generation available: all art procedural, documented in ASSETS.md.

## Status (2026-11-09)

- Risk task 1 (player controller + procedural animation): **complete**. Verified via scripted captures: run, jump, fall, dash (afterimage), wall slide/jump, double jump, side/up/down nail, pogo bounce, focus heal, hurt flash, facing flip.
- Risk task 2 (rooms, camera, ability gates): **complete**. Door transitions land at paired doors, camera clamps to room bounds, dash gap requires the dash relic, wall gate opens after the wall relic, bench respawn works.
- Main build: **complete** — 7 rooms, 3 enemy types, boss with 2 phases + arena gates, soul/heal/spell, mask shard, geo, death shade recovery, HUD/map/pause/title/ending.
- Automated checks: `test/test_systems.gd` all ASSERTs pass; `test/test_ui.gd` map/pause asserts pass; no script errors in `godot --headless --quit`.
- Presentation proof bundle: `screenshots/result/1/video.mp4` (30 s at 30 fps, 1280×720) + 900 raw `frame*.png` frames.
- Deliberately out of scope: audio, charms/notches, vendor/map purchase, NPC dialogue, save-to-disk.
