extends Enemy

var drift := 0.0


func setup_shade(pos: Vector2) -> void:
	home = pos
	position = pos
	patrol_min = pos.x - 100.0
	patrol_max = pos.x + 100.0
	_configure({})


func _configure(_data: Dictionary) -> void:
	max_hp = 8
	geo_drop = 0
	body_size = Vector2(54, 96)
	use_gravity = false
	contact_damage = 1


func _ai(delta: float) -> void:
	if player == null or player.dead:
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-2.0 * delta))
		return
	var target := player.global_position + Vector2(0, -70)
	var d := global_position.distance_to(target)
	if d < 760.0:
		var speed := 72.0 + sin(anim_time * 2.0) * 22.0
		var desired := (target - global_position).normalized() * speed
		velocity = velocity.lerp(desired, 1.0 - exp(-1.8 * delta))
	else:
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-2.0 * delta))
	if absf(velocity.x) > 4.0:
		facing = 1 if velocity.x > 0.0 else -1


func death_color() -> Color:
	return Color(0.75, 0.7, 0.95)


func _die() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	if touch_area != null:
		touch_area.set_deferred("monitoring", false)
	Game.reclaim_shade()
	if world != null:
		world.spawn_death_burst(global_position + Vector2(0, -48), Color(0.8, 0.75, 1.0))
	queue_free()


func _draw() -> void:
	var bob := sin(anim_time * 2.4) * 6.0
	var a := 0.78 + 0.12 * sin(anim_time * 3.0)
	var base := Vector2(0, bob)
	var dark := Color(0.03, 0.035, 0.06, a)
	var glow := Color(0.75, 0.7, 1.0, 0.7)
	# wispy lower body
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-26, -70), base + Vector2(26, -70), base + Vector2(36, -24),
		base + Vector2(18, 6 + sin(anim_time * 2.0) * 5.0),
		base + Vector2(-4, -12), base + Vector2(-22, 4 + cos(anim_time * 2.3) * 5.0),
		base + Vector2(-34, -26)
	]), dark)
	# mask
	var head := base + Vector2(0, -92)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(-18, -8), head + Vector2(-8, -20), head + Vector2(8, -20),
		head + Vector2(18, -8), head + Vector2(12, 14), head + Vector2(-12, 14)
	]), Color(0.75, 0.72, 0.85, a))
	draw_circle(head + Vector2(-6, -2), 3.2, glow)
	draw_circle(head + Vector2(6, -2), 3.2, glow)
	draw_circle(head + Vector2(-6, -2), 7.0, Color(0.65, 0.6, 1.0, 0.15))
	draw_circle(head + Vector2(6, -2), 7.0, Color(0.65, 0.6, 1.0, 0.15))
	# trailing wisps
	for i in range(3):
		var ox := sin(anim_time * 2.0 + i * 2.0) * 16.0
		draw_circle(base + Vector2(ox - 20.0 + i * 20.0, -30.0 - i * 8.0), 2.5, Color(0.6, 0.55, 0.9, 0.35))
