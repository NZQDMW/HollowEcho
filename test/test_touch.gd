extends SceneTree

# 手机触摸控制回归：摇杆移动/瞄准、动作键、自动松开、地图/暂停键。

var game
var gm
var frame := 0
var touch
var stick_center := Vector2.ZERO
var jump_pos := Vector2.ZERO
var attack_pos := Vector2.ZERO
var pause_pos := Vector2.ZERO
var map_pos := Vector2.ZERO


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	root.add_child(game)


func _button_pos(name: String) -> Vector2:
	for b in touch.buttons:
		if String(b["name"]) == name:
			return b["pos"]
	return Vector2.ZERO


func _process(_delta: float) -> bool:
	frame += 1
	if gm == null:
		gm = root.get_node_or_null("Game")

	match frame:
		4:
			game.debug_start()
		20:
			touch = game.touch
			touch.visible = true
			touch.size = Vector2(1280, 720)
			touch._layout()
			touch.set_process(true)
			var g = root.get_node_or_null("Game")
			if g != null:
				g.touch_mode = true
			stick_center = touch.stick_center
			jump_pos = _button_pos("jump")
			attack_pos = _button_pos("attack")
			pause_pos = _button_pos("pause")
			map_pos = _button_pos("map")
			print("ASSERT touch_ready visible=", touch.visible,
				" stick=", stick_center, " jump=", jump_pos, " pause=", pause_pos)
			# 摇杆向右
			touch.touch_down(0, stick_center + Vector2(80, 0))
			print("ASSERT stick_right=", Input.get_action_strength("move_right") > 0.4,
				" strength=", Input.get_action_strength("move_right"))
			# 摇杆拖到左上
			touch.touch_drag(0, stick_center + Vector2(-80, -80))
			print("ASSERT stick_left=", Input.get_action_strength("move_left") > 0.4,
				" aim_up=", Input.is_action_pressed("aim_up"))
			touch.touch_up(0)
			print("ASSERT stick_release=", not Input.is_action_pressed("move_left"),
				" aim_up_released=", not Input.is_action_pressed("aim_up"))
		30:
			# 跳跃键按住 / 松开
			touch.touch_down(1, jump_pos)
			print("ASSERT jump_down=", Input.is_action_pressed("jump"))
		36:
			touch.touch_up(1)
			print("ASSERT jump_released=", not Input.is_action_pressed("jump"))
		# 攻击键自动松开
		40:
			touch.touch_down(2, attack_pos)
			print("ASSERT attack_down=", Input.is_action_pressed("attack"))
		50:
			print("ASSERT attack_auto_released=", not Input.is_action_pressed("attack"))
			touch.touch_up(2)
			# 暂停 / 地图
			touch.touch_down(3, pause_pos)
		60:
			print("ASSERT pause_on=", game.paused, " tree_paused=", paused)
			touch.touch_up(3)
			touch.touch_down(4, pause_pos)
		70:
			print("ASSERT pause_off=", not game.paused, " tree_paused=", paused)
			touch.touch_up(4)
			touch.touch_down(5, map_pos)
		80:
			print("ASSERT map_on=", game.map_open, " tree_paused=", paused)
			touch.touch_up(5)
			touch.touch_down(6, map_pos)
		90:
			print("ASSERT map_off=", not game.map_open, " tree_paused=", paused)
			touch.touch_up(6)
			# HUD 文案应切换为触摸提示
			print("ASSERT touch_mode=", gm.touch_mode, " interact_label=", gm.interact_label())
		110:
			touch._release_all()
			quit()
	return false
