extends Node

var game
var frame := 0
var moment := "market"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--moment="):
			moment = arg.substr(9)
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	add_child(game)


func find_npc(id: String):
	if game.world.room == null:
		return null
	for n in game.world.room.get_children():
		if n.get_script() == load("res://scripts/npc.gd") and String(n.npc_id) == id:
			return n
	return null


func find_boss():
	if game.world.room == null:
		return null
	for n in game.world.room.get_children():
		if n.get_script() == load("res://scripts/boss.gd"):
			return n
	return null


func _setup() -> void:
	var gm = get_tree().root.get_node_or_null("Game")
	game.debug_start()
	var p = game.world.player
	if p != null:
		p.debug_invincible = true
	match moment:
		"market":
			game.debug_goto(&"r8", Vector2(600, 760))
		"shop":
			game.debug_goto(&"r8", Vector2(600, 760))
			if gm != null:
				gm.geo = 120
				gm.geo_changed.emit(gm.geo)
			game.open_dialogue(find_npc("merchant"))
		"lore":
			game.debug_goto(&"r8", Vector2(1270, 620))
			game.open_dialogue(find_npc("lorekeeper"))
		"cavern":
			game.debug_goto(&"r9", Vector2(1980, 1200))
		"mask":
			game.debug_goto(&"r9", Vector2(2050, 860))
		"boss":
			game.debug_goto(&"r10", Vector2(700, 620))
		"map":
			game.debug_goto(&"r1", Vector2(360, 680))
			game.debug_goto(&"r2", Vector2(170, 1200))
			game.debug_goto(&"r3", Vector2(170, 780))
			game.debug_goto(&"r8", Vector2(600, 760))
		"map_all":
			if gm != null:
				for i in range(1, 15):
					gm.visited[StringName("r%d" % i)] = true
			game.debug_goto(&"r1", Vector2(360, 680))
		"reward":
			game.debug_goto(&"r10", Vector2(700, 620))
		"passage":
			game.debug_goto(&"r11", Vector2(1640, 1100))
		"secret":
			game.debug_goto(&"r6", Vector2(1420, 600))
		"feather":
			game.debug_goto(&"r11", Vector2(180, 640))
		"pain":
			game.debug_goto(&"r12", Vector2(420, 1200))
		"pain_mid":
			game.debug_goto(&"r12", Vector2(1450, 800))
		"pain_deep":
			game.debug_goto(&"r13", Vector2(980, 1800))
		"heart":
			game.debug_goto(&"r14", Vector2(560, 700))
		"charms":
			game.debug_goto(&"r14", Vector2(560, 700))
			if gm != null:
				gm.gain_item(&"feather", "轻羽斗篷")
				gm.gain_item(&"lantern", "守梦者之灯")
				gm.gain_item(&"pain_heart", "苦痛之心")
		"mobile":
			game.debug_goto(&"r8", Vector2(600, 760))
			if gm != null:
				gm.touch_mode = true
			if game.touch != null:
				game.touch.visible = true
				game.touch.set_process(true)
				game.touch.set_process_input(true)
				game.touch.size = Vector2(1280, 720)
				game.touch._layout()


func _process(_delta: float) -> void:
	frame += 1
	if frame == 5:
		_setup()
	if moment == "shop" and frame == 16:
		game._advance_dialogue()
		game._advance_dialogue()
	if moment == "map" and frame == 120:
		game._toggle_map()
	if moment == "map_all" and frame == 30:
		game._toggle_map()
	if moment == "boss" and frame == 32:
		var b = find_boss()
		if b != null:
			b.take_hit(26, Vector2.RIGHT, null)
	if moment == "reward" and frame == 24:
		var b2 = find_boss()
		if b2 != null:
			b2.take_hit(48, Vector2.RIGHT, null)
