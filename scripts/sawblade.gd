extends Node2D

# 苦痛之路的锯刃：沿 move 向量正弦往返，接触玩家扣 1 格生命。

var radius := 28.0
var base_pos := Vector2.ZERO
var move_vec := Vector2.ZERO
var period := 2.4
var phase := 0.0
var spin_speed := 7.0
var time := 0.0
var area: Area2D
var player: Player
var world: GameWorld


func setup(config: Dictionary) -> void:
	base_pos = config.get("pos", Vector2.ZERO)
	radius = float(config.get("radius", 28.0))
	move_vec = config.get("move", Vector2.ZERO)
	period = maxf(0.2, float(config.get("period", 2.4)))
	phase = float(config.get("phase", 0.0))
	spin_speed = float(config.get("spin", 7.0))
	position = base_pos


func _ready() -> void:
	area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = Utils.L_PLAYER
	area.monitorable = false
	var cs := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius * 0.82
	cs.shape = shape
	area.add_child(cs)
	add_child(area)
	z_index = 5
	queue_redraw()


func _physics_process(delta: float) -> void:
	time += delta
	var t := time / period * TAU + phase
	position = base_pos + Vector2(move_vec.x * sin(t), move_vec.y * sin(t))
	rotation += spin_speed * delta
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
	if player != null and not player.dead and area.overlaps_body(player):
		player.take_damage(1, global_position)
	queue_redraw()


func _draw() -> void:
	var teeth := 10
	var pts := PackedVector2Array()
	for i in range(teeth * 2):
		var a := TAU * float(i) / float(teeth * 2)
		var r := radius if i % 2 == 0 else radius * 0.72
		pts.append(Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, Color(0.34, 0.3, 0.29))
	draw_polyline(pts, Color(0.86, 0.62, 0.42, 0.75), 1.6, true)
	draw_circle(Vector2.ZERO, radius * 0.58, Color(0.2, 0.18, 0.18))
	draw_circle(Vector2.ZERO, radius * 0.3, Color(0.62, 0.4, 0.24))
	draw_circle(Vector2.ZERO, radius * 0.12, Color(0.98, 0.78, 0.5, 0.9))
	# motion shimmer
	for i in range(teeth):
		var a2 := TAU * float(i) / float(teeth) + time * 0.6
		draw_line(Vector2(cos(a2), sin(a2)) * radius * 0.9, Vector2(cos(a2), sin(a2)) * radius * 1.14,
			Color(0.95, 0.55, 0.35, 0.12), 1.2)
	draw_circle(Vector2.ZERO, radius * 1.25, Color(0.9, 0.4, 0.28, 0.05))
