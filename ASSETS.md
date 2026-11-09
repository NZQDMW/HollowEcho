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
| boss 残破守卫 | vector boss | ~260 px tall | armored husk with mace; slam/charge/rage phases |
| shade | vector ghost | ~110 px tall | black echo of the knight, white eyes, holds lost geo |
| terrain | procedural | per room | dark rock polygons, cyan rim light, cracks, moss tufts, hanging vines |
| backdrop | procedural | 3 layers | far/mid/near cave silhouettes, light shafts, glow dots, parallax |
| lantern | procedural | ~90 px | warm additive glow + post |
| bench | procedural | ~140 px | stone bench with pale glow |
| relic pickups | procedural icons | 48-64 px | dash cloak / wall claw / double-jump wings / mask shard |
| geo | procedural | 18 px | golden shard with glow |
| HUD | Control drawing | 1280x720 | masks, soul orb, geo counter, room banner, boss bar, prompts |
| font | SystemFont | - | Microsoft YaHei / Noto Sans CJK SC fallback for Chinese |
