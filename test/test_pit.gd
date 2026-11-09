extends SceneTree

var game
var gm
var frame := 0


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	root.add_child(game)


func _process(_delta: float) -> bool:
	frame += 1
	if gm == null:
		gm = root.get_node_or_null("Game")

	match frame:
		4:
			game.debug_start()
		20:
			game.debug_goto(&"r4", Vector2(1100, 1480))
			print("ASSERT pit_enter masks=", gm.masks, " pos=", game.world.player.global_position)
		45:
			var p = game.world.player
			print("ASSERT pit_exit pos=", p.global_position, " masks=", gm.masks, " floor=", p.is_on_floor(), " room=", game.world.room_id)
		80:
			quit()
	return false
