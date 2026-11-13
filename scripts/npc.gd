extends Area2D

var npc_id: StringName = &""
var npc_name := ""
var style := "merchant"
var prompt := "E  交谈"
var pages: Array = []
var shop_items: Array = []
var shop_intro := ""
var time := 0.0
var in_range := false


func setup(pos: Vector2, data: Dictionary) -> void:
	position = pos
	npc_id = data.get("id", &"")
	npc_name = data.get("name", "")
	style = data.get("style", "merchant")
	prompt = data.get("prompt", "E  交谈")
	pages = data.get("pages", [])
	shop_items = data.get("shop", [])
	shop_intro = data.get("shop_intro", "看看有什么需要的。")


func _ready() -> void:
	collision_layer = Utils.L_INTERACT
	collision_mask = Utils.L_PLAYER
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(190, 150)
	cs.shape = shape
	cs.position = Vector2(0, -75)
	add_child(cs)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	z_index = 2
	Utils.make_glow(self, Vector2(0, -96), 84.0, Color(Utils.C_WARM, 0.16))


func _process(delta: float) -> void:
	time += delta
	queue_redraw()
	if in_range and Game.dialogue_cooldown <= 0.0 and Input.is_action_just_pressed("interact"):
		Game.dialogue_requested.emit(self)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		in_range = true
		var shown := prompt
		if Game.touch_mode and shown.begins_with("E  "):
			shown = "%s  %s" % [Game.interact_label(), shown.substr(3)]
		Game.prompt_changed.emit(shown)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		in_range = false
		Game.prompt_changed.emit("")


func _draw() -> void:
	var bob := sin(time * 1.8) * 2.0
	if style == "lorekeeper":
		_draw_lorekeeper(bob)
	else:
		_draw_merchant(bob)


func _draw_merchant(bob: float) -> void:
	var base := Vector2(0, bob)
	var cloak := Color(0.16, 0.2, 0.27)
	var cloak_dark := Color(0.08, 0.1, 0.14)
	var trim := Color(Utils.C_WARM, 0.5)

	# staff and lantern
	draw_line(base + Vector2(46, -118), base + Vector2(52, 0), Color(0.24, 0.2, 0.16), 4.0)
	var lamp := base + Vector2(52, -96)
	draw_line(lamp, lamp + Vector2(0, 12), Color(0.2, 0.18, 0.14), 2.0)
	draw_colored_polygon(PackedVector2Array([
		lamp + Vector2(-8, 14), lamp + Vector2(8, 14), lamp + Vector2(5, 30), lamp + Vector2(-5, 30)
	]), Color(1.0, 0.72, 0.38, 0.9))
	draw_circle(lamp + Vector2(0, 22), 13.0, Color(1.0, 0.68, 0.32, 0.12))

	# back pack
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-40, -74), base + Vector2(-62, -60), base + Vector2(-66, -14),
		base + Vector2(-46, -6), base + Vector2(-30, -20)
	]), Color(0.19, 0.16, 0.14))
	draw_line(base + Vector2(-58, -58), base + Vector2(-60, -18), Color(0.09, 0.08, 0.07), 2.0)

	# legs
	draw_line(base + Vector2(-14, -26), base + Vector2(-18, 0), cloak_dark, 8.0)
	draw_line(base + Vector2(14, -26), base + Vector2(18, 0), cloak_dark, 8.0)

	# body cloak
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-30, -104), base + Vector2(-24, -30), base + Vector2(-36, -4),
		base + Vector2(30, -4), base + Vector2(24, -32), base + Vector2(32, -104)
	]), cloak)
	draw_line(base + Vector2(-27, -98), base + Vector2(-32, -10), Color(Utils.C_RIM, 0.28), 2.0)
	draw_line(base + Vector2(-26, -82), base + Vector2(26, -82), trim, 3.0)

	# arms
	draw_line(base + Vector2(-24, -88), base + Vector2(-4, -58), cloak_dark, 7.0)
	draw_line(base + Vector2(24, -88), base + Vector2(40, -66), cloak_dark, 7.0)

	# head, mask, wide hat
	var head := base + Vector2(0, -118)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(0, 14), head + Vector2(-13, 4), head + Vector2(-11, -8),
		head + Vector2(0, -14), head + Vector2(11, -8), head + Vector2(13, 4)
	]), Color(0.62, 0.58, 0.5))
	draw_circle(head + Vector2(-5, 0), 2.4, Color(Utils.C_WARM, 0.9))
	draw_circle(head + Vector2(5, 0), 2.4, Color(Utils.C_WARM, 0.9))
	draw_colored_polygon(Utils.ellipse_points(head + Vector2(0, -14), 40, 10, 20), cloak_dark)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(-16, -16), head + Vector2(16, -16),
		head + Vector2(10, -36), head + Vector2(-10, -36)
	]), cloak)
	draw_line(head + Vector2(-16, -16), head + Vector2(16, -16), trim, 2.0)


func _draw_lorekeeper(bob: float) -> void:
	var base := Vector2(0, bob)
	var robe := Color(0.15, 0.19, 0.26)
	var dark := Color(0.07, 0.09, 0.13)

	# stone desk
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-52, -30), base + Vector2(52, -30),
		base + Vector2(46, 0), base + Vector2(-46, 0)
	]), Color(0.15, 0.18, 0.24))
	draw_line(base + Vector2(-52, -30), base + Vector2(52, -30), Color(Utils.C_RIM, 0.4), 2.0)

	# seated body
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-26, -86), base + Vector2(-40, -34),
		base + Vector2(40, -34), base + Vector2(26, -86)
	]), robe)
	draw_line(base + Vector2(-20, -68), base + Vector2(-12, -44), dark, 7.0)
	draw_line(base + Vector2(20, -68), base + Vector2(12, -44), dark, 7.0)

	# head and small bell
	var head := base + Vector2(0, -104)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(0, 16), head + Vector2(-14, 6), head + Vector2(-13, -8),
		head + Vector2(0, -16), head + Vector2(13, -8), head + Vector2(14, 6)
	]), Color(0.8, 0.78, 0.7))
	draw_line(head + Vector2(-10, -14), head + Vector2(-16, -34), dark, 2.0)
	draw_circle(head + Vector2(-16, -36), 4.0, Color(0.85, 0.7, 0.35, 0.9))
	draw_circle(head + Vector2(-5, 0), 2.2, Color(Utils.C_GLOW, 0.85))
	draw_circle(head + Vector2(5, 0), 2.2, Color(Utils.C_GLOW, 0.85))

	# open book on the desk
	var book := base + Vector2(0, -42)
	draw_colored_polygon(PackedVector2Array([
		book + Vector2(-26, 8), book + Vector2(0, 0), book + Vector2(26, 8),
		book + Vector2(26, 14), book + Vector2(0, 6), book + Vector2(-26, 14)
	]), Color(0.4, 0.32, 0.22))
	draw_line(book + Vector2(0, 0), book + Vector2(0, 6), Color(0.2, 0.16, 0.12), 2.0)
	var pulse := 0.5 + 0.5 * sin(time * 2.0)
	for i in range(3):
		draw_line(
			book + Vector2(-18, 10 + i * 1.5),
			book + Vector2(-5, 6 + i * 1.5),
			Color(Utils.C_GLOW, 0.25 + 0.2 * pulse), 1.2
		)
	for i in range(3):
		draw_line(
			book + Vector2(18, 10 + i * 1.5),
			book + Vector2(5, 6 + i * 1.5),
			Color(Utils.C_GLOW, 0.25 + 0.2 * pulse), 1.2
		)
