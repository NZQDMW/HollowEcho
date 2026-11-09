extends Node2D

var rect := Rect2()
var relic_id: StringName = &""
var hint := ""
var locked := true
var body: StaticBody2D
var time := 0.0
var hint_cooldown := 0.0


func setup(r: Rect2, rid: StringName, text: String) -> void:
	rect = r
	relic_id = rid
	hint = text
	position = r.position


func _ready() -> void:
	locked = not Game.has_relic(relic_id)
	Game.relic_gained.connect(_on_relic_gained)
	if locked:
		body = StaticBody2D.new()
		body.collision_layer = Utils.L_WORLD
		body.collision_mask = 0
		body.position = rect.size * 0.5
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		cs.shape = shape
		body.add_child(cs)
		add_child(body)
		var area := Area2D.new()
		area.collision_layer = 0
		area.collision_mask = Utils.L_PLAYER
		area.position = rect.size * 0.5
		var acs := CollisionShape2D.new()
		var ashape := RectangleShape2D.new()
		ashape.size = rect.size + Vector2(90, 40)
		acs.shape = ashape
		area.add_child(acs)
		area.body_entered.connect(_on_body_entered)
		add_child(area)
	z_index = 2


func _on_relic_gained(rid: StringName, _title: String) -> void:
	if rid == relic_id and locked:
		locked = false
		if body != null:
			body.queue_free()
			body = null
		queue_redraw()


func _on_body_entered(body_node: Node) -> void:
	if locked and hint_cooldown <= 0.0 and body_node is Player:
		hint_cooldown = 4.0
		Game.toast.emit(hint)


func _process(delta: float) -> void:
	time += delta
	hint_cooldown = maxf(0.0, hint_cooldown - delta)
	if locked:
		queue_redraw()


func _draw() -> void:
	if not locked:
		# faint remnants of the seal
		draw_rect(Rect2(Vector2.ZERO, rect.size), Color(Utils.C_RIM, 0.03))
		return
	var pulse := 0.5 + 0.5 * sin(time * 3.0)
	draw_rect(Rect2(Vector2.ZERO, rect.size), Color(0.05, 0.18, 0.22, 0.28))
	for i in range(int(rect.size.x / 34.0) + 1):
		var x := i * 34.0
		var a := 0.12 + 0.12 * pulse
		draw_line(Vector2(x, 0), Vector2(x + 10, rect.size.y), Color(Utils.C_GLOW, a), 2.0)
	for i in range(int(rect.size.y / 42.0) + 1):
		var y := i * 42.0 + fposmod(time * 26.0, 42.0)
		draw_line(Vector2(0, y), Vector2(rect.size.x, y), Color(Utils.C_RIM, 0.06 + 0.05 * pulse), 1.0)
	draw_rect(Rect2(Vector2.ZERO, rect.size), Color(Utils.C_RIM, 0.2 + 0.1 * pulse), false, 2.0)
