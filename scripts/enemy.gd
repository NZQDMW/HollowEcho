class_name Enemy
extends CharacterBody2D

var max_hp := 4
var hp := 4
var contact_damage := 1
var geo_drop := 2
var body_size := Vector2(70, 46)
var use_gravity := true
var dead := false
var flash := 0.0
var anim_time := 0.0
var facing := 1
var home := Vector2.ZERO
var patrol_min := 0.0
var patrol_max := 0.0
var player: Player
var world: GameWorld
var touch_area: Area2D


func setup(data: Dictionary) -> void:
	var p: Vector2 = data.get("pos", Vector2.ZERO)
	home = p
	position = p
	patrol_min = float(data.get("min_x", p.x - 140.0))
	patrol_max = float(data.get("max_x", p.x + 140.0))
	_configure(data)


func _configure(_data: Dictionary) -> void:
	pass


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = Utils.L_ENEMY
	collision_mask = Utils.L_WORLD
	floor_snap_length = 8.0
	hp = max_hp

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = body_size
	cs.shape = shape
	cs.position = Vector2(0, -body_size.y * 0.5)
	add_child(cs)

	touch_area = Area2D.new()
	touch_area.collision_layer = 0
	touch_area.collision_mask = Utils.L_PLAYER
	touch_area.monitoring = true
	var tcs := CollisionShape2D.new()
	var tshape := RectangleShape2D.new()
	tshape.size = body_size + Vector2(10, 10)
	tcs.shape = tshape
	tcs.position = Vector2(0, -body_size.y * 0.5)
	touch_area.add_child(tcs)
	add_child(touch_area)

	z_index = 4
	anim_time = randf() * 10.0


func _physics_process(delta: float) -> void:
	if dead:
		return
	anim_time += delta
	flash = maxf(0.0, flash - delta)
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
	if world == null:
		world = get_tree().get_first_node_in_group("world") as GameWorld

	_ai(delta)

	if use_gravity:
		if not is_on_floor():
			velocity.y = minf(velocity.y + 2200.0 * delta, 1200.0)
		elif velocity.y > 0.0:
			velocity.y = 0.0

	move_and_slide()

	if player != null and not player.dead and player.invuln <= 0.0 and touch_area.overlaps_body(player):
		player.take_damage(contact_damage, global_position)

	queue_redraw()


func _ai(_delta: float) -> void:
	pass


func take_hit(damage: int, dir: Vector2, _src) -> void:
	if dead:
		return
	hp -= damage
	flash = 0.16
	if use_gravity:
		velocity += Vector2(dir.x * 160.0, -110.0)
	else:
		velocity += Vector2(dir.x * 130.0, 0.0)
	if world != null:
		world.spawn_hit(global_position + Vector2(0, -body_size.y * 0.6), dir)
	if hp <= 0:
		_die()


func death_color() -> Color:
	return Utils.C_GLOW


func _die() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	if touch_area != null:
		touch_area.set_deferred("monitoring", false)
	if world != null:
		world.spawn_death_burst(global_position + Vector2(0, -body_size.y * 0.5), death_color())
		if geo_drop > 0:
			world.spawn_geo(global_position + Vector2(0, -28), geo_drop)
	queue_free()
