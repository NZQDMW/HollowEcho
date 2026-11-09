extends SceneTree

var game
var frame := 0


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	root.add_child(game)


func key_event(code: int) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	ev.pressed = true
	return ev


func _process(_delta: float) -> bool:
	frame += 1
	match frame:
		4:
			game.debug_start()
		20:
			game._unhandled_input(key_event(KEY_TAB))
		26:
			print("ASSERT map_paused=", paused)
		50:
			game._unhandled_input(key_event(KEY_TAB))
		56:
			print("ASSERT map_closed_paused=", paused)
		80:
			game._unhandled_input(key_event(KEY_ESCAPE))
		86:
			print("ASSERT pause_paused=", paused)
		120:
			game._unhandled_input(key_event(KEY_ESCAPE))
		126:
			print("ASSERT resume_paused=", paused)
		160:
			quit()
	return false
