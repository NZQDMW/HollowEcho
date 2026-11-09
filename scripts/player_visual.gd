class_name PlayerVisual
extends Node2D

var player: Player
var run_phase := 0.0
var time := 0.0
var ghosts: Array[Dictionary] = []
var ghost_timer := 0.0


func _process(delta: float) -> void:
	time += delta
	if player == null:
		return
	var speed := absf(player.velocity.x)
	var on_floor := player.is_on_floor()
	if on_floor and speed > 20.0:
		run_phase += delta * (speed / Player.SPEED) * 2.1
	else:
		run_phase = lerpf(run_phase, roundf(run_phase), delta * 8.0)

	if player.dashing:
		ghost_timer -= delta
		if ghost_timer <= 0.0:
			ghost_timer = 0.028
			ghosts.append({"pos": player.global_position, "age": 0.0})
			if ghosts.size() > 8:
				ghosts.pop_front()
	for g in ghosts:
		g["age"] = float(g["age"]) + delta
	while not ghosts.is_empty() and float(ghosts[0]["age"]) > 0.3:
		ghosts.pop_front()

	if player.invuln > 0.0 and not player.dead:
		modulate.a = 0.45 + 0.55 * absf(sin(time * 18.0))
	else:
		modulate.a = 1.0

	scale.x = player.facing
	queue_redraw()


func _draw() -> void:
	if player == null:
		return

	var flash := player.hurt_timer > 0.0
	var speed := absf(player.velocity.x)
	var moving := speed > 20.0 and player.is_on_floor()
	var bob := sin(run_phase * TAU) * 2.5 if moving else sin(time * 2.2) * 1.2
	var lean := clampf(player.velocity.x / Player.SPEED, -1.0, 1.0) * 0.06

	var cloak := Color(0.28, 0.35, 0.48) if flash else Utils.C_SLATE
	var cloak_dark := Color(0.18, 0.23, 0.33) if flash else Color(0.13, 0.17, 0.25)
	var body_col := Color(0.75, 0.78, 0.8) if flash else Color(0.055, 0.07, 0.1)
	var mask_col := Color(1, 1, 1) if flash else Utils.C_IVORY

	# --- afterimages ---
	for g in ghosts:
		var lp: Vector2 = to_local(Vector2(g["pos"]))
		var a: float = 0.24 * (1.0 - float(g["age"]) / 0.3)
		var gp := PackedVector2Array([
			lp + Vector2(-44, -92), lp + Vector2(-52, -30), lp + Vector2(-30, -2),
			lp + Vector2(26, -2), lp + Vector2(48, -36), lp + Vector2(30, -92)
		])
		draw_colored_polygon(gp, Color(cloak.r, cloak.g, cloak.b, a))

	# --- dash streak ---
	if player.dashing:
		for i in range(4):
			var yy := -20.0 - i * 22.0
			draw_line(Vector2(-90.0 - i * 22.0, yy), Vector2(-30.0, yy), Color(Utils.C_GLOW, 0.10 + 0.04 * i), 2.0, true)

	var ground_y := 0.0
	if not player.is_on_floor():
		ground_y = 0.0

	# --- legs ---
	var stride := sin(run_phase * TAU) * 9.0 if moving else 0.0
	var leg_col := Color(0.06, 0.08, 0.12)
	if flash:
		leg_col = Color(0.6, 0.62, 0.65)
	_draw_leg(Vector2(-11, -26 + bob), Vector2(-15 + stride, ground_y), leg_col)
	_draw_leg(Vector2(11, -26 + bob), Vector2(15 - stride, ground_y), leg_col)

	# --- cloak ---
	var sway := sin(time * 2.6) * 2.5
	var tail := 6.0 + clampf(player.velocity.x * 0.02, -7.0, 9.0)
	if player.dashing:
		tail = 34.0
	if player.wall_sliding:
		sway = 5.0
	var base := Vector2(0, bob)
	var cloak_pts := PackedVector2Array([
		base + Vector2(-30, -96),
		base + Vector2(-38, -66 + sway * 0.5),
		base + Vector2(-50 - tail * 0.4, -30 + sway),
		base + Vector2(-44, -4 + sway * 0.5),
		base + Vector2(-16, 2),
		base + Vector2(14, 2),
		base + Vector2(44, -6),
		base + Vector2(50 + tail * 0.35, -34 + sway * 0.6),
		base + Vector2(36, -68 + sway * 0.4),
		base + Vector2(28, -96)
	])
	draw_colored_polygon(cloak_pts, cloak)
	# inner shadow
	var inner := PackedVector2Array([
		base + Vector2(-20, -90), base + Vector2(-26, -40), base + Vector2(-8, -12),
		base + Vector2(18, -14), base + Vector2(28, -46), base + Vector2(20, -90)
	])
	draw_colored_polygon(inner, cloak_dark)
	# rim light along the cloak edge
	draw_polyline(PackedVector2Array([
		base + Vector2(-30, -96), base + Vector2(-38, -66 + sway * 0.5),
		base + Vector2(-50 - tail * 0.4, -30 + sway), base + Vector2(-44, -4)
	]), Color(Utils.C_RIM, 0.5), 2.0, true)

	# --- body ---
	var body_rect := PackedVector2Array([
		base + Vector2(-16, -100), base + Vector2(16, -100),
		base + Vector2(20, -30), base + Vector2(-18, -30)
	])
	draw_colored_polygon(body_rect, body_col)

	# --- head / mask ---
	var head := base + Vector2(0, -118 + sin(time * 2.2) * 1.0)
	# horns
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(-17, -8), head + Vector2(-44, -40), head + Vector2(-26, 4)
	]), mask_col)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(17, -8), head + Vector2(44, -40), head + Vector2(26, 4)
	]), mask_col)
	# mask face
	var mask_pts := PackedVector2Array([
		head + Vector2(0, 18), head + Vector2(-24, 10), head + Vector2(-30, -6),
		head + Vector2(-18, -14), head + Vector2(18, -14), head + Vector2(30, -6),
		head + Vector2(24, 10)
	])
	draw_colored_polygon(mask_pts, mask_col)
	# eye sockets
	var eye_col := Color(0.02, 0.025, 0.04)
	if flash:
		eye_col = Color(0.3, 0.3, 0.35)
	draw_circle(head + Vector2(-11, 0), 5.2, eye_col)
	draw_circle(head + Vector2(11, 0), 5.2, eye_col)
	# tiny eye glints
	draw_circle(head + Vector2(-9, -1.5), 1.4, Color(0.75, 0.9, 0.95, 0.8))
	draw_circle(head + Vector2(13, -1.5), 1.4, Color(0.75, 0.9, 0.95, 0.8))

	# --- arm & nail ---
	_draw_arm_and_nail(base, head)

	# --- focus aura ---
	if player.focusing:
		var t := clampf(player.focus_timer / Player.FOCUS_TIME, 0.0, 1.0)
		var center := base + Vector2(0, -58)
		var radius := 34.0 + 22.0 * t
		draw_arc(center, radius, 0.0, TAU, 40, Color(Utils.C_SOUL, 0.35 + 0.4 * t), 3.0, true)
		draw_arc(center, radius * 0.68, time * 2.0, time * 2.0 + PI * 1.4, 24, Color(Utils.C_GLOW, 0.5), 2.0, true)
		for i in range(7):
			var ang := time * 3.0 + i * TAU / 7.0
			var r2 := lerpf(radius * 1.8, radius * 0.5, fposmod(time * 0.9 + i * 0.17, 1.0))
			var p := center + Vector2(cos(ang), sin(ang)) * r2
			draw_circle(p, 2.2, Color(Utils.C_GLOW, 0.75))


func _draw_leg(hip: Vector2, foot: Vector2, col: Color) -> void:
	draw_line(hip, foot, col, 9.0, true)
	draw_circle(foot, 4.5, col)


func _draw_arm_and_nail(base: Vector2, head: Vector2) -> void:
	var hand := base + Vector2(16, -84)
	var nail_col := Color(0.82, 0.87, 0.9)
	var glow_col := Color(Utils.C_GLOW, 0.55)

	if player.attacking:
		var t := clampf(1.0 - player.attack_timer / Player.ATTACK_TIME, 0.0, 1.0)
		var eased := ease(t, 0.45)
		var ang := 0.0
		var arc_from := 0.0
		var arc_to := 0.0
		var length := 108.0
		match player.attack_dir:
			Vector2.UP:
				hand = base + Vector2(10, -96)
				ang = lerpf(-0.25, -1.72, eased)
				arc_from = -0.25
				arc_to = ang
				length = 116.0
			Vector2.DOWN:
				hand = base + Vector2(8, -60)
				ang = lerpf(0.25, 1.72, eased)
				arc_from = 0.25
				arc_to = ang
				length = 112.0
			_:
				hand = base + Vector2(16, -84)
				ang = lerpf(-1.15, 0.55, eased)
				arc_from = -1.2
				arc_to = ang
				length = 118.0
		var tip := hand + Vector2(cos(ang), sin(ang)) * length
		# slash arc trail
		if t > 0.08:
			var pts := PackedVector2Array()
			var steps := 14
			for i in range(steps + 1):
				var a2 := lerpf(arc_from, arc_to, float(i) / steps)
				pts.append(hand + Vector2(cos(a2), sin(a2)) * (length * 0.92))
			draw_polyline(pts, Color(Utils.C_SOUL, 0.55 * (1.0 - t * 0.6)), 7.0, true)
			draw_polyline(pts, Color(1, 1, 1, 0.35 * (1.0 - t)), 2.5, true)
		# arm and nail
		draw_line(base + Vector2(12, -84), hand, Color(0.06, 0.08, 0.12), 9.0, true)
		draw_line(hand, tip, nail_col, 5.5, true)
		draw_line(hand, tip, glow_col, 2.0, true)
	else:
		var tip := base + Vector2(62, -42)
		draw_line(base + Vector2(14, -84), base + Vector2(40, -64), Color(0.07, 0.09, 0.13), 8.0, true)
		draw_line(base + Vector2(40, -64), tip, nail_col, 4.5, true)
		draw_line(base + Vector2(40, -64), tip, Color(Utils.C_GLOW, 0.28), 1.5, true)

	# wall cling arm
	if player.wall_sliding:
		draw_line(base + Vector2(10, -90), base + Vector2(46, -104), Color(0.08, 0.1, 0.14), 8.0, true)
		draw_circle(base + Vector2(46, -104), 4.0, Color(0.08, 0.1, 0.14))
