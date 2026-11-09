extends SceneTree

var game
var gm
var frame := 0
var shade_node
var boss_node


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
			print("ASSERT start")
		20:
			game.debug_goto(&"r3", Vector2(1800, 780))
			print("STAGE dash relic")
		40:
			print("ASSERT dash=", gm.relics["dash"])
		60:
			game.debug_goto(&"r5", Vector2(900, 990))
			print("STAGE wall relic")
		80:
			print("ASSERT wall=", gm.relics["wall"])
		100:
			game.debug_goto(&"r6", Vector2(1100, 480))
			print("STAGE double relic")
		120:
			print("ASSERT double=", gm.relics["double"])
		140:
			game.debug_goto(&"r1", Vector2(260, 680))
			print("STAGE bench")
		150:
			Input.action_press("interact")
		156:
			Input.action_release("interact")
		172:
			print("ASSERT bench_room=", gm.bench_room, " bench_pos=", gm.bench_pos)
		190:
			game.debug_goto(&"r2", Vector2(600, 1200))
			gm.geo = 20
			gm.geo_changed.emit(gm.geo)
			print("STAGE death")
		200:
			var p = game.world.player
			p.invuln = 0.0
			p.take_damage(99, p.global_position + Vector2(50, 0))
		320:
			print("ASSERT shade_active=", not gm.shade.is_empty(), " geo=", gm.geo, " room=", game.world.room_id)
			game.debug_goto(&"r2", Vector2(600, 1200))
		340:
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/shade.gd"):
					shade_node = n
			print("ASSERT shade_found=", shade_node != null)
			if shade_node != null:
				shade_node.take_hit(99, Vector2.RIGHT, null)
		370:
			print("ASSERT geo_reclaimed=", gm.geo)
		400:
			game.debug_goto(&"r7", Vector2(400, 620))
			print("STAGE boss")
		420:
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/boss.gd"):
					boss_node = n
			print("ASSERT boss_found=", boss_node != null)
			if boss_node != null:
				boss_node.take_hit(60, Vector2.RIGHT, null)
		540:
			print("ASSERT boss_defeated=", gm.boss_defeated, " state=", game.state)
		560:
			print("ASSERT ending_state=", game.state)
			quit()
	return false
