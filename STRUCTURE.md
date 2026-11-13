# HollowEcho（空谷回响）

## Dimension: 2D

Engine: Godot 4.7.2 (GL Compatibility), GDScript. No C# / .NET (Steam build is standard, no SDK).

## Input Actions

| Action | Keys |
|--------|------|
| move_left | A, Left |
| move_right | D, Right |
| aim_up | W, Up |
| aim_down | S, Down |
| jump | Space |
| attack | J, Z |
| dash | K, X |
| spell | L, C |
| focus | F |
| interact | E |
| map | Tab |
| pause | Escape |
| restart | R |

## Scenes

### Main
- **File:** res://scenes/main.tscn
- **Root type:** Node2D (script `game_root.gd`)
- **Runtime children:** World (draws room, entities), Camera2D, HUD (CanvasLayer, layer 10), Fade (CanvasLayer, layer 20), Pause/Map (HUD child)

Entities, rooms and UI are constructed at runtime from code. No per-entity .tscn files.

## Scripts

| File | Role |
|------|------|
| scripts/game.gd | Autoload `Game`: masks, soul, geo, relics, special items, bench, shade, visited rooms, signals |
| scripts/game_root.gd | Root orchestration: title, play, death, ending, pause, room transitions, fade |
| scripts/world.gd | Loads/frees rooms, spawns player, camera bounds, door handling |
| scripts/room_data.gd | Static room definitions (platforms, moving/crumble platforms, saws, doors, enemies, pickups, props) |
| scripts/room.gd | Builds a room from data: collision, drawn terrain, entities, dust |
| scripts/player.gd | CharacterBody2D controller, health, soul, attack, abilities, special-item modifiers |
| scripts/player_visual.gd | Procedural knight drawing + afterimages + focus aura |
| scripts/enemy.gd | Enemy base: hp, hit flash, contact damage, death drops, fall-out recovery |
| scripts/crawler.gd / flyer.gd / husk.gd | Enemy behaviors |
| scripts/spitter.gd | Ranged acid spitter: patrol, telegraph, aimed acid projectile |
| scripts/hopper.gd | Leaping enemy: crouch → leap toward the player |
| scripts/moving_platform.gd | AnimatableBody2D moving slab (sine path); carries the player |
| scripts/crumble_platform.gd | Crumbling slab: shakes, collapses, re-forms |
| scripts/sawblade.gd | Rotating/patrolling saw hazard for the Path of Pain |
| scripts/npc.gd | Area2D NPC: prompt, procedural merchant/lorekeeper drawing, opens dialogue/shop |
| scripts/npc_data.gd | Static NPC definitions: merchant catalogue + lorekeeper pages |
| scripts/boss.gd | Boss state machine, phases, shockwaves, defeat; configurable name/hp/final |
| scripts/shade.gd | Death shade that holds lost geo |
| scripts/pickup.gd | Geo, relic, mask shard, special-item pickups |
| scripts/bench.gd | Checkpoint/rest (heal, save) |
| scripts/gate.gd | Relic/key-gated barrier |
| scripts/sign.gd | Readable tutorial message |
| scripts/projectile.gd | Vengeful-spirit bolt and boss shockwave |
| scripts/hud.gd | Masks/soul/geo, banners, toasts, boss bar, title/end/death overlays, map, pause |
| scripts/backdrop.gd | Parallax cave silhouettes, light shafts, glow dust |
| scripts/effects.gd | Hit sparks, slash FX, screen shake, hitstop |
| scripts/utils.gd | Palette, glow texture, jagged shapes, fonts, drawing helpers |
| test/presentation.gd | SceneTree capture driver for the base proof bundle (900 frames / 30 s) |
| test/presentation_content.tscn / presentation_content_node.gd | Scene-driven content demo (market, shop, new area, optional boss) |
| test/capture_moment.tscn / capture_moment.gd | Deterministic per-moment screenshots via `--moment=<name>` |
| test/smoke.gd | Basic movement/room-transition smoke test |
| test/test_systems.gd | Relics, bench, death/shade, boss/ending assertions |
| test/test_content.gd | Shop, key gate, new rooms, mask shard, optional boss assertions |
| test/test_extra.gd | 14-room door reciprocity, 王座密道/苦痛之路/王座之心, special items, map coverage |
| test/test_pain.gd | Moving-platform carry (horizontal / vertical) |
| test/test_focus.gd | Focus heal / spell assertions |
| test/test_ui.gd | Map / pause assertions |

## Debug Hooks

- `GameRoot.debug_start()`, `debug_goto(room, pos)`, `debug_cut(room, pos)` (fade + teleport), `player.debug_invincible`.
- SceneTree test scripts must not reference the `Game` autoload or global classes whose scripts depend on it at compile time (see MEMORY.md); use `root.get_node("Game")` and `get_script() == load(path)` checks.

## Runtime Details

- Ledges use one-way collision shapes; ground/walls are solid.
- Pickups persist collected state via `Game.taken_pickups` keyed by `room:x:y`; relics are skipped when already owned.
- Room data may declare `npcs` (ids resolved through `NpcData`), `props` (stall/crate/bell/pillar, drawn by `Room`), `platforms` (sine-moving AnimatableBody2D slabs), `crumble` (crumbling slabs), `saws` (rotating hazards), `specials` (special-item pickups) and a `boss` config dict (`id`, `name`, `hp`, `final`, optional `phase2_text`).
- Special items live in `Game.special_items`; `Game.gain_item()` applies their passive effect (dash cooldown, focus speed, nail/soul bonus) and the HUD draws three charm slots.
- NPC interaction pauses the tree; `GameRoot` polls W/S/E/Esc while the HUD draws the dialogue/shop panel. Purchases go through `Game.purchase(item)` and are recorded in `Game.shop_purchases`.
- Optional bosses write their id to `Game.bosses_defeated`; `Room._build_boss` skips an already-defeated boss when the room reloads. The final boss alone calls `Game.trigger_ending()`.
- All visuals are drawn with `_draw`/Polygon2D/gradient textures; CJK text uses SystemFont.

## Signals

- Game: `masks_changed`, `soul_changed`, `geo_changed`, `relic_gained`, `room_changed`, `toast`, `boss_state`, `shade_changed`, `prompt_changed`, `dialogue_requested`, `ending`.
- Player: `died`, `health_changed`, `soul_gained`, `attack_hit`.
- World: `room_loaded(room_id)`, `transition_requested(target_room, door_index)`.
- Boss: `defeated`, `health_changed(hp, max)`, `arena_locked`.
- Pickup: `collected`.

## Physics Layers (bitmask)

1 world, 2 player, 4 enemy, 8 hazard, 16 interact, 32 player_attack, 64 enemy_attack.

## Build / Run

- Import: `godot --headless --path . --import`
- Validate: `godot --headless --path . --quit`
- Tests: `godot --headless --path . --fixed-fps 30 --script res://test/test_extra.gd`（同样适用于 test_systems / test_content / test_focus / test_ui / test_pit / test_pain）
- Run: `godot --path .`
- Capture (scene-driven): `godot --path . --write-movie screenshots/x/frame.png --fixed-fps 30 --quit-after N res://test/presentation_content.tscn`
- Moment shots: `godot --path . --write-movie screenshots/moments/<name>/frame.png --fixed-fps 30 --quit-after 200 res://test/capture_moment.tscn -- --moment=<name>`

## Asset Hints

All visuals procedural (see ASSETS.md). SystemFont for CJK text. No image files.
