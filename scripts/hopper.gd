extends Enemy

enum State { IDLE, CROUCH, LEAP, LAND }

var state: State = State.IDLE
var timer := 0.9
var idle_time := 1.0
var crouch := 0.0


func _configure(_data: Dictionary) -> void:
	max_hp = 4
	geo_drop = 3
	body_size = Vector2(60, 44)
	contact_damage = 1


func _ai(delta: float) -> void:
	crouch = maxf(0.0, crouch - delta * 3.0)
	if player == null or player.dead:
		velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
		return
	match state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
			if position.x <= patrol_min:
				facing = 1
			elif position.x >= patrol_max:
				facing = -1
			timer -= delta
			if timer <= 0.0:
				var dx := player.global_position.x - global_position.x
				var dy := player.global_position.y - global_position.y
				if absf(dx) < 620.0 and absf(dy) < 260.0:
					facing = 1 if dx > 0.0 else -1
					state = State.CROUCH
					timer = 0.34
					crouch = 1.0
				else:
					timer = idle_time
		State.CROUCH:
			velocity.x = move_toward(velocity.x, 0.0, 2000.0 * delta)
			timer -= delta
			if timer <= 0.0:
				velocity = Vector2(facing * 235.0, -700.0)
				state = State.LEAP
				timer = 1.3
				crouch = 0.0
		State.LEAP:
			timer -= delta
			if timer <= 0.0:
				state = State.IDLE
				timer = idle_time
			elif timer < 1.1 and is_on_floor():
				state = State.LAND
				timer = 0.3
				crouch = 0.7
		State.LAND:
			velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.IDLE
				timer = idle_time


func death_color() -> Color:
	return Color(0.95, 0.75, 0.4)


func _draw() -> void:
	var base := Vector2(0, crouch * 8.0)
	var body := Color(0.14, 0.18, 0.22) if flash <= 0.0 else Color(0.65, 0.68, 0.7)
	var hi := Color(0.24, 0.31, 0.36) if flash <= 0.0 else Color(0.82, 0.84, 0.86)
	var stretch := 1.0
	if state == State.CROUCH:
		stretch = 0.82
	elif state == State.LEAP:
		stretch = 1.12

	# hind legs
	draw_line(base + Vector2(-20, -18), base + Vector2(-34, 0), Color(0.07, 0.09, 0.12), 5.0)
	draw_line(base + Vector2(20, -18), base + Vector2(34, 0), Color(0.07, 0.09, 0.12), 5.0)
	# crouched body
	var h := 26.0 * stretch
	draw_colored_polygon(Utils.ellipse_points(base + Vector2(0, -h), 30.0, h, 20), body)
	draw_colored_polygon(Utils.ellipse_points(base + Vector2(-3, -h - 3), 18.0, h * 0.55, 16), hi)
	# head
	var head := base + Vector2(facing * 26.0, -h - 10.0)
	draw_colored_polygon(Utils.ellipse_points(head, 16, 13, 16), body)
	# eyes
	draw_circle(head + Vector2(facing * 4.0, -3), 4.0, Color(1.0, 0.78, 0.35))
	draw_circle(head + Vector2(facing * 4.0, -3), 8.0, Color(1.0, 0.7, 0.3, 0.16))
	draw_circle(head + Vector2(-facing * 6.0, -4), 2.2, Color(1.0, 0.78, 0.35, 0.7))
	# glowing back ridge
	for i in range(3):
		var p := base + Vector2(-14.0 + i * 12.0, -h - 8.0 - i * 2.0)
		draw_circle(p, 2.0, Color(0.95, 0.75, 0.4, 0.5))
	if state == State.CROUCH:
		draw_arc(base + Vector2(0, -6), 34.0, PI + 0.3, TAU - 0.3, 18, Color(1.0, 0.75, 0.4, 0.35), 2.0, true)
