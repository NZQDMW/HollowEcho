extends Enemy

var speed := 76.0


func _configure(_data: Dictionary) -> void:
	max_hp = 4
	geo_drop = 3
	body_size = Vector2(86, 44)
	contact_damage = 1


func _ai(_delta: float) -> void:
	if position.x <= patrol_min:
		facing = 1
	elif position.x >= patrol_max:
		facing = -1
	if is_on_wall():
		facing *= -1
	velocity.x = facing * speed


func death_color() -> Color:
	return Color(1.0, 0.62, 0.28)


func _draw() -> void:
	var bob := sin(anim_time * 9.0) * 1.8
	var shell := Color(0.11, 0.14, 0.2) if flash <= 0.0 else Color(0.55, 0.58, 0.62)
	var shell_hi := Color(0.19, 0.25, 0.34) if flash <= 0.0 else Color(0.7, 0.72, 0.75)
	# legs
	for i in range(3):
		var lx := -26.0 + i * 22.0
		var wave := sin(anim_time * 11.0 + i * 1.7) * 6.0
		draw_line(Vector2(lx, -18 + bob), Vector2(lx - 16 + wave, 0), Color(0.07, 0.09, 0.13), 4.0)
		draw_line(Vector2(lx + 8, -18 + bob), Vector2(lx + 20 + wave, 0), Color(0.07, 0.09, 0.13), 4.0)
	# shell
	draw_colored_polygon(Utils.ellipse_points(Vector2(0, -22 + bob), 44, 21, 26), shell)
	draw_colored_polygon(Utils.ellipse_points(Vector2(0, -27 + bob), 30, 12, 22), shell_hi)
	# segment lines
	for i in range(3):
		var x := -16.0 + i * 16.0
		draw_line(Vector2(x, -40 + bob), Vector2(x + 4, -8 + bob), Color(0.05, 0.07, 0.1, 0.8), 1.5)
	# eyes
	var eye := Color(1.0, 0.66, 0.25)
	draw_circle(Vector2(24, -26 + bob), 5.0, eye)
	draw_circle(Vector2(12, -28 + bob), 4.0, eye)
	draw_circle(Vector2(24, -26 + bob), 9.0, Color(1.0, 0.55, 0.2, 0.16))
	draw_circle(Vector2(12, -28 + bob), 8.0, Color(1.0, 0.55, 0.2, 0.14))
