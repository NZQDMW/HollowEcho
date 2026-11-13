class_name Boss
extends CharacterBody2D

signal defeated

enum State { INTRO, WALK, TELEGRAPH_SLAM, SLAM, RECOVER, TELEGRAPH_CHARGE, CHARGE, STAGGER, DYING, DEAD }

var max_hp := 60
var hp := 60
var phase := 1
var boss_id := "guard"
var boss_name := "残破守卫"
var final_boss := true
var phase2_text := "铠甲碎裂了。守卫的怒火更加猛烈。"
var arena := Rect2()
var player: Player
var world: GameWorld
var state: State = State.INTRO
var timer := 1.4
var attack_cd := 1.0
var facing := -1
var flash := 0.0
var anim_time := 0.0
var was_airborne := false
var body_size := Vector2(110, 180)
var touch_area: Area2D
var gate_bodies: Array[Node] = []
var gate_visuals: Array[Node2D] = []
var rng := RandomNumberGenerator.new()


func setup(pos: Vector2, arena_rect: Rect2, config := {}) -> void:
	position = pos
	arena = arena_rect
	boss_id = String(config.get("id", "guard"))
	boss_name = String(config.get("name", "残破守卫"))
	max_hp = int(config.get("hp", 60))
	hp = max_hp
	final_boss = bool(config.get("final", true))
	phase2_text = String(config.get("phase2_text", "铠甲碎裂了。守卫的怒火更加猛烈。"))
	rng.randomize()


func _ready() -> void:
	collision_layer = Utils.L_ENEMY
	collision_mask = Utils.L_WORLD
	floor_snap_length = 8.0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = body_size
	cs.shape = shape
	cs.position = Vector2(0, -body_size.y * 0.5)
	add_child(cs)

	touch_area = Area2D.new()
	touch_area.collision_layer = 0
	touch_area.collision_mask = Utils.L_PLAYER
	var tcs := CollisionShape2D.new()
	var tshape := RectangleShape2D.new()
	tshape.size = body_size + Vector2(14, 10)
	tcs.shape = tshape
	tcs.position = Vector2(0, -body_size.y * 0.5)
	touch_area.add_child(tcs)
	add_child(touch_area)

	z_index = 4
	anim_time = randf() * 10.0
	Game.boss_state.emit(true, boss_name, hp, max_hp)
	call_deferred("_spawn_gates")


func _spawn_gates() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var left := Rect2(arena.position.x, arena.position.y, 22, arena.size.y)
	var right := Rect2(arena.end.x - 22, arena.position.y, 22, arena.size.y)
	for r in [left, right]:
		var body := StaticBody2D.new()
		body.collision_layer = Utils.L_WORLD
		body.collision_mask = 0
		body.position = r.get_center()
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = r.size
		cs.shape = shape
		body.add_child(cs)
		parent.add_child(body)
		gate_bodies.append(body)

		var holder := Node2D.new()
		var poly := Polygon2D.new()
		poly.polygon = PackedVector2Array([
			r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)
		])
		poly.color = Color(0.1, 0.55, 0.65, 0.3)
		holder.add_child(poly)
		for i in range(5):
			var line := Line2D.new()
			var x: float = r.position.x + 3.0 + i * (r.size.x - 6.0) / 4.0
			line.points = PackedVector2Array([Vector2(x, r.position.y), Vector2(x, r.end.y)])
			line.width = 2.5
			line.default_color = Color(0.5, 0.95, 1.0, 0.5)
			holder.add_child(line)
		var edge := Line2D.new()
		edge.points = PackedVector2Array([Vector2(r.position.x, r.position.y), Vector2(r.position.x, r.end.y)])
		edge.width = 4.0
		edge.default_color = Color(0.6, 1.0, 1.0, 0.55)
		holder.add_child(edge)
		parent.add_child(holder)
		gate_visuals.append(holder)


func _open_gates() -> void:
	for b in gate_bodies:
		if is_instance_valid(b):
			b.queue_free()
	gate_bodies.clear()
	for v in gate_visuals:
		if is_instance_valid(v):
			v.queue_free()
	gate_visuals.clear()


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	anim_time += delta
	flash = maxf(0.0, flash - delta)
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
	if world == null:
		world = get_tree().get_first_node_in_group("world") as GameWorld
	if player == null:
		return

	attack_cd = maxf(0.0, attack_cd - delta)
	var dx := player.global_position.x - global_position.x

	match state:
		State.INTRO:
			timer -= delta
			velocity.x = 0.0
			if player != null and not player.dead:
				facing = 1 if dx > 0.0 else -1
			if timer <= 0.0:
				state = State.WALK
				attack_cd = 0.7
		State.WALK:
			face_player(dx)
			if absf(dx) > 190.0:
				velocity.x = facing * (145.0 if phase == 2 else 95.0)
			else:
				velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if attack_cd <= 0.0:
				if absf(dx) < 640.0 and rng.randf() < 0.65:
					state = State.TELEGRAPH_SLAM
					timer = 0.42 if phase == 2 else 0.55
				else:
					state = State.TELEGRAPH_CHARGE
					timer = 0.45 if phase == 2 else 0.6
				velocity.x = 0.0
		State.TELEGRAPH_SLAM:
			face_player(dx)
			velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.SLAM
				was_airborne = false
				velocity = Vector2(clampf(dx / 0.68, -430.0, 430.0), -760.0)
		State.SLAM:
			if not is_on_floor():
				was_airborne = true
			if was_airborne and is_on_floor():
				_land_slam()
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.WALK
				attack_cd = 0.85 if phase == 2 else 1.25
		State.TELEGRAPH_CHARGE:
			face_player(dx)
			velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.CHARGE
				timer = 0.48
				velocity.x = facing * 940.0
		State.CHARGE:
			velocity.x = facing * 940.0
			timer -= delta
			if timer <= 0.0 or is_on_wall():
				state = State.STAGGER
				timer = 0.75 if phase == 2 else 0.95
				velocity.x = 0.0
				if world != null:
					world.spawn_death_burst(global_position + Vector2(0, -80), Color(0.8, 0.7, 0.55))
		State.STAGGER:
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
			timer -= delta
			if timer <= 0.0:
				state = State.WALK
				attack_cd = 0.65
		State.DYING:
			velocity.x = 0.0
			timer -= delta
			if timer <= 0.0:
				state = State.DEAD
				if final_boss:
					Game.trigger_ending()
				return

	if not is_on_floor():
		velocity.y = minf(velocity.y + 2400.0 * delta, 1600.0)
	elif velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()
	global_position.x = clampf(global_position.x, arena.position.x + 60.0, arena.end.x - 60.0)

	if state != State.DYING and player != null and not player.dead and player.invuln <= 0.0:
		if touch_area.overlaps_body(player):
			player.take_damage(1, global_position)

	queue_redraw()


func face_player(dx: float) -> void:
	if absf(dx) > 4.0:
		facing = 1 if dx > 0.0 else -1


func _land_slam() -> void:
	state = State.RECOVER
	timer = 0.55 if phase == 2 else 0.75
	velocity.x = 0.0
	if world != null:
		world.spawn_shockwave(global_position + Vector2(facing * 40.0, 0), 1)
		world.spawn_shockwave(global_position + Vector2(-facing * 40.0, 0), -1)
		world.spawn_death_burst(global_position + Vector2(0, -10), Color(0.85, 0.7, 0.5))
		if world.camera != null:
			world.camera.add_shake(14.0)
	if player != null and absf(player.global_position.x - global_position.x) < 170.0 \
		and absf(player.global_position.y - global_position.y) < 120.0 and player.invuln <= 0.0:
		player.take_damage(1, global_position)


func take_hit(damage: int, dir: Vector2, _src) -> void:
	if state == State.DYING or state == State.DEAD:
		return
	hp = maxi(0, hp - damage)
	flash = 0.14
	if world != null:
		world.spawn_hit(global_position + Vector2(0, -90), dir)
	if phase == 1 and hp <= max_hp / 2:
		phase = 2
		Game.toast.emit(phase2_text)
		if world != null:
			world.spawn_death_burst(global_position + Vector2(0, -100), Color(1.0, 0.45, 0.3))
	Game.boss_state.emit(true, boss_name, hp, max_hp)
	if hp <= 0:
		_defeat()


func _defeat() -> void:
	state = State.DYING
	timer = 1.9
	_open_gates()
	Game.boss_state.emit(false, "", 0, 1)
	Game.bosses_defeated[boss_id] = true
	defeated.emit()
	if world != null:
		world.spawn_death_burst(global_position + Vector2(0, -110), Color(1.0, 0.75, 0.5))
		world.spawn_death_burst(global_position + Vector2(0, -70), Color(0.8, 0.9, 1.0))
		if world.camera != null:
			world.camera.add_shake(16.0)
	if not final_boss:
		Game.reward_echo_boss()


func _draw() -> void:
	var bob := sin(anim_time * 2.0) * 2.5
	var crouch := 0.0
	if state == State.STAGGER:
		crouch = 24.0
	elif state == State.DYING:
		crouch = 44.0
	var lean := 0.0
	match state:
		State.TELEGRAPH_SLAM:
			lean = -0.08
		State.SLAM:
			lean = 0.16
		State.TELEGRAPH_CHARGE:
			lean = -0.14
		State.CHARGE:
			lean = 0.2
	var base := Vector2(0, bob + crouch)
	var armor := Color(0.16, 0.14, 0.18) if flash <= 0.0 else Color(0.75, 0.72, 0.68)
	var armor_hi := Color(0.28, 0.25, 0.3) if flash <= 0.0 else Color(0.9, 0.88, 0.84)
	var rim := Color(0.8, 0.52, 0.32, 0.8)
	var cloth := Color(0.1, 0.09, 0.12) if flash <= 0.0 else Color(0.5, 0.48, 0.45)
	var eye := Color(0.9, 0.3, 0.2) if phase == 2 else Color(0.55, 0.9, 1.0)

	# legs
	draw_line(base + Vector2(-30, -66), base + Vector2(-38 - lean * 30.0, 0), armor, 16.0)
	draw_line(base + Vector2(30, -66), base + Vector2(38 + lean * 30.0, 0), armor, 16.0)
	draw_line(base + Vector2(-44, 0), base + Vector2(-24, 0), armor_hi, 8.0)
	draw_line(base + Vector2(24, 0), base + Vector2(44, 0), armor_hi, 8.0)

	# skirt
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-58, -140), base + Vector2(-40, -62), base + Vector2(-70, -10),
		base + Vector2(70, -10), base + Vector2(42, -64), base + Vector2(58, -140)
	]), cloth)
	# torso
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-54, -190), base + Vector2(-66, -136), base + Vector2(-44, -96),
		base + Vector2(44, -96), base + Vector2(66, -136), base + Vector2(54, -190)
	]), armor)
	draw_polyline(PackedVector2Array([
		base + Vector2(-54, -190), base + Vector2(-66, -136), base + Vector2(-44, -96)
	]), rim, 3.0, true)
	# chest plate lines
	draw_line(base + Vector2(0, -186), base + Vector2(0, -100), armor_hi, 3.0)
	draw_line(base + Vector2(-40, -152), base + Vector2(40, -152), armor_hi, 2.0)

	# arms and mace
	var mace_ang := 0.55
	match state:
		State.TELEGRAPH_SLAM:
			mace_ang = -1.15
		State.SLAM:
			mace_ang = 1.35
		State.TELEGRAPH_CHARGE:
			mace_ang = -0.4
		State.STAGGER:
			mace_ang = 1.55
		State.DYING:
			mace_ang = 1.62
	var shoulder := base + Vector2(46 * facing, -172)
	var hand := shoulder + Vector2(cos(mace_ang) * 64.0 * facing, sin(mace_ang) * 54.0)
	draw_line(base + Vector2(40 * facing, -176), hand, armor, 14.0)
	draw_circle(hand, 9.0, armor_hi)
	var mace_dir := Vector2(facing * cos(mace_ang + 0.5), sin(mace_ang + 0.5))
	var mace_tip := hand + mace_dir * 88.0
	draw_line(hand, mace_tip, Color(0.24, 0.2, 0.17), 10.0)
	draw_colored_polygon(Utils.ellipse_points(mace_tip, 26, 20, 18), Color(0.3, 0.25, 0.22))
	draw_colored_polygon(Utils.ellipse_points(mace_tip, 14, 10, 14), Color(0.4, 0.33, 0.28))

	# head
	var head := base + Vector2(0, -212)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(0, 26), head + Vector2(-30, 16), head + Vector2(-34, -18),
		head + Vector2(-14, -34), head + Vector2(14, -34), head + Vector2(34, -18),
		head + Vector2(30, 16)
	]), Color(0.72, 0.67, 0.56) if flash <= 0.0 else Color(1, 1, 1))
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(-22, -22), head + Vector2(-52, -62), head + Vector2(-34, -12)
	]), Color(0.72, 0.67, 0.56) if flash <= 0.0 else Color(1, 1, 1))
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(22, -22), head + Vector2(52, -62), head + Vector2(34, -12)
	]), Color(0.72, 0.67, 0.56) if flash <= 0.0 else Color(1, 1, 1))
	draw_circle(head + Vector2(-10, 0), 5.5, eye)
	draw_circle(head + Vector2(10, 0), 5.5, eye)
	draw_circle(head + Vector2(-10, 0), 11.0, Color(eye.r, eye.g, eye.b, 0.16))
	draw_circle(head + Vector2(10, 0), 11.0, Color(eye.r, eye.g, eye.b, 0.16))

	# phase 2 cracks
	if phase == 2 and state != State.DEAD:
		draw_line(base + Vector2(-30, -170), base + Vector2(-8, -130), Color(0.95, 0.4, 0.25, 0.7), 2.5)
		draw_line(base + Vector2(34, -120), base + Vector2(10, -90), Color(0.95, 0.4, 0.25, 0.7), 2.5)
