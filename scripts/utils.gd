class_name Utils
extends RefCounted

# Palette — see ASSETS.md art direction
const C_VOID := Color(0.027, 0.039, 0.071)
const C_BG := Color(0.043, 0.063, 0.11)
const C_ROCK := Color(0.078, 0.114, 0.18)
const C_ROCK2 := Color(0.106, 0.165, 0.251)
const C_SLATE := Color(0.173, 0.255, 0.376)
const C_RIM := Color(0.451, 0.769, 0.847)
const C_GLOW := Color(0.525, 0.89, 0.937)
const C_WARM := Color(1.0, 0.706, 0.361)
const C_IVORY := Color(0.91, 0.894, 0.839)
const C_TEXT := Color(0.835, 0.89, 0.918)
const C_TEXT_DIM := Color(0.56, 0.65, 0.706)
const C_GEO := Color(0.941, 0.839, 0.51)
const C_DANGER := Color(0.95, 0.42, 0.35)
const C_SOUL := Color(0.55, 0.9, 0.96)

# Physics layers (bitmask)
const L_WORLD := 1
const L_PLAYER := 2
const L_ENEMY := 4
const L_HAZARD := 8
const L_INTERACT := 16
const L_PLAYER_ATTACK := 32
const L_ENEMY_ATTACK := 64

static var _font: Font
static var _glow: Texture2D


static func font() -> Font:
	if _font == null:
		var f := SystemFont.new()
		f.font_names = PackedStringArray([
			"Microsoft YaHei UI", "Microsoft YaHei", "Noto Sans CJK SC",
			"Source Han Sans SC", "SimHei", "sans-serif"
		])
		f.font_weight = 500
		_font = f
	return _font


static func glow_texture() -> Texture2D:
	if _glow == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
		g.colors = PackedColorArray([
			Color(1, 1, 1, 1), Color(1, 1, 1, 0.32), Color(1, 1, 1, 0)
		])
		var t := GradientTexture2D.new()
		t.gradient = g
		t.width = 256
		t.height = 256
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		_glow = t
	return _glow


static func make_glow(parent: Node2D, pos: Vector2, radius: float, color: Color) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = glow_texture()
	s.position = pos
	s.scale = Vector2.ONE * (radius * 2.0 / 256.0)
	s.modulate = color
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	s.material = m
	s.z_index = -1
	parent.add_child(s)
	return s


static func ellipse_points(center: Vector2, rx: float, ry: float, segments := 24) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(segments):
		var a := TAU * float(i) / float(segments)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func ground_poly(rect: Rect2, seed_value: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var pts := PackedVector2Array()
	pts.append(rect.position + Vector2(0, rect.size.y))
	pts.append(rect.position)
	var x := 0.0
	while x < rect.size.x:
		x = minf(x + rng.randf_range(30.0, 78.0), rect.size.x)
		pts.append(rect.position + Vector2(x, rng.randf_range(-5.0, 4.0)))
	pts.append(rect.position + Vector2(rect.size.x, rect.size.y))
	return pts


static func slab_poly(rect: Rect2, seed_value: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var pts := PackedVector2Array()
	pts.append(rect.position + Vector2(0, rect.size.y))
	pts.append(rect.position)
	var x := 0.0
	while x < rect.size.x:
		x = minf(x + rng.randf_range(24.0, 56.0), rect.size.x)
		pts.append(rect.position + Vector2(x, rng.randf_range(-3.0, 3.0)))
	pts.append(rect.position + Vector2(rect.size.x, rect.size.y * 0.7))
	pts.append(rect.position + Vector2(rect.size.x * 0.9, rect.size.y))
	return pts


static func cave_silhouette(width: float, base_y: float, amp: float, seed_value: int, step := 90.0) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var pts := PackedVector2Array()
	var x := -200.0
	while x < width + 220.0:
		var y := base_y + sin(x * 0.0021 + seed_value * 1.7) * amp * 0.55 + rng.randf_range(-amp * 0.45, amp * 0.45)
		pts.append(Vector2(x, y))
		x += step
	return pts


static func stalactite_row(width: float, amp: float, seed_value: int, step := 120.0) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 91
	var pts := PackedVector2Array()
	var x := -120.0
	pts.append(Vector2(x, -20))
	while x < width + 160.0:
		x += step
		pts.append(Vector2(x, rng.randf_range(10.0, amp)))
		pts.append(Vector2(x + step * 0.42, rng.randf_range(2.0, amp * 0.35)))
	return pts
