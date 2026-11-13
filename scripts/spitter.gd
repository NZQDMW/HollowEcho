extends Enemy

enum State { IDLE, WINDUP, RECOVER }

var speed := 28.0
var state: State = State.IDLE
var timer := 0.0
var cooldown := 1.0


func _configure(_data: Dictionary) -> void:
	max_hp = 5
	geo_drop = 4
	body_size = Vector2(68, 52)
	contact_damage = 1


func _ai(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if player == null or player.dead:
		velocity.x = 0.0
		return
	if position.x <= patrol_min:
		facing = 1
	elif position.x >= patrol_max:
		facing = -1
	var dx := player.global_position.x - global_position.x
	var dy := player.global_position.y - global_position.y
	var in_range := absf(dx) < 560.0 and absf(dy) < 220.0
	match state:
		State.IDLE:
			velocity.x = facing * speed
			_face_player(dx)
			if cooldown <= 0.0 and in_range:
				state = State.WINDUP
				timer = 0.55
				velocity.x = 0.0
		State.WINDUP:
			velocity.x = 0.0
			_face_player(dx)
			timer -= delta
			if timer <= 0.0:
				_spit()
				state = State.RECOVER
				timer = 0.45
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.IDLE
				cooldown = 2.1


func _face_player(dx: float) -> void:
	if absf(dx) > 6.0:
		facing = 1 if dx > 0.0 else -1


func _spit() -> void:
	if world == null or player == null:
		return
	var from := global_position + Vector2(facing * 40.0, -38.0)
	var to := player.global_position + Vector2(0, -46)
	var vel := Vector2(signf(to.x - from.x) * 440.0, clampf((to.y - from.y) * 1.4, -240.0, 240.0))
	world.spawn_acid(from, vel)


func death_color() -> Color:
	return Color(0.55, 0.9, 0.4)


func _draw() -> void:
	var bob := sin(anim_time * 3.0) * 2.0
	var pulse := 0.5 + 0.5 * sin(anim_time * (8.0 if state == State.WINDUP else 2.5))
	var shell := Color(0.13, 0.17, 0.2) if flash <= 0.0 else Color(0.62, 0.66, 0.68)
	var shell_hi := Color(0.22, 0.28, 0.32) if flash <= 0.0 else Color(0.8, 0.82, 0.84)
	var sac := Color(0.42, 0.78, 0.3, 0.55 + 0.35 * pulse) if flash <= 0.0 else Color(0.9, 1.0, 0.9)
	var base := Vector2(0, bob)

	# stubby legs
	for i in range(3):
		var lx := -24.0 + i * 22.0
		draw_line(base + Vector2(lx, -16), base + Vector2(lx - 6, 0), Color(0.07, 0.09, 0.12), 4.0)

	# shell carapace
	draw_colored_polygon(Utils.ellipse_points(base + Vector2(0, -24), 34, 26, 22), shell)
	draw_colored_polygon(Utils.ellipse_points(base + Vector2(-4, -32), 22, 14, 18), shell_hi)

	# glowing acid sac on the back
	draw_circle(base + Vector2(-14, -40), (11.0 + pulse * 3.0), sac)
	draw_circle(base + Vector2(-16, -43), 3.5, Color(0.85, 1.0, 0.7, 0.7))

	# mouth funnel
	var mouth := base + Vector2(facing * 28.0, -28)
	var mw := 8.0 + pulse * 3.0
	draw_colored_polygon(PackedVector2Array([
		mouth + Vector2(0, -mw), mouth + Vector2(facing * 10.0, 0), mouth + Vector2(0, mw)
	]), Color(0.3, 0.5, 0.2, 0.9))
	draw_line(mouth + Vector2(facing * 4.0, 0), mouth + Vector2(facing * 12.0, 0), Color(0.7, 1.0, 0.55, 0.6 + 0.3 * pulse), 2.0)

	# eyes
	draw_circle(base + Vector2(facing * 10.0, -28), 3.2, Color(0.75, 1.0, 0.5))
	draw_circle(base + Vector2(facing * 2.0, -30), 2.4, Color(0.75, 1.0, 0.5, 0.8))

	if state == State.WINDUP:
		draw_arc(base + Vector2(facing * 24.0, -28), 18.0 + pulse * 6.0, -0.8, 0.8, 16,
			Color(0.6, 1.0, 0.45, 0.5), 2.0, true)
