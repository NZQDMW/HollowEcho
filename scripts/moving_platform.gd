extends AnimatableBody2D

# 苦痛之路的移动石台：沿 move 向量做正弦往返，玩家站在上面会被一起带走。

var platform_size := Vector2(160, 24)
var base_pos := Vector2.ZERO
var move_vec := Vector2.ZERO
var period := 3.0
var phase := 0.0
var time := 0.0
var shape: CollisionShape2D
var rune_seed := 1


func setup(config: Dictionary) -> void:
	base_pos = config.get("pos", Vector2.ZERO)
	platform_size = config.get("size", Vector2(160, 24))
	move_vec = config.get("move", Vector2.ZERO)
	period = maxf(0.2, float(config.get("period", 3.0)))
	phase = float(config.get("phase", 0.0))
	rune_seed = int(config.get("seed", int(absf(base_pos.x)) + int(absf(base_pos.y))))
	position = base_pos


func _ready() -> void:
	collision_layer = Utils.L_WORLD
	collision_mask = 0
	sync_to_physics = true
	shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = platform_size
	shape.shape = rect
	shape.one_way_collision = true
	shape.one_way_collision_margin = 10.0
	add_child(shape)
	z_index = 3
	queue_redraw()


func _physics_process(delta: float) -> void:
	time += delta
	var t := time / period * TAU + phase
	position = base_pos + Vector2(move_vec.x * sin(t), move_vec.y * sin(t))
	queue_redraw()


func _draw() -> void:
	var half := platform_size * 0.5
	var rect := Rect2(-half, platform_size)
	var poly := Utils.slab_poly(rect, rune_seed)
	draw_colored_polygon(poly, Utils.C_ROCK2)
	# pale rim light — the path is carved from a whiter stone than the caves
	draw_line(Vector2(-half.x + 4.0, -half.y), Vector2(half.x - 4.0, -half.y),
		Color(Utils.C_IVORY, 0.72), 2.0, true)
	draw_line(Vector2(-half.x + 2.0, half.y), Vector2(-half.x + 2.0, -half.y),
		Color(Utils.C_RIM, 0.28), 1.5)
	# moving runes
	var pulse := 0.45 + 0.35 * sin(time * 2.4 + phase)
	for i in range(3):
		var x := -half.x * 0.55 + i * half.x * 0.55
		draw_circle(Vector2(x, 0), 2.6, Color(Utils.C_GLOW, 0.25 + pulse * 0.35))
	# underside shadow
	draw_line(Vector2(-half.x + 6.0, half.y - 1.0), Vector2(half.x - 6.0, half.y - 1.0),
		Color(0.02, 0.03, 0.05, 0.8), 2.0)
