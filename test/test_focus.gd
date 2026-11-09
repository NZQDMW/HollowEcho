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
			game.debug_goto(&"r1", Vector2(700, 680))
			gm.masks = 2
			gm.masks_changed.emit(gm.masks, gm.max_masks)
			gm.soul = 66.0
			gm.soul_changed.emit(gm.soul, gm.MAX_SOUL)
		30:
			Input.action_press("focus")
		75:
			Input.action_release("focus")
		80:
			print("ASSERT heal masks=", gm.masks, " soul=", gm.soul)
		90:
			Input.action_press("spell")
		96:
			Input.action_release("spell")
		100:
			print("ASSERT spell soul=", gm.soul)
		110:
			var proj_count := 0
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/projectile.gd"):
					proj_count += 1
			print("ASSERT projectile_count=", proj_count)
		160:
			quit()

	return false
