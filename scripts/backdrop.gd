class_name Backdrop
extends Node2D

var camera: CameraRig
var theme := {
	"bg1": Color(0.03, 0.05, 0.09),
	"bg2": Color(0.075, 0.11, 0.18),
	"accent": Color(0.2, 0.55, 0.65),
}
var room_seed := 1
var time := 0.0
var view_size := Vector2(1280, 720)


func _ready() -> void:
	view_size = get_viewport_rect().size


func setup(theme_data: Dictionary, seed_value: int) -> void:
	if theme_data is Dictionary and not theme_data.is_empty():
		theme = theme_data
	room_seed = seed_value
	queue_redraw()


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _scroll() -> Vector2:
	if camera == null:
		return Vector2.ZERO
	return camera.get_screen_center_position() - view_size * 0.5


func _draw() -> void:
	view_size = get_viewport_rect().size
	var bg1: Color = theme.get("bg1", Color(0.03, 0.05, 0.09))
	var bg2: Color = theme.get("bg2", Color(0.075, 0.11, 0.18))
	var accent: Color = theme.get("accent", Color(0.2, 0.55, 0.65))
	var scroll := _scroll()

	# vertical gradient
	var bands := 10
	for i in range(bands):
		var t := float(i) / float(bands)
		var col := bg1.lerp(bg2, t)
		draw_rect(Rect2(0, view_size.y * t, view_size.x, view_size.y / bands + 2.0), col)

	# far caves
	_draw_cave_layer(scroll, 0.10, 0.58, bg1.lerp(Color(0.12, 0.18, 0.28), 0.35), room_seed + 1, 46.0)
	# stalactites far
	_draw_stalactites(scroll, 0.10, bg1.lerp(Color(0.1, 0.15, 0.24), 0.3), room_seed + 11, 90.0)

	# mid caves
	_draw_cave_layer(scroll, 0.26, 0.70, bg1.lerp(Color(0.16, 0.24, 0.35), 0.5), room_seed + 2, 60.0)
	# light shafts
	_draw_shafts(scroll, accent)
	# glow dots
	_draw_dots(scroll, accent)

	# near caves
	_draw_cave_layer(scroll, 0.48, 0.86, bg1.lerp(Color(0.09, 0.13, 0.2), 0.75), room_seed + 3, 48.0)

	# soft vignette at edges
	var edge := Color(0.0, 0.0, 0.02, 0.22)
	draw_rect(Rect2(0, 0, view_size.x, 70), edge)
	draw_rect(Rect2(0, view_size.y - 110, view_size.x, 110), Color(0.0, 0.0, 0.02, 0.28))


func _draw_cave_layer(scroll: Vector2, factor: float, base_ratio: float, col: Color, seed_value: int, amp: float) -> void:
	var off := Vector2(-scroll.x * factor, -scroll.y * factor * 0.25)
	var width := view_size.x + 400.0
	var base_y := view_size.y * base_ratio + off.y
	var pts := Utils.cave_silhouette(width + 400.0, base_y, amp, seed_value, 84.0)
	var shifted := PackedVector2Array()
	for p in pts:
		shifted.append(Vector2(p.x + off.x - 200.0, p.y))
	shifted.append(Vector2(view_size.x + 500.0, view_size.y + 100.0))
	shifted.append(Vector2(-500.0, view_size.y + 100.0))
	draw_colored_polygon(shifted, col)


func _draw_stalactites(scroll: Vector2, factor: float, col: Color, seed_value: int, amp: float) -> void:
	var off := Vector2(-scroll.x * factor, -scroll.y * factor * 0.18)
	var width := view_size.x + 400.0
	var pts := Utils.stalactite_row(width + 400.0, amp, seed_value, 96.0)
	var shifted := PackedVector2Array()
	shifted.append(Vector2(-500.0, -80.0))
	for p in pts:
		shifted.append(Vector2(p.x + off.x - 200.0, p.y + off.y))
	shifted.append(Vector2(view_size.x + 500.0, -80.0))
	draw_colored_polygon(shifted, col)


func _draw_shafts(scroll: Vector2, accent: Color) -> void:
	var ox := -fposmod(scroll.x * 0.06, 520.0)
	for i in range(4):
		var x := ox + i * 520.0 + 140.0
		var top := -60.0
		var bottom := view_size.y + 60.0
		var pts := PackedVector2Array([
			Vector2(x, top), Vector2(x + 90.0, top),
			Vector2(x + 240.0, bottom), Vector2(x + 60.0, bottom)
		])
		draw_colored_polygon(pts, Color(accent.r, accent.g, accent.b, 0.035))
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + 20.0, top), Vector2(x + 52.0, top),
			Vector2(x + 140.0, bottom), Vector2(x + 88.0, bottom)
		]), Color(accent.r, accent.g, accent.b, 0.028))


func _draw_dots(scroll: Vector2, accent: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = room_seed * 977 + 13
	for i in range(30):
		var base := Vector2(rng.randf_range(0.0, 1600.0), rng.randf_range(80.0, 640.0))
		var factor := rng.randf_range(0.1, 0.45)
		var p := Vector2(
			fposmod(base.x - scroll.x * factor, view_size.x + 80.0) - 40.0,
			fposmod(base.y - scroll.y * factor * 0.3, view_size.y)
		)
		var pulse := 0.4 + 0.6 * (0.5 + 0.5 * sin(time * 1.3 + i * 1.7))
		var r := 1.5 + 1.5 * pulse
		draw_circle(p, r, Color(accent.r, accent.g, accent.b, 0.18 + 0.35 * pulse))
