extends StaticBody2D

# 苦痛之路的碎裂石台：被踩上后晃动，短暂延迟后崩塌，数秒后重新凝成。

var platform_size := Vector2(140, 22)
var base_pos := Vector2.ZERO
var crumble_delay := 0.6
var respawn_time := 2.8
var state := 0  # 0 idle, 1 shaking, 2 gone
var timer := 0.0
var shake := 0.0
var rune_seed := 1
var shape: CollisionShape2D
var detector: Area2D
var time := 0.0


func setup(config: Dictionary) -> void:
	base_pos = config.get("pos", Vector2.ZERO)
	platform_size = config.get("size", Vector2(140, 22))
	crumble_delay = float(config.get("delay", 0.6))
	respawn_time = float(config.get("respawn", 2.8))
	rune_seed = int(config.get("seed", int(absf(base_pos.x)) + int(absf(base_pos.y))))
	position = base_pos


func _ready() -> void:
	collision_layer = Utils.L_WORLD
	collision_mask = 0
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = platform_size
	cs.shape = rect
	cs.one_way_collision = true
	cs.one_way_collision_margin = 10.0
	add_child(cs)
	shape = cs

	detector = Area2D.new()
	detector.collision_layer = 0
	detector.collision_mask = Utils.L_PLAYER
	detector.position = Vector2(0, -platform_size.y * 0.5 - 4.0)
	var dcs := CollisionShape2D.new()
	var dshape := RectangleShape2D.new()
	dshape.size = Vector2(platform_size.x, 12.0)
	dcs.shape = dshape
	detector.add_child(dcs)
	add_child(detector)
	detector.body_entered.connect(_on_body_entered)

	z_index = 3
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if state != 0 or not (body is Player):
		return
	state = 1
	timer = crumble_delay


func _process(delta: float) -> void:
	time += delta
	match state:
		1:
			timer -= delta
			shake = sin(time * 58.0) * 4.0
			if timer <= 0.0:
				state = 2
				timer = respawn_time
				shape.set_deferred("disabled", true)
				detector.set_deferred("monitoring", false)
				var world := get_tree().get_first_node_in_group("world")
				if world != null:
					world.call("spawn_death_burst", global_position, Color(0.55, 0.5, 0.42))
		2:
			timer -= delta
			if timer <= 0.0:
				state = 0
				shake = 0.0
				shape.set_deferred("disabled", false)
				detector.set_deferred("monitoring", true)
	queue_redraw()


func _draw() -> void:
	if state == 2:
		# faint outline of where the slab will re-form
		var half := platform_size * 0.5
		draw_rect(Rect2(-half, platform_size), Color(Utils.C_RIM, 0.05), false, 1.2)
		return
	var half := platform_size * 0.5
	draw_set_transform(Vector2(shake, 0), 0.0, Vector2.ONE)
	var rect := Rect2(-half, platform_size)
	var poly := Utils.slab_poly(rect, rune_seed)
	var col := Utils.C_ROCK2 if state == 0 else Color(0.22, 0.2, 0.22)
	draw_colored_polygon(poly, col)
	draw_line(Vector2(-half.x + 4.0, -half.y), Vector2(half.x - 4.0, -half.y),
		Color(Utils.C_IVORY, 0.6), 2.0, true)
	# fracture lines appear while shaking
	if state == 1:
		for i in range(3):
			var x := -half.x * 0.5 + i * half.x * 0.5
			draw_line(Vector2(x, -half.y + 2.0), Vector2(x + 6.0, half.y - 2.0),
				Color(0.95, 0.55, 0.4, 0.7), 1.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
