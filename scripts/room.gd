class_name Room
extends Node2D

signal door_entered(target: StringName, door_index: int)

var data: Dictionary = {}
var bounds := Rect2()
var room_id: StringName = &"r1"
var room_name := ""
var theme := {}
var ground: Array = []
var ledges: Array = []
var doors: Array = []
var lanterns: Array = []
var hazards: Array = []
var pits: Array = []


func setup(room_data: Dictionary) -> void:
	data = room_data
	room_id = data.get("id", &"r1")
	room_name = data.get("name", "")
	theme = data.get("theme", {})
	ground = data.get("ground", [])
	ledges = data.get("ledges", [])
	doors = data.get("doors", [])
	lanterns = data.get("lanterns", [])
	hazards = data.get("hazards", [])
	pits = data.get("pits", [])
	var size: Vector2 = data.get("size", Vector2(1280, 720))
	bounds = Rect2(Vector2.ZERO, size)
	_build_collision()
	_build_doors()
	_build_hazards()
	_build_pits()
	_build_gates()
	_build_bench_and_signs()
	_build_pickups()
	_build_enemies()
	_build_boss()
	_build_lanterns()
	queue_redraw()


func _build_collision() -> void:
	for g in ground:
		_make_static(g["rect"])
	for w in data.get("walls", []):
		_make_static(w["rect"])
	for l in ledges:
		_make_static(l["rect"], true)
	# room boundaries
	var s := bounds.size
	_make_static(Rect2(-60, -60, 60, s.y + 120))
	_make_static(Rect2(s.x, -60, 60, s.y + 120))
	_make_static(Rect2(0, -60, s.x, 60))
	_make_static(Rect2(0, s.y, s.x, 60))


func _make_static(rect: Rect2, one_way := false) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = Utils.L_WORLD
	body.collision_mask = 0
	body.position = rect.get_center()
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	shape.shape = rs
	shape.one_way_collision = one_way
	if one_way:
		shape.one_way_collision_margin = 10.0
	body.add_child(shape)
	add_child(body)


func _build_doors() -> void:
	for i in range(doors.size()):
		var dd: Dictionary = doors[i]
		var trigger: Rect2 = dd["trigger"]
		var area := Area2D.new()
		area.collision_layer = 0
		area.collision_mask = Utils.L_PLAYER
		area.position = trigger.get_center()
		var shape := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = trigger.size
		shape.shape = rs
		area.add_child(shape)
		add_child(area)
		var target: StringName = dd["target"]
		var target_door: int = int(dd["target_door"])
		area.body_entered.connect(func(body: Node) -> void:
			if body is Player:
				door_entered.emit(target, target_door)
		)


func _build_hazards() -> void:
	for h in hazards:
		var rect: Rect2 = h
		var area := Area2D.new()
		area.collision_layer = Utils.L_HAZARD
		area.collision_mask = Utils.L_PLAYER
		area.position = rect.get_center()
		var shape := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = rect.size
		shape.shape = rs
		area.add_child(shape)
		area.body_entered.connect(func(body: Node) -> void:
			if body is Player:
				body.take_damage(1, rect.get_center())
		)
		add_child(area)


func _build_pits() -> void:
	for p in pits:
		var rect: Rect2 = p["rect"]
		var respawn: Vector2 = p["respawn"]
		var area := Area2D.new()
		area.collision_layer = 0
		area.collision_mask = Utils.L_PLAYER
		area.position = rect.get_center()
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		cs.shape = shape
		area.add_child(cs)
		add_child(area)
		area.body_entered.connect(func(body: Node) -> void:
			var pl := body as Player
			if pl == null or pl.dead:
				return
			if pl.invuln <= 0.0:
				pl.take_damage(1, rect.get_center())
			if pl.dead:
				return
			pl.global_position = respawn
			pl.velocity = Vector2.ZERO
			pl.invuln = maxf(pl.invuln, 0.9)
			var world := get_tree().get_first_node_in_group("world")
			if world != null:
				world.call("spawn_death_burst", rect.get_center(), Color(0.55, 0.45, 0.9))
				var cam = world.get("camera")
				if cam != null:
					cam.add_shake(9.0)
			Game.toast.emit("深渊将你送回了岸边。")
		)


func _load_script(path: String) -> GDScript:
	if ResourceLoader.exists(path):
		return load(path) as GDScript
	push_warning("Missing script: %s" % path)
	return null


func _build_gates() -> void:
	var scr := _load_script("res://scripts/gate.gd")
	if scr == null:
		return
	for g in data.get("gates", []):
		var node = scr.new()
		node.setup(g["rect"], g["relic"], g["hint"])
		add_child(node)


func _build_bench_and_signs() -> void:
	var bench_scr := _load_script("res://scripts/bench.gd")
	if bench_scr != null:
		for p in data.get("benches", []):
			var b = bench_scr.new()
			b.setup(p, room_id)
			add_child(b)
	var sign_scr := _load_script("res://scripts/sign.gd")
	if sign_scr != null:
		for s in data.get("signs", []):
			var node = sign_scr.new()
			node.setup(s["pos"], s["text"])
			add_child(node)


func _build_pickups() -> void:
	var scr := _load_script("res://scripts/pickup.gd")
	if scr == null:
		return
	for p in data.get("pickups", []):
		var pos: Vector2 = p["pos"]
		var key := "%s:%.0f:%.0f" % [room_id, pos.x, pos.y]
		if Game.taken_pickups.has(key):
			continue
		var node = scr.new()
		node.setup_geo(pos, int(p["amount"]), key)
		add_child(node)
	for r in data.get("relics", []):
		var rid: StringName = r["id"]
		var pos: Vector2 = r["pos"]
		var key := "%s:%.0f:%.0f" % [room_id, pos.x, pos.y]
		if Game.has_relic(rid) or Game.taken_pickups.has(key):
			continue
		var node = scr.new()
		node.setup_relic(pos, rid, r["title"], key)
		add_child(node)
	for m in data.get("mask_shards", []):
		var pos: Vector2 = m["pos"]
		var key := "%s:%.0f:%.0f" % [room_id, pos.x, pos.y]
		if Game.taken_pickups.has(key):
			continue
		var node = scr.new()
		node.setup_mask(pos, key)
		add_child(node)


func _build_enemies() -> void:
	var map := {
		"crawler": "res://scripts/crawler.gd",
		"flyer": "res://scripts/flyer.gd",
		"husk": "res://scripts/husk.gd",
	}
	for e in data.get("enemies", []):
		var path: String = map.get(e["type"], "")
		if path.is_empty():
			continue
		var scr := _load_script(path)
		if scr == null:
			continue
		var node = scr.new()
		node.setup(e)
		add_child(node)


func _build_boss() -> void:
	var boss_data: Dictionary = data.get("boss", {})
	if boss_data.is_empty():
		return
	var scr := _load_script("res://scripts/boss.gd")
	if scr == null:
		return
	var node = scr.new()
	node.setup(boss_data["pos"], boss_data.get("arena", bounds))
	add_child(node)


func _build_lanterns() -> void:
	for p in lanterns:
		var pos: Vector2 = p
		Utils.make_glow(self, pos + Vector2(0, -76), 96.0, Color(1.0, 0.68, 0.34, 0.42))


func _draw() -> void:
	var accent: Color = theme.get("accent", Utils.C_RIM)
	for g in ground:
		var rect: Rect2 = g["rect"]
		var seed_value: int = int(g.get("seed", 1))
		var poly := Utils.ground_poly(rect, seed_value)
		draw_colored_polygon(poly, Utils.C_ROCK)
		var top := PackedVector2Array()
		for i in range(1, poly.size() - 1):
			top.append(poly[i])
		if top.size() >= 2:
			draw_polyline(top, Color(Utils.C_RIM, 0.85), 2.2, true)
		_draw_ground_details(rect, seed_value, accent)

	for w in data.get("walls", []):
		_draw_wall(w["rect"], int(w.get("seed", 5)))

	for l in ledges:
		var rect: Rect2 = l["rect"]
		var seed_value: int = int(l.get("seed", 2))
		var poly := Utils.slab_poly(rect, seed_value)
		draw_colored_polygon(poly, Utils.C_ROCK2)
		var top := PackedVector2Array()
		for p in poly:
			if p.y <= rect.position.y + 7.0:
				top.append(p)
		if top.size() >= 2:
			draw_polyline(top, Color(Utils.C_RIM, 0.75), 2.0, true)
		draw_line(rect.position + Vector2(8, rect.size.y), rect.position + Vector2(rect.size.x - 12, rect.size.y), Color(0.03, 0.05, 0.08), 2.0)

	for h in hazards:
		_draw_hazard(h)

	for p in pits:
		_draw_pit(p["rect"])

	for d in doors:
		_draw_door(d, accent)

	for p in lanterns:
		_draw_lantern(p)

	_draw_decor(accent)


func _draw_ground_details(rect: Rect2, seed_value: int, accent: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 131 + 7
	# cracks
	for i in range(int(rect.size.x / 120.0) + 1):
		var x := rng.randf_range(rect.position.x + 16.0, rect.position.x + rect.size.x - 16.0)
		var y := rng.randf_range(rect.position.y + 18.0, rect.position.y + minf(rect.size.y - 8.0, 90.0))
		draw_line(Vector2(x, y), Vector2(x + rng.randf_range(-16, 16), y + rng.randf_range(12, 34)), Color(0.04, 0.06, 0.1, 0.8), 1.5)
	# moss tufts
	for i in range(int(rect.size.x / 70.0) + 1):
		var x := rng.randf_range(rect.position.x + 8.0, rect.position.x + rect.size.x - 8.0)
		var y := rect.position.y
		for k in range(3):
			draw_line(Vector2(x + k * 4.0, y), Vector2(x + k * 4.0 + rng.randf_range(-7, 7), y - rng.randf_range(7, 18)), Color(0.18, 0.4, 0.34, 0.85), 1.6)
	# glowing mushrooms
	for i in range(int(rect.size.x / 180.0) + 1):
		var x := rng.randf_range(rect.position.x + 20.0, rect.position.x + rect.size.x - 20.0)
		var y := rect.position.y - 2.0
		draw_line(Vector2(x, y), Vector2(x, y - 12), Color(0.5, 0.7, 0.7, 0.5), 2.0)
		draw_circle(Vector2(x, y - 13), 3.5 + rng.randf() * 1.5, Color(accent.r, accent.g, accent.b, 0.75))


func _draw_pit(rect: Rect2) -> void:
	var top := rect.position.y - 150.0
	draw_rect(Rect2(rect.position.x, top, rect.size.x, rect.size.y + 150.0), Color(0.004, 0.005, 0.01, 0.58))
	for i in range(3):
		var y := top + 46.0 + i * 38.0
		draw_line(Vector2(rect.position.x + 10, y), Vector2(rect.end.x - 10, y), Color(0.36, 0.3, 0.56, 0.09), 2.0)
	var x := rect.position.x + 4.0
	while x < rect.end.x - 4.0:
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, rect.position.y), Vector2(x + 12, rect.position.y - 30.0), Vector2(x + 24, rect.position.y)
		]), Color(0.22, 0.1, 0.16))
		draw_line(Vector2(x + 12, rect.position.y - 30.0), Vector2(x + 24, rect.position.y), Color(0.85, 0.4, 0.35, 0.55), 1.5)
		x += 24.0


func _draw_wall(rect: Rect2, seed_value: int) -> void:
	draw_rect(rect, Utils.C_ROCK)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 97 + 3
	# vertical rim light on both faces
	draw_line(rect.position + Vector2(2, 0), rect.position + Vector2(2, rect.size.y), Color(Utils.C_RIM, 0.35), 2.0)
	draw_line(Vector2(rect.end.x - 2, rect.position.y), rect.end, Color(Utils.C_RIM, 0.2), 2.0)
	# cracks and moss
	for i in range(int(rect.size.y / 120.0) + 1):
		var y := rng.randf_range(rect.position.y + 10.0, rect.end.y - 10.0)
		var x := rng.randf_range(rect.position.x + 6.0, rect.end.x - 10.0)
		draw_line(Vector2(x, y), Vector2(x + rng.randf_range(-10, 10), y + rng.randf_range(18, 46)), Color(0.04, 0.06, 0.1, 0.8), 1.5)
		draw_circle(Vector2(x + 4, y), 2.0, Color(0.3, 0.68, 0.6, 0.4))


func _draw_hazard(rect: Rect2) -> void:
	var x := rect.position.x
	while x < rect.position.x + rect.size.x:
		var p := PackedVector2Array([
			Vector2(x, rect.end.y),
			Vector2(x + 13.0, rect.position.y),
			Vector2(x + 26.0, rect.end.y),
		])
		draw_colored_polygon(p, Color(0.28, 0.12, 0.16))
		draw_line(p[1], p[2], Color(Utils.C_DANGER, 0.7), 1.5)
		x += 26.0


func _draw_door(d: Dictionary, accent: Color) -> void:
	var trigger: Rect2 = d["trigger"]
	var c := trigger.get_center()
	var side: String = d.get("side", "left")
	if side == "up" or side == "down":
		var w := trigger.size.x
		draw_rect(Rect2(c.x - w * 0.5, c.y - 26.0, w, 52.0), Color(0.02, 0.03, 0.05, 0.85))
		draw_rect(Rect2(c.x - w * 0.46, c.y - 18.0, w * 0.92, 36.0), Color(accent.r, accent.g, accent.b, 0.10))
		draw_line(Vector2(c.x - w * 0.42, c.y), Vector2(c.x + w * 0.42, c.y), Color(accent.r, accent.g, accent.b, 0.5), 2.0)
	else:
		var h := trigger.size.y
		draw_rect(Rect2(c.x - 26.0, c.y - h * 0.5, 52.0, h), Color(0.02, 0.03, 0.05, 0.85))
		draw_rect(Rect2(c.x - 18.0, c.y - h * 0.46, 36.0, h * 0.92), Color(accent.r, accent.g, accent.b, 0.10))
		draw_line(Vector2(c.x, c.y - h * 0.42), Vector2(c.x, c.y + h * 0.42), Color(accent.r, accent.g, accent.b, 0.5), 2.0)


func _draw_lantern(p: Vector2) -> void:
	draw_line(p + Vector2(0, -72), p + Vector2(0, -6), Color(0.14, 0.17, 0.22), 4.0)
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(-11, -78), p + Vector2(11, -78), p + Vector2(6, -94), p + Vector2(-6, -94)
	]), Color(1.0, 0.74, 0.4, 0.9))
	draw_circle(p + Vector2(0, -86), 5.0, Color(0.6, 0.93, 0.96, 0.9))


func _draw_decor(accent: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 1)) * 313 + 5
	var size := bounds.size
	# hanging vines from the ceiling
	for i in range(10):
		var x := rng.randf_range(20.0, size.x - 20.0)
		var length := rng.randf_range(50.0, 190.0)
		var pts := PackedVector2Array()
		var y := 0.0
		while y < length:
			pts.append(Vector2(x + sin(y * 0.06 + i) * 7.0, y))
			y += 9.0
		draw_polyline(pts, Color(0.13, 0.24, 0.23, 0.55), 2.0, true)
	# faint runes on walls
	for i in range(3):
		var x := rng.randf_range(80.0, size.x - 80.0)
		var y := rng.randf_range(120.0, size.y * 0.55)
		draw_circle(Vector2(x, y), 2.5, Color(accent.r, accent.g, accent.b, 0.25))
		draw_arc(Vector2(x, y), 9.0, 0.0, TAU, 16, Color(accent.r, accent.g, accent.b, 0.12), 1.2, true)
