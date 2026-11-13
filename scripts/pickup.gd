extends Area2D

enum Kind { GEO, RELIC, MASK, SPECIAL }

var kind: Kind = Kind.GEO
var amount := 1
var relic_id: StringName = &""
var relic_title := ""
var special_id: StringName = &""
var special_title := ""
var time := 0.0
var magnet_delay := 0.25
var collected := false
var base_pos := Vector2.ZERO
var player: Player
var pickup_key := ""


func setup_geo(pos: Vector2, value: int, key := "") -> void:
	position = pos
	base_pos = pos
	amount = value
	pickup_key = key
	kind = Kind.GEO


func setup_relic(pos: Vector2, id: StringName, title: String, key := "") -> void:
	position = pos
	base_pos = pos
	relic_id = id
	relic_title = title
	pickup_key = key
	kind = Kind.RELIC


func setup_mask(pos: Vector2, key := "") -> void:
	position = pos
	base_pos = pos
	pickup_key = key
	kind = Kind.MASK


func setup_special(pos: Vector2, id: StringName, title: String, key := "") -> void:
	position = pos
	base_pos = pos
	special_id = id
	special_title = title
	pickup_key = key
	kind = Kind.SPECIAL


func _ready() -> void:
	collision_layer = 0
	collision_mask = Utils.L_PLAYER
	var cs := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 46.0 if kind == Kind.RELIC else 20.0
	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)
	z_index = 3
	if kind == Kind.RELIC:
		Utils.make_glow(self, Vector2(0, -22), 70.0, Color(Utils.C_SOUL, 0.4))
	elif kind == Kind.MASK:
		Utils.make_glow(self, Vector2(0, -18), 44.0, Color(Utils.C_IVORY, 0.28))
	elif kind == Kind.SPECIAL:
		Utils.make_glow(self, Vector2(0, -22), 64.0, Color(Utils.C_IVORY, 0.36))
	else:
		Utils.make_glow(self, Vector2(0, -10), 20.0, Color(Utils.C_GEO, 0.3))


func _process(delta: float) -> void:
	time += delta
	if kind == Kind.GEO:
		magnet_delay = maxf(0.0, magnet_delay - delta)
		if magnet_delay <= 0.0:
			if player == null:
				player = get_tree().get_first_node_in_group("player") as Player
			if player != null and not player.dead:
				var d := global_position.distance_to(player.global_position + Vector2(0, -40))
				if d < 150.0:
					global_position = global_position.move_toward(player.global_position + Vector2(0, -40), (520.0 + (150.0 - d) * 2.0) * delta)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if collected or not (body is Player):
		return
	collected = true
	if not pickup_key.is_empty():
		Game.taken_pickups[pickup_key] = true
	var world := get_tree().get_first_node_in_group("world")
	match kind:
		Kind.GEO:
			Game.add_geo(amount)
			if world != null:
				world.call("spawn_hit", global_position, Vector2.UP)
		Kind.RELIC:
			Game.gain_relic(relic_id, relic_title)
			if world != null:
				world.call("spawn_death_burst", global_position, Utils.C_SOUL)
		Kind.MASK:
			Game.add_masks(1)
			Game.toast.emit("拾得面具碎片 · 生命上限提升")
			if world != null:
				world.call("spawn_death_burst", global_position, Utils.C_IVORY)
		Kind.SPECIAL:
			Game.gain_item(special_id, special_title)
			if world != null:
				world.call("spawn_death_burst", global_position, Color(1.0, 0.82, 0.55))
	queue_free()


func _draw() -> void:
	var bob := sin(time * 2.6) * 4.0
	match kind:
		Kind.GEO:
			var c := Vector2(0, -12 + bob)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, -9), c + Vector2(8, -2), c + Vector2(5, 9),
				c + Vector2(-5, 9), c + Vector2(-8, -2)
			]), Utils.C_GEO)
			draw_line(c + Vector2(0, -7), c + Vector2(0, 7), Color(0.6, 0.5, 0.2, 0.7), 1.2)
		Kind.RELIC:
			var c := Vector2(0, -24 + bob)
			var ring := 26.0 + sin(time * 2.0) * 3.0
			draw_arc(c, ring, time * 1.8, time * 1.8 + TAU * 0.72, 30, Color(Utils.C_SOUL, 0.75), 2.5, true)
			draw_arc(c, ring + 6.0, -time * 1.1, -time * 1.1 + TAU * 0.4, 24, Color(Utils.C_GLOW, 0.4), 1.5, true)
			match relic_id:
				&"dash":
					draw_colored_polygon(PackedVector2Array([
						c + Vector2(-20, -12), c + Vector2(18, -6), c + Vector2(24, 4),
						c + Vector2(8, 14), c + Vector2(-8, 14), c + Vector2(-22, 4)
					]), Color(Utils.C_SOUL, 0.9))
					draw_line(c + Vector2(-18, 2), c + Vector2(18, 2), Color(1, 1, 1, 0.6), 1.5)
				&"wall":
					for i in range(3):
						draw_line(c + Vector2(-14 + i * 12, 14), c + Vector2(-6 + i * 12, -14), Color(Utils.C_IVORY, 0.9), 3.0)
				&"double":
					draw_colored_polygon(PackedVector2Array([
						c + Vector2(-26, 4), c + Vector2(-4, -16), c + Vector2(-2, 10)
					]), Color(Utils.C_IVORY, 0.85))
					draw_colored_polygon(PackedVector2Array([
						c + Vector2(26, 4), c + Vector2(4, -16), c + Vector2(2, 10)
					]), Color(Utils.C_IVORY, 0.85))
			var label_sz := Utils.font().get_string_size(relic_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
			draw_string(Utils.font(), Vector2(-label_sz.x * 0.5, -68), relic_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Utils.C_TEXT, 0.8))
		Kind.MASK:
			var c := Vector2(0, -18 + bob)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, 10), c + Vector2(-14, 2), c + Vector2(-16, -10),
				c + Vector2(-6, -14), c + Vector2(6, -14), c + Vector2(16, -10),
				c + Vector2(14, 2)
			]), Utils.C_IVORY)
			draw_circle(c + Vector2(-5, -3), 2.0, Color(0.05, 0.06, 0.1))
			draw_circle(c + Vector2(5, -3), 2.0, Color(0.05, 0.06, 0.1))
		Kind.SPECIAL:
			var c := Vector2(0, -24 + bob)
			var ring := 24.0 + sin(time * 2.1 + 1.0) * 3.0
			draw_arc(c, ring, -time * 1.4, -time * 1.4 + TAU * 0.8, 30, Color(Utils.C_WARM, 0.7), 2.2, true)
			draw_arc(c, ring + 5.0, time * 0.9, time * 0.9 + TAU * 0.45, 24, Color(Utils.C_IVORY, 0.35), 1.4, true)
			match special_id:
				&"feather":
					for i in range(3):
						draw_line(c + Vector2(-16 + i * 4, 12 - i * 2), c + Vector2(14 - i * 6, -14 + i * 6),
							Color(Utils.C_IVORY, 0.85 - i * 0.16), 3.0 - i * 0.5)
					draw_colored_polygon(PackedVector2Array([
						c + Vector2(14, -16), c + Vector2(22, -6), c + Vector2(12, -4)
					]), Color(Utils.C_GLOW, 0.9))
				&"lantern":
					draw_line(c + Vector2(0, -20), c + Vector2(0, -12), Color(0.5, 0.45, 0.35), 2.0)
					draw_colored_polygon(PackedVector2Array([
						c + Vector2(-10, -12), c + Vector2(10, -12), c + Vector2(13, 10),
						c + Vector2(-13, 10)
					]), Color(0.35, 0.3, 0.22, 0.95))
					draw_circle(c + Vector2(0, 0), 6.5, Color(1.0, 0.82, 0.48, 0.95))
					draw_circle(c + Vector2(0, 0), 14.0, Color(1.0, 0.75, 0.4, 0.16))
				&"pain_heart":
					draw_colored_polygon(PackedVector2Array([
						c + Vector2(0, 16), c + Vector2(-16, 0), c + Vector2(-10, -14),
						c + Vector2(0, -6), c + Vector2(10, -14), c + Vector2(16, 0)
					]), Color(0.72, 0.18, 0.2, 0.95))
					draw_line(c + Vector2(0, 12), c + Vector2(0, -4), Color(1.0, 0.72, 0.55, 0.85), 1.6)
					draw_line(c + Vector2(-8, 0), c + Vector2(0, 6), Color(1.0, 0.72, 0.55, 0.6), 1.2)
					draw_line(c + Vector2(8, 0), c + Vector2(0, 6), Color(1.0, 0.72, 0.55, 0.6), 1.2)
			var label_sz := Utils.font().get_string_size(special_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
			draw_string(Utils.font(), Vector2(-label_sz.x * 0.5, -66), special_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Utils.C_TEXT, 0.85))
