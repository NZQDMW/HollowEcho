class_name Player
extends CharacterBody2D

signal died
signal damaged
signal attack_hit(hit_pos: Vector2, dir: Vector2)
signal focus_completed
signal jumped
signal dashed

const SPEED := 340.0
const ACCEL := 2600.0
const AIR_ACCEL := 1900.0
const DECEL := 3400.0
const GRAVITY := 2500.0
const MAX_FALL := 1500.0
const JUMP_VELOCITY := -900.0
const DOUBLE_JUMP_VELOCITY := -780.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.12
const DASH_SPEED := 1050.0
const DASH_TIME := 0.2
const DASH_COOLDOWN := 0.5
const WALL_SLIDE_SPEED := 170.0
const WALL_JUMP_VELOCITY := Vector2(390.0, -870.0)
const WALL_JUMP_LOCK := 0.16
const ATTACK_TIME := 0.3
const ATTACK_ACTIVE_START := 0.03
const ATTACK_ACTIVE_END := 0.17
const ATTACK_COOLDOWN := 0.34
const ATTACK_DAMAGE := 2
const FOCUS_TIME := 0.9
const HURT_DURATION := 0.3
const INVULN_TIME := 1.1

var facing := 1
var dead := false
var control_enabled := true
var debug_invincible := false

var dashing := false
var dash_timer := 0.0
var dash_cd := 0.0
var dash_used_in_air := false

var attacking := false
var attack_timer := 0.0
var attack_cd := 0.0
var attack_dir := Vector2.RIGHT
var attack_hits := {}

var hurt_timer := 0.0
var invuln := 0.0

var focusing := false
var focus_timer := 0.0

var coyote := 0.0
var jump_buffer := 0.0
var wall_lock := 0.0
var double_used := false
var wall_sliding := false

var attack_area: Area2D
var attack_shape: CollisionShape2D
var area_rect: RectangleShape2D
var visual: PlayerVisual
var room_fx: Node


func _ready() -> void:
	add_to_group("player")
	collision_layer = Utils.L_PLAYER
	collision_mask = Utils.L_WORLD
	floor_snap_length = 8.0

	var body := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 96)
	body.shape = rect
	body.position = Vector2(0, -48)
	add_child(body)

	attack_area = Area2D.new()
	attack_area.collision_layer = 0
	attack_area.collision_mask = Utils.L_ENEMY
	attack_area.monitoring = false
	attack_area.z_index = 4
	attack_shape = CollisionShape2D.new()
	area_rect = RectangleShape2D.new()
	area_rect.size = Vector2(120, 90)
	attack_shape.shape = area_rect
	attack_area.add_child(attack_shape)
	add_child(attack_area)

	visual = PlayerVisual.new()
	visual.player = self
	visual.z_index = 6
	add_child(visual)


func _tick_timers(delta: float) -> void:
	dash_cd = maxf(0.0, dash_cd - delta)
	attack_cd = maxf(0.0, attack_cd - delta)
	invuln = maxf(0.0, invuln - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)
	wall_lock = maxf(0.0, wall_lock - delta)
	jump_buffer = maxf(0.0, jump_buffer - delta)


func _physics_process(delta: float) -> void:
	if dead:
		return
	_tick_timers(delta)

	var on_floor := is_on_floor()
	var x_input := Input.get_axis("move_left", "move_right")

	if hurt_timer > 0.0:
		if not on_floor:
			velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		else:
			velocity.x = move_toward(velocity.x, 0.0, DECEL * delta)
		move_and_slide()
		return

	if not control_enabled:
		velocity.x = move_toward(velocity.x, 0.0, DECEL * delta)
		if not on_floor:
			velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		return

	if absf(x_input) > 0.15 and not focusing:
		facing = 1 if x_input > 0.0 else -1

	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER

	# --- Focus / heal ---
	if focusing:
		var cancel := not Input.is_action_pressed("focus") \
			or not on_floor \
			or Game.masks >= Game.max_masks \
			or Game.soul < Game.HEAL_COST \
			or absf(x_input) > 0.25 \
			or Input.is_action_just_pressed("jump") \
			or Input.is_action_just_pressed("attack") \
			or Input.is_action_just_pressed("dash") \
			or Input.is_action_just_pressed("spell")
		if cancel:
			_cancel_focus()
		else:
			velocity.x = move_toward(velocity.x, 0.0, DECEL * delta)
			focus_timer += delta
			if focus_timer >= FOCUS_TIME:
				focus_timer = 0.0
				if Game.spend_soul(Game.HEAL_COST):
					Game.heal(1)
					focus_completed.emit()
			if not on_floor:
				velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
			move_and_slide()
			return

	# --- Start focus ---
	if Input.is_action_pressed("focus") and on_floor and not attacking and not dashing \
		and Game.masks < Game.max_masks and Game.soul >= Game.HEAL_COST:
		focusing = true
		focus_timer = 0.0
		velocity.x = 0.0

	# --- Dash ---
	if Input.is_action_just_pressed("dash") and Game.has_relic(&"dash") \
		and dash_cd <= 0.0 and not dashing and (on_floor or not dash_used_in_air):
		_start_dash()

	if dashing:
		dash_timer -= delta
		velocity = Vector2(facing * DASH_SPEED, 0.0)
		if dash_timer <= 0.0:
			dashing = false
			velocity.x = facing * 450.0
			dash_cd = DASH_COOLDOWN
		move_and_slide()
		return

	# --- Attack ---
	if Input.is_action_just_pressed("attack") and attack_cd <= 0.0 and not attacking:
		_start_attack()

	if attacking:
		attack_timer -= delta
		var elapsed := ATTACK_TIME - attack_timer
		if elapsed >= ATTACK_ACTIVE_START and elapsed <= ATTACK_ACTIVE_END:
			_attack_query()
		if attack_timer <= 0.0:
			attacking = false
			attack_area.monitoring = false
			attack_cd = ATTACK_COOLDOWN

	# --- Spell ---
	if Input.is_action_just_pressed("spell") and attack_cd <= 0.0 \
		and Game.soul >= Game.SPELL_COST:
		_cast_spell()

	# --- Wall state ---
	wall_sliding = false
	if Game.has_relic(&"wall") and not on_floor and is_on_wall_only():
		var wn := get_wall_normal()
		if absf(x_input) > 0.2 and signf(x_input) == signf(-wn.x):
			wall_sliding = true
			velocity.y = minf(velocity.y, WALL_SLIDE_SPEED)
			if velocity.y > -80.0:
				velocity.y = minf(velocity.y + GRAVITY * 0.25 * delta, WALL_SLIDE_SPEED)
			facing = 1 if wn.x < 0.0 else -1

	# --- Horizontal movement ---
	if wall_lock <= 0.0:
		if absf(x_input) > 0.1:
			var accel := ACCEL if on_floor else AIR_ACCEL
			velocity.x = move_toward(velocity.x, x_input * SPEED, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, DECEL * delta)

	# --- Gravity ---
	if not on_floor:
		if wall_sliding:
			velocity.y = minf(velocity.y, WALL_SLIDE_SPEED)
		else:
			velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	else:
		coyote = COYOTE_TIME
		double_used = false
		dash_used_in_air = false

	if not on_floor and not wall_sliding:
		coyote = maxf(0.0, coyote - delta)

	# --- Jump ---
	if jump_buffer > 0.0:
		if on_floor or coyote > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer = 0.0
			coyote = 0.0
			jumped.emit()
		elif (wall_sliding or (Game.has_relic(&"wall") and is_on_wall_only())):
			var wn := get_wall_normal()
			velocity.x = wn.x * WALL_JUMP_VELOCITY.x
			velocity.y = WALL_JUMP_VELOCITY.y
			wall_lock = WALL_JUMP_LOCK
			jump_buffer = 0.0
			facing = 1 if wn.x > 0.0 else -1
			jumped.emit()
		elif Game.has_relic(&"double") and not double_used:
			velocity.y = DOUBLE_JUMP_VELOCITY
			double_used = true
			jump_buffer = 0.0
			jumped.emit()

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.45

	move_and_slide()


func _start_dash() -> void:
	dashing = true
	dash_timer = DASH_TIME
	dash_cd = DASH_COOLDOWN
	if not is_on_floor():
		dash_used_in_air = true
	attack_area.monitoring = false
	attacking = false
	dashed.emit()


func _start_attack() -> void:
	attacking = true
	attack_timer = ATTACK_TIME
	attack_hits = {}
	attack_area.monitoring = true
	if Input.is_action_pressed("aim_up"):
		attack_dir = Vector2.UP
	elif Input.is_action_pressed("aim_down") and not is_on_floor():
		attack_dir = Vector2.DOWN
	else:
		attack_dir = Vector2(facing, 0)

	if attack_dir == Vector2.UP:
		attack_area.position = Vector2(0, -130)
		area_rect.size = Vector2(110, 120)
	elif attack_dir == Vector2.DOWN:
		attack_area.position = Vector2(0, 10)
		area_rect.size = Vector2(100, 120)
	else:
		attack_area.position = Vector2(facing * 78, -55)
		area_rect.size = Vector2(130, 90)


func _attack_query() -> void:
	for body in attack_area.get_overlapping_bodies():
		if body == self or not body.has_method("take_hit"):
			continue
		var id := body.get_instance_id()
		if attack_hits.has(id):
			continue
		attack_hits[id] = true
		body.take_hit(ATTACK_DAMAGE + Game.nail_bonus, attack_dir, self)
		Game.add_soul(10.0)
		attack_hit.emit(body.global_position, attack_dir)
		if attack_dir == Vector2.DOWN:
			velocity.y = -560.0
			double_used = false
			dash_used_in_air = false


func _cast_spell() -> void:
	if not Game.spend_soul(Game.SPELL_COST):
		return
	attack_cd = 0.3
	var world := get_tree().get_first_node_in_group("world")
	if world != null and world.has_method("spawn_spell"):
		world.call("spawn_spell", global_position + Vector2(facing * 44, -72), facing)


func _cancel_focus() -> void:
	focusing = false
	focus_timer = 0.0


func take_damage(amount: int, from_pos: Vector2) -> void:
	if dead or invuln > 0.0 or debug_invincible:
		return
	var now_dead := Game.hurt(amount)
	invuln = INVULN_TIME
	hurt_timer = HURT_DURATION
	focusing = false
	focus_timer = 0.0
	dashing = false
	attacking = false
	attack_area.monitoring = false
	var dir := signf(global_position.x - from_pos.x)
	if dir == 0.0:
		dir = -facing
	velocity = Vector2(dir * 400.0, -380.0)
	damaged.emit()
	if now_dead:
		_die()


func _die() -> void:
	dead = true
	control_enabled = false
	velocity = Vector2.ZERO
	attack_area.monitoring = false
	visible = false
	died.emit()


func respawn_at(pos: Vector2) -> void:
	dead = false
	visible = true
	control_enabled = true
	position = pos
	velocity = Vector2.ZERO
	invuln = 1.2
	hurt_timer = 0.0
	dashing = false
	attacking = false
	focusing = false
	focus_timer = 0.0
	dash_cd = 0.0
	attack_cd = 0.0
	double_used = false
	dash_used_in_air = false
	attack_area.monitoring = false
