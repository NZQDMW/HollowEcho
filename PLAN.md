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

## Content Update (2026-11-13)

- Added 3 rooms: r8 静默集市 (safe hub, bench, merchant, lorekeeper, stalls), r9 钟鸣洞窟 (acid spitters, hopper, mask shard, pit), r10 回响之厅 (optional boss 钟鸣守卫, 48 HP, 2 phases).
- Added a geo economy: merchant sells 面具碎片 ×2 (40), 灵魂容器 (70), 骨钉磨石 (90), 锈蚀钥匙 (40). Purchases persist for the run in `Game.shop_purchases`.
- Added key-gated optional branch: r3 → r8 → (锈蚀钥匙) → r9 → r10.
- Added NPC dialogue/shop UI (pauses the tree; GameRoot polls W/S/E/Esc; HUD draws the panel with purchase feedback).
- Added two enemy types: 吐酸者 (aimed acid projectile) and 跃虫 (leaping chase), plus a new acid projectile kind.
- Parameterized the boss (id/name/hp/final/phase2 text); optional boss is skipped after defeat and rewards 回响之心 (mask +1, nail +1, soul cap +33). Ending line changes if the bell boss was defeated.
- Map screen now shows 10 rooms with legend and explored counter.
- Tests: `test/test_content.gd` covers shop purchase/limit, key gate unlock, new rooms/enemies, mask shard, optional boss reward and non-respawn. All existing tests still pass.
- Screenshot proof: `screenshots/result/content/shot_*.png` (8 moments) via `test/capture_moment.tscn`.
- Note: `--write-movie` + `--script` produces transparent frames on this Godot build; scene-driven capture is the working path.

## Content Update 2 (2026-11-13): 苦痛之路

- Added 4 rooms: r11 王座密道 (secret passage; charm pickup, 2 enemies), r12 苦痛之路·回廊 (horizontal gauntlet, 5 moving platforms, 2 crumbling slabs, 4 saws, 4 checkpoint pits), r13 苦痛之路·深井 (vertical wall-jump shaft, 2 moving platforms, 3 saws), r14 王座之心 (reward chamber with bench).
- r6 王座前厅 gained a high ledge, a secret up-door to r11, and a hint sign; the lorekeeper has an extra page pointing at the rift.
- Added a light special-item (charm) system: 轻羽斗篷 (dash cooldown −50%), 守梦者之灯 (soul cap +33, faster focus; sold by the merchant for 120 geo), 苦痛之心 (nail +2, soul on hit +5; Path of Pain reward). HUD draws three charm slots and the ending gains an extra line when 苦痛之心 is owned.
- New mechanics: sine-moving AnimatableBody2D platforms that carry the player, crumbling slabs (0.6 s shake → collapse → 2.8 s re-form), rotating sawblades with sinusoidal patrols. New room-data keys: `platforms`, `crumble`, `saws`, `specials`.
- Map expanded to 14 rooms in three rows; long labels auto-shrink.
- Tests: `test/test_extra.gd` (door reciprocity across all 14 rooms, room contents, special-item effects/persistence, lantern purchase, map coverage) and `test/test_pain.gd` (moving platform carries the player horizontally and vertically). All existing tests still pass with `--fixed-fps 30`.
- Screenshot proof: `screenshots/moments/{passage,feather,pain,pain_mid,pain_deep,heart,charms,map_all}/` via `test/capture_moment.tscn`.

## Mobile & Web Update (2026-11-13)

- Added `scripts/touch_controls.gd`: virtual joystick (left, analog move + aim up/down) and action buttons (right: 跳/打/冲/法/聚/互), plus map/pause buttons at top-right. Multi-touch; tap buttons auto-release, hold buttons support jump height and focus; releases all on focus loss.
- Touch UI shows automatically on touch devices (`DisplayServer.is_touchscreen_available()` / mobile OS) and hides on desktop. `Game.touch_mode` switches title, pause, dialogue, shop, map and interact-prompt text to touch hints; a portrait overlay asks the player to rotate.
- `project.godot`: landscape handheld orientation, `pointing/emulate_touch_from_mouse=true`, Web renderer override gl_compatibility.
- Bundled a 592-glyph Noto Sans SC subset (`assets/fonts/NotoSansSC-Medium-Subset.ttf`, SIL OFL) because Godot's `SystemFont` renders CJK as tofu in the web export; `Utils.font()` now prefers the bundled font.
- Added `export_presets.cfg` (Web, non-threaded WASM) and exported `docs/` for GitHub Pages.
- Published the code and web build to `NZQDMW/HollowEcho`; Pages URL: `https://nzqdmw.github.io/HollowEcho/`.
- Tests: `test/test_touch.gd` (joystick, aiming, auto-release, pause/map). All existing tests pass.

## Notes

- No audio (pipeline does not ship audio).
- No image generation available: all art procedural, documented in ASSETS.md.

## Status (2026-11-09)

- Risk task 1 (player controller + procedural animation): **complete**. Verified via scripted captures: run, jump, fall, dash (afterimage), wall slide/jump, double jump, side/up/down nail, pogo bounce, focus heal, hurt flash, facing flip.
- Risk task 2 (rooms, camera, ability gates): **complete**. Door transitions land at paired doors, camera clamps to room bounds, dash gap requires the dash relic, wall gate opens after the wall relic, bench respawn works.
- Main build: **complete** — 14 rooms, 3 enemy types + 2 extra, boss with 2 phases + arena gates, soul/heal/spell, mask shard, geo, death shade recovery, HUD/map/pause/title/ending, 3 special items and the Path of Pain hidden branch.
- Automated checks: `test/test_systems.gd`, `test/test_content.gd`, `test/test_extra.gd`, `test/test_pain.gd`, `test/test_focus.gd`, `test/test_ui.gd`, `test/test_pit.gd` all ASSERTs pass with `--fixed-fps 30`; no script errors in `godot --headless --quit`.
- Presentation proof bundle: `screenshots/result/1/video.mp4` (30 s at 30 fps, 1280×720) + 900 raw `frame*.png` frames; new-area moments in `screenshots/moments/`.
- Deliberately out of scope: audio, full charm/notch system, vendor/map purchase, save-to-disk.
