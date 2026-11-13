extends Node

var game
var frame := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	add_child(game)


func player():
	return game.world.player


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


func _process(_delta: float) -> void:
	frame += 1
	var gm = get_node_or_null("Game")
	if gm == null:
		gm = get_tree().root.get_node_or_null("Game")

	# ---------- title ----------
	if frame == 40:
		game.debug_start()

	# ---------- R8 静默集市: merchant, lorekeeper, market stalls ----------
	if frame == 56:
		game.debug_cut(&"r8", Vector2(560, 760))
	if frame == 66:
		var p = player()
		if p != null:
			p.debug_invincible = true
	if frame == 92:
		var merchant = find_npc("merchant")
		if merchant != null:
			game.open_dialogue(merchant)
	if frame == 132:
		game._advance_dialogue()
		game._advance_dialogue()
	if frame == 160:
		if gm != null:
			gm.geo = 120
			gm.geo_changed.emit(gm.geo)
		if game.dialogue_shop.size() >= 4:
			game.dialogue_index = 3
			game._attempt_purchase()
	if frame == 200:
		game._close_dialogue()
	if frame == 214:
		game.debug_cut(&"r8", Vector2(1270, 620))
	if frame == 236:
		var keeper = find_npc("lorekeeper")
		if keeper != null:
			game.open_dialogue(keeper)
	if frame == 276:
		game._advance_dialogue()
	if frame == 316:
		game._close_dialogue()

	# ---------- R9 钟鸣洞窟: new enemies ----------
	if frame == 336:
		game.debug_cut(&"r9", Vector2(560, 1200))
	if frame == 350:
		Input.action_press("move_left")
	if frame == 366:
		Input.action_press("attack")
	if frame == 372:
		Input.action_release("attack")
	if frame == 380:
		Input.action_press("attack")
	if frame == 386:
		Input.action_release("attack")
	if frame == 398:
		Input.action_release("move_left")
	if frame == 404:
		Input.action_press("move_right")
	if frame == 424:
		Input.action_press("jump")
	if frame == 432:
		Input.action_release("jump")
	if frame == 452:
		Input.action_release("move_right")
	if frame == 470:
		game.debug_cut(&"r9", Vector2(1980, 1200))
	if frame == 484:
		Input.action_press("attack")
	if frame == 490:
		Input.action_release("attack")

	# ---------- R10 回响之厅: optional boss ----------
	if frame == 510:
		game.debug_cut(&"r10", Vector2(320, 620))
	if frame == 524:
		Input.action_press("move_right")
	if frame == 596:
		Input.action_release("move_right")
	if frame == 604:
		Input.action_press("attack")
	if frame == 610:
		Input.action_release("attack")
	if frame == 620:
		var b = find_boss()
		if b != null:
			b.take_hit(14, Vector2.RIGHT, null)
	if frame == 660:
		var b2 = find_boss()
		if b2 != null:
			b2.take_hit(14, Vector2.RIGHT, null)

	# ---------- map with the new rooms ----------
	if frame == 700:
		game.hud.set_map(true)
		game.map_open = true
	if frame == 760:
		game.hud.set_map(false)
		game.map_open = false

	# ---------- boss reward ----------
	if frame == 820:
		var b3 = find_boss()
		if b3 != null:
			b3.take_hit(48, Vector2.RIGHT, null)
