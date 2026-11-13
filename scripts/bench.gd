extends Area2D

var room_id: StringName = &"r1"
var in_range := false
var time := 0.0
var resting := 0.0


func setup(pos: Vector2, rid: StringName) -> void:
	position = pos
	room_id = rid


func _ready() -> void:
	collision_layer = Utils.L_INTERACT
	collision_mask = Utils.L_PLAYER
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(150, 110)
	cs.shape = shape
	cs.position = Vector2(0, -55)
	add_child(cs)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	z_index = 1


func _process(delta: float) -> void:
	time += delta
	if resting > 0.0:
		resting = maxf(0.0, resting - delta)
	queue_redraw()
	if in_range and Game.dialogue_cooldown <= 0.0 and Input.is_action_just_pressed("interact"):
		Game.save_bench(room_id, position)
		resting = 1.2
		var world := get_tree().get_first_node_in_group("world")
		if world != null:
			world.call("spawn_focus_burst", global_position + Vector2(0, -46))


func _on_body_entered(body: Node) -> void:
	if body is Player:
		in_range = true
		Game.prompt_changed.emit("E  在长椅上休息")


func _on_body_exited(body: Node) -> void:
	if body is Player:
		in_range = false
		Game.prompt_changed.emit("")


func _draw() -> void:
	var glow := 0.5 + 0.5 * sin(time * 2.0)
	# seat
	draw_colored_polygon(PackedVector2Array([
		Vector2(-52, -42), Vector2(52, -42), Vector2(58, -28), Vector2(-58, -28)
	]), Color(0.24, 0.29, 0.38))
	draw_line(Vector2(-52, -42), Vector2(52, -42), Color(Utils.C_RIM, 0.55), 2.0, true)
	# backrest
	draw_colored_polygon(PackedVector2Array([
		Vector2(-44, -84), Vector2(-30, -84), Vector2(-34, -42), Vector2(-48, -42)
	]), Color(0.2, 0.25, 0.33))
	draw_colored_polygon(PackedVector2Array([
		Vector2(30, -84), Vector2(44, -84), Vector2(48, -42), Vector2(34, -42)
	]), Color(0.2, 0.25, 0.33))
	# legs
	draw_line(Vector2(-44, -28), Vector2(-46, 0), Color(0.13, 0.16, 0.22), 6.0)
	draw_line(Vector2(44, -28), Vector2(46, 0), Color(0.13, 0.16, 0.22), 6.0)
	# soft glow at the seat
	draw_circle(Vector2(0, -46), 34.0, Color(Utils.C_GLOW, 0.05 + 0.03 * glow))
	draw_circle(Vector2(0, -46), 18.0, Color(Utils.C_GLOW, 0.08 + 0.04 * glow))
	if resting > 0.0:
		draw_arc(Vector2(0, -48), 46.0 + (1.2 - resting) * 30.0, 0.0, TAU, 32, Color(Utils.C_SOUL, resting * 0.5), 2.0, true)
