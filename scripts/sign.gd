extends Area2D

var message := ""
var in_range := false
var time := 0.0


func setup(pos: Vector2, text: String) -> void:
	position = pos
	message = text


func _ready() -> void:
	collision_layer = Utils.L_INTERACT
	collision_mask = Utils.L_PLAYER
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(120, 100)
	cs.shape = shape
	cs.position = Vector2(0, -50)
	add_child(cs)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	z_index = 2


func _process(delta: float) -> void:
	time += delta
	queue_redraw()
	if in_range and Game.dialogue_cooldown <= 0.0 and Input.is_action_just_pressed("interact"):
		Game.toast.emit(message)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		in_range = true
		Game.prompt_changed.emit("%s  阅读" % Game.interact_label())


func _on_body_exited(body: Node) -> void:
	if body is Player:
		in_range = false
		Game.prompt_changed.emit("")


func _draw() -> void:
	# post
	draw_line(Vector2(0, 0), Vector2(0, -68), Color(0.22, 0.25, 0.3), 5.0)
	draw_line(Vector2(0, -68), Vector2(0, -104), Color(0.22, 0.25, 0.3), 4.0)
	# board
	draw_colored_polygon(PackedVector2Array([
		Vector2(-30, -106), Vector2(30, -106), Vector2(34, -68), Vector2(-34, -68)
	]), Color(0.19, 0.24, 0.3))
	draw_polyline(PackedVector2Array([
		Vector2(-30, -106), Vector2(30, -106), Vector2(34, -68), Vector2(-34, -68), Vector2(-30, -106)
	]), Color(Utils.C_RIM, 0.45), 1.5, true)
	# runes
	var pulse := 0.55 + 0.45 * sin(time * 2.4)
	draw_line(Vector2(-16, -94), Vector2(10, -94), Color(Utils.C_GLOW, 0.5 * pulse), 1.6)
	draw_line(Vector2(-16, -87), Vector2(4, -87), Color(Utils.C_GLOW, 0.35 * pulse), 1.6)
	draw_line(Vector2(-16, -80), Vector2(14, -80), Color(Utils.C_GLOW, 0.28 * pulse), 1.6)
	draw_circle(Vector2(0, -68), 4.0, Color(Utils.C_WARM, 0.7))
