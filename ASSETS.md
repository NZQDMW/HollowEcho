# Assets

**Art direction:** Hand-drawn-inspired minimalist silhouette art for a ruined subterranean kingdom. Side-view 2D. Palette: void black-blue `#070a12`, deep cave `#101827`, rock `#1b2a40`, slate `#2c4160`, pale cyan rim light `#73c4d8`, bioluminescent glow `#86e3ef`, warm lantern `#ffb45c`, ivory mask `#e8e4d6`. Crisp vector silhouettes, jagged rock edges with a thin rim-light line, layered parallax caves, hanging vines, soft additive glow, drifting dust motes, light shafts. One small ivory-masked knight with horns and a slate cloak against vast dark spaces. Mood: quiet, melancholy, mysterious.

## Production Note

No image-generation API/key is available on this machine (Gemini/xAI/Tripo keys absent), so every visual is **drawn procedurally at runtime in GDScript** (`_draw`, `Polygon2D`, gradient textures, particles). `reference.png` is a hand-authored PIL mock used as the visual target and QA anchor.

## Runtime "assets" (procedural)

| Name | Type | Size | Notes |
|------|------|------|-------|
| knight | vector character | ~120 px tall | ivory dual-horn mask, black body, slate cloak, silver nail; run/jump/fall/dash/wall-cling/attack/pogo/focus/hurt states; horizontal flip |
| crawler | vector enemy | ~100x50 px | beetle, orange glowing eyes, patrols platforms |
| flyer | vector enemy | ~80x60 px | moth-like, bobbing chase flight |
| husk | vector enemy | ~140 px tall | tall husk guard, club lunge |
| spitter | vector enemy | ~95x70 px | acid sac pulsing green, funnel mouth, telegraph arc |
| hopper | vector enemy | ~90x60 px | crouched flea, glowing ridge, leap toward player |
| acid bolt | procedural projectile | ~30 px | wobbling green blob with dripping trail |
| merchant 灰烬商人·墨 | vector NPC | ~150 px tall | wide hat, back pack, staff lantern, warm eyes |
| lorekeeper 记录者·铃 | vector NPC | ~120 px tall | seated on a ledge, open glowing book, small bell |
| boss 残破守卫 | vector boss | ~260 px tall | armored husk with mace; slam/charge/rage phases |
| boss 钟鸣守卫 | vector boss | ~260 px tall | same rig, bell-cave palette; optional reward boss |
| Path of Pain palette | procedural | per room | whiter carved stone, ivory rim, warm-gold saw glow; kept within the existing palette |
| bell prop | procedural | ~120 px | suspended bronze bell with warm halo |
| market stall | procedural | ~150 px | striped canopy, counter with glowing goods |
| crate / pillar | procedural props | ~80 px / ~210 px | stacked boxes; broken fluted column |
| shade | vector ghost | ~110 px tall | black echo of the knight, white eyes, holds lost geo |
| moving platform | procedural slab | 140–160×24 px | pale stone slab, ivory rim light, pulsing runes; rides a sine path |
| touch HUD | Control drawing | 1280×720 reference | translucent joystick base/knob, 6 action buttons + map/pause, Chinese labels, portrait rotate overlay |
| crumble platform | procedural slab | 140×22 px | same slab; shakes, red fracture lines, collapses, faint re-form outline |
| sawblade | procedural hazard | r≈24–28 px | dark toothed wheel, warm bronze core, motion shimmer, orange glow |
| special items | procedural icons | 48–64 px | 轻羽斗篷 (feather strokes), 守梦者之灯 (warm lantern), 苦痛之心 (red crystal heart), each with an ivory ring + label |
| HUD charm slots | Control drawing | 3×40 px | three outlined slots under the soul orb; filled icon per owned special item |
| terrain | procedural | per room | dark rock polygons, cyan rim light, cracks, moss tufts, hanging vines |
| backdrop | procedural | 3 layers | far/mid/near cave silhouettes, light shafts, glow dots, parallax |
| lantern | procedural | ~90 px | warm additive glow + post |
| bench | procedural | ~140 px | stone bench with pale glow |
| relic pickups | procedural icons | 48-64 px | dash cloak / wall claw / double-jump wings / mask shard |
| geo | procedural | 18 px | golden shard with glow |
| HUD | Control drawing | 1280x720 | masks, soul orb, geo counter, room banner, boss bar, prompts |
| font (bundled) | Noto Sans SC Medium subset | 592 glyphs, ~210 KB | `assets/fonts/NotoSansSC-Medium-Subset.ttf`, SIL OFL (license in `assets/fonts/OFL.txt`); used first by `Utils.font()` so Chinese renders in the web export; regenerate with fontTools when adding new Chinese text |
| font (fallback) | SystemFont | - | Microsoft YaHei / Noto Sans CJK SC fallback if the bundled font is missing |
