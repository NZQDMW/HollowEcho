class_name SparkBurst
extends Node2D

var particles: Array[Dictionary] = []
var life_left := 0.5
var _gravity := 480.0


func setup(pos: Vector2, color: Color, count := 10, speed := 240.0, size := 3.0, life := 0.45, spread := PI) -> void:
	position = pos
	life_left = life
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(count):
		var ang := rng.randf_range(-spread, spread)
		var sp := rng.randf_range(speed * 0.35, speed)
		particles.append({
			"pos": Vector2.ZERO,
			"vel": Vector2(cos(ang), sin(ang)) * sp,
			"life": rng.randf_range(life * 0.55, life),
			"max": life,
			"size": size * rng.randf_range(0.6, 1.4),
			"color": color,
		})
	z_index = 20


func _process(delta: float) -> void:
	var alive := false
	for p in particles:
		var l: float = p["life"] - delta
		p["life"] = l
		if l <= 0.0:
			continue
		alive = true
		p["vel"] = Vector2(p["vel"]) + Vector2(0.0, _gravity * delta)
		p["pos"] = Vector2(p["pos"]) + Vector2(p["vel"]) * delta
	queue_redraw()
	if not alive:
		queue_free()


func _draw() -> void:
	for p in particles:
		var l: float = p["life"]
		if l <= 0.0:
			continue
		var c: Color = p["color"]
		var k: float = clampf(l / maxf(0.001, float(p["max"])), 0.0, 1.0)
		draw_circle(Vector2(p["pos"]), float(p["size"]) * k, Color(c.r, c.g, c.b, c.a * k))
