extends Enemy

var speed := 132.0


func _configure(_data: Dictionary) -> void:
	max_hp = 3
	geo_drop = 2
	body_size = Vector2(56, 40)
	use_gravity = false
	contact_damage = 1


func _ai(delta: float) -> void:
	var target := home + Vector2(0, sin(anim_time * 1.6) * 46.0)
	if player != null and player.global_position.distance_to(global_position) < 380.0:
		target = player.global_position + Vector2(0, -58)
	var desired := (target - global_position).normalized() * speed
	velocity = velocity.lerp(desired, 1.0 - exp(-2.4 * delta))
	if absf(velocity.x) > 8.0:
		facing = 1 if velocity.x > 0.0 else -1


func death_color() -> Color:
	return Color(0.55, 0.85, 0.95)


func _draw() -> void:
	var flap := sin(anim_time * 14.0)
	var bob := sin(anim_time * 3.0) * 3.0
	var wing := Color(0.24, 0.32, 0.44) if flash <= 0.0 else Color(0.7, 0.73, 0.78)
	var body_col := Color(0.08, 0.1, 0.14) if flash <= 0.0 else Color(0.6, 0.62, 0.66)
	var c := Vector2(0, -24 + bob)
	# wings
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-6, -4), c + Vector2(-46, -22 - flap * 16.0), c + Vector2(-38, 6 + flap * 8.0), c + Vector2(-4, 8)
	]), Color(wing.r, wing.g, wing.b, 0.7))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(6, -4), c + Vector2(46, -22 - flap * 16.0), c + Vector2(38, 6 + flap * 8.0), c + Vector2(4, 8)
	]), Color(wing.r, wing.g, wing.b, 0.7))
	# body
	draw_colored_polygon(Utils.ellipse_points(c, 15, 22, 20), body_col)
	# eyes
	draw_circle(c + Vector2(-6, -4), 3.2, Color(0.55, 0.94, 1.0))
	draw_circle(c + Vector2(6, -4), 3.2, Color(0.55, 0.94, 1.0))
	draw_circle(c + Vector2(-6, -4), 6.0, Color(0.45, 0.9, 1.0, 0.2))
	draw_circle(c + Vector2(6, -4), 6.0, Color(0.45, 0.9, 1.0, 0.2))
	# antennae
	draw_line(c + Vector2(-4, -18), c + Vector2(-16, -34), Color(0.3, 0.4, 0.5), 1.5)
	draw_line(c + Vector2(4, -18), c + Vector2(16, -34), Color(0.3, 0.4, 0.5), 1.5)
