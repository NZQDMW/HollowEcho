extends Enemy

enum State { PATROL, TELEGRAPH, LUNGE, RECOVER }

var state: State = State.PATROL
var timer := 0.0
var cooldown := 0.0


func _configure(_data: Dictionary) -> void:
	max_hp = 8
	geo_drop = 5
	body_size = Vector2(62, 118)
	contact_damage = 1


func _ai(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if player == null:
		velocity.x = 0.0
		return
	var dx := player.global_position.x - global_position.x
	var dy := absf(player.global_position.y - global_position.y)
	match state:
		State.PATROL:
			if position.x <= patrol_min:
				facing = 1
			elif position.x >= patrol_max:
				facing = -1
			velocity.x = facing * 56.0
			if dy < 150.0 and absf(dx) < 380.0 and cooldown <= 0.0 and not player.dead:
				state = State.TELEGRAPH
				timer = 0.38
				facing = 1 if dx > 0.0 else -1
				velocity.x = 0.0
		State.TELEGRAPH:
			velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.LUNGE
				timer = 0.32
				velocity.x = facing * 760.0
		State.LUNGE:
			velocity.x = facing * 760.0
			timer -= delta
			if timer <= 0.0 or is_on_wall():
				state = State.RECOVER
				timer = 0.55
				velocity.x = 0.0
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.PATROL
				cooldown = 1.1


func death_color() -> Color:
	return Color(0.9, 0.55, 0.4)


func _draw() -> void:
	var bob := sin(anim_time * 3.0) * 1.5
	var lean := 0.0
	if state == State.TELEGRAPH:
		lean = -0.12 * facing
	elif state == State.LUNGE:
		lean = 0.18 * facing
	var base := Vector2(0, bob)
	var cloth := Color(0.19, 0.22, 0.29) if flash <= 0.0 else Color(0.65, 0.67, 0.7)
	var dark := Color(0.06, 0.08, 0.11) if flash <= 0.0 else Color(0.5, 0.52, 0.56)
	var mask_col := Color(0.78, 0.74, 0.64) if flash <= 0.0 else Color(1, 1, 1)
	var eye_col := Color(0.95, 0.35, 0.25) if state == State.TELEGRAPH else Color(0.6, 0.9, 0.95)

	# legs
	draw_line(base + Vector2(-14, -44), base + Vector2(-20 - lean * 20.0, 0), dark, 9.0)
	draw_line(base + Vector2(14, -44), base + Vector2(20 + lean * 20.0, 0), dark, 9.0)
	# robe
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-30, -100), base + Vector2(-22, -42), base + Vector2(-34, -8),
		base + Vector2(30, -8), base + Vector2(24, -44), base + Vector2(30, -100)
	]), cloth)
	draw_line(base + Vector2(-24, -94), base + Vector2(-28, -12), Color(Utils.C_RIM, 0.3), 2.0)
	# arms
	draw_line(base + Vector2(-24, -88), base + Vector2(-44, -58 + lean * 18.0), dark, 8.0)
	draw_line(base + Vector2(24, -88), base + Vector2(48, -62 + lean * 18.0), dark, 8.0)
	# club
	var hand := base + Vector2(48, -62 + lean * 18.0)
	var club_tip := hand + Vector2(40 * facing, -26 - lean * 40.0)
	draw_line(hand, club_tip, Color(0.28, 0.24, 0.2), 7.0)
	draw_circle(club_tip, 10.0, Color(0.3, 0.25, 0.2))
	# mask
	var head := base + Vector2(0, -116)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(0, 16), head + Vector2(-17, 8), head + Vector2(-14, -10),
		head + Vector2(0, -16), head + Vector2(14, -10), head + Vector2(17, 8)
	]), mask_col)
	draw_circle(head + Vector2(-6, 0), 3.0, eye_col)
	draw_circle(head + Vector2(6, 0), 3.0, eye_col)
