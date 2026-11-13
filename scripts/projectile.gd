extends Area2D

enum Kind { SPELL, SHOCKWAVE, ACID }

var kind: Kind = Kind.SPELL
var velocity := Vector2.ZERO
var damage := 6
var life := 1.2
var dir := 1
var time := 0.0
var dead := false


func setup_spell(pos: Vector2, facing: int) -> void:
	kind = Kind.SPELL
	position = pos
	dir = facing
	velocity = Vector2(facing * 780.0, 0.0)
	damage = 6
	life = 1.1


func setup_shockwave(pos: Vector2, direction: int) -> void:
	kind = Kind.SHOCKWAVE
	position = pos
	dir = direction
	velocity = Vector2(direction * 430.0, 0.0)
	damage = 1
	life = 1.5


func setup_acid(pos: Vector2, vel: Vector2) -> void:
	kind = Kind.ACID
	position = pos
	velocity = vel
	dir = 1 if vel.x >= 0.0 else -1
	damage = 1
	life = 2.2


func _ready() -> void:
	collision_layer = 0
	if kind == Kind.SPELL:
		collision_mask = Utils.L_WORLD | Utils.L_ENEMY
	elif kind == Kind.ACID:
		collision_mask = Utils.L_WORLD | Utils.L_PLAYER
	else:
		collision_mask = Utils.L_PLAYER
	var cs := CollisionShape2D.new()
	if kind == Kind.SPELL:
		var shape := CircleShape2D.new()
		shape.radius = 16.0
		cs.shape = shape
	elif kind == Kind.ACID:
		var shape := CircleShape2D.new()
		shape.radius = 13.0
		cs.shape = shape
	else:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(48, 56)
		cs.shape = shape
		cs.position = Vector2(0, -28)
	add_child(cs)
	body_entered.connect(_on_body_entered)
	z_index = 5


func _physics_process(delta: float) -> void:
	if dead:
		return
	time += delta
	life -= delta
	position += velocity * delta
	queue_redraw()
	if life <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if dead:
		return
	if kind == Kind.SPELL:
		if body.has_method("take_hit"):
			body.take_hit(damage, Vector2(dir, 0), null)
			_burst(Utils.C_SOUL)
		else:
			_burst(Utils.C_RIM)
		dead = true
		queue_free()
	elif kind == Kind.ACID:
		if body is Player:
			body.take_damage(damage, global_position)
			_burst(Color(0.55, 0.85, 0.4))
			dead = true
			queue_free()
		elif body is StaticBody2D:
			_burst(Color(0.45, 0.7, 0.35))
			dead = true
			queue_free()
	else:
		if body is Player:
			body.take_damage(damage, global_position)
			_burst(Color(0.9, 0.7, 0.45))
			dead = true
			queue_free()


func _burst(color: Color) -> void:
	var world := get_tree().get_first_node_in_group("world")
	if world != null:
		world.call("spawn_death_burst", global_position, color)


func _draw() -> void:
	if kind == Kind.SPELL:
		var c := Vector2.ZERO
		var flicker := 0.85 + 0.15 * sin(time * 40.0)
		# trailing streak
		for i in range(4):
			draw_circle(c - Vector2(dir * (18.0 + i * 13.0), 0), 7.0 - i * 1.4, Color(Utils.C_SOUL, 0.18 * (1.0 - i * 0.2)))
		# crescent
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(dir * 16, -16), c + Vector2(dir * 28, 0), c + Vector2(dir * 16, 16),
			c + Vector2(dir * 2, 6), c + Vector2(dir * -4, 0), c + Vector2(dir * 2, -6)
		]), Color(Utils.C_SOUL, 0.92 * flicker))
		draw_circle(c, 8.0, Color(0.85, 0.98, 1.0, 0.85))
		draw_circle(c, 18.0, Color(Utils.C_SOUL, 0.12))
	elif kind == Kind.ACID:
		var wobble := sin(time * 22.0) * 2.5
		# dripping trail
		for i in range(3):
			draw_circle(
				Vector2(-dir * (14.0 + i * 12.0), wobble * (0.5 + i * 0.3)),
				5.5 - i * 1.2, Color(0.5, 0.8, 0.35, 0.22 - i * 0.05)
			)
		# blob
		draw_colored_polygon(Utils.ellipse_points(Vector2(0, wobble), 14, 11, 18), Color(0.48, 0.78, 0.32, 0.9))
		draw_circle(Vector2(-3, -3 + wobble), 4.5, Color(0.78, 0.97, 0.6, 0.8))
		draw_circle(Vector2(4, 3 + wobble), 3.0, Color(0.32, 0.55, 0.2, 0.8))
		draw_circle(Vector2(0, wobble), 18.0, Color(0.5, 0.85, 0.35, 0.1))
	else:
		var flip := 1.0 if int(time * 16.0) % 2 == 0 else 0.85
		var pts := PackedVector2Array()
		pts.append(Vector2(-26, 0))
		pts.append(Vector2(-18, -36))
		pts.append(Vector2(-6, -12))
		pts.append(Vector2(2, -52))
		pts.append(Vector2(12, -18))
		pts.append(Vector2(24, -40))
		pts.append(Vector2(26, 0))
		draw_colored_polygon(pts, Color(0.95, 0.65, 0.35, 0.5 * flip))
		draw_polyline(pts, Color(1.0, 0.8, 0.5, 0.8 * flip), 2.0, true)
		for i in range(3):
			draw_circle(Vector2(-14 + i * 14, -8 - sin(time * 22.0 + i) * 10.0), 3.0, Color(1.0, 0.75, 0.4, 0.6))