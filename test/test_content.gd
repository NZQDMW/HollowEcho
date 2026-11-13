extends SceneTree

var game
var gm
var frame := 0
var gate_node
var merchant
var boss_node


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	root.add_child(game)


func _count_script(script_path: String) -> int:
	var n := 0
	if game.world.room == null:
		return 0
	for child in game.world.room.get_children():
		if child.get_script() == load(script_path):
			n += 1
	return n


func _find_script(script_path: String):
	if game.world.room == null:
		return null
	for child in game.world.room.get_children():
		if child.get_script() == load(script_path):
			return child
	return null


func _process(_delta: float) -> bool:
	frame += 1
	if gm == null:
		gm = root.get_node_or_null("Game")

	match frame:
		4:
			game.debug_start()
		20:
			game.debug_goto(&"r8", Vector2(600, 760))
		26:
			print("ASSERT r8=", game.world.room.room_name,
				" npcs=", _count_script("res://scripts/npc.gd"),
				" doors=", game.world.room.doors.size())
			gate_node = _find_script("res://scripts/gate.gd")
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/npc.gd") and String(n.npc_id) == "merchant":
					merchant = n
			print("ASSERT gate_locked=", gate_node.locked if gate_node != null else "none",
				" merchant=", merchant != null)
		34:
			gm.geo = 300
			gm.geo_changed.emit(gm.geo)
			game.open_dialogue(merchant)
			print("ASSERT dialogue_open=", game.dialogue_open, " paused=", paused,
				" mode=", game.dialogue_mode)
		44:
			game._advance_dialogue()
			game._advance_dialogue()
			print("ASSERT shop_mode=", game.dialogue_mode, " rows=", game.dialogue_shop.size())
		50:
			var key_item = game.dialogue_shop[3]
			var ok = gm.purchase(key_item)
			print("ASSERT key_bought=", ok, " geo=", gm.geo,
				" has_key=", gm.has_relic(&"key"), " gate_locked=", gate_node.locked)
		58:
			var mask_item = game.dialogue_shop[0]
			var ok2 = gm.purchase(mask_item)
			print("ASSERT mask_bought=", ok2, " max_masks=", gm.max_masks, " masks=", gm.masks)
		64:
			var mask_item = game.dialogue_shop[0]
			var ok3 = gm.purchase(mask_item)
			var ok4 = gm.purchase(mask_item)
			print("ASSERT mask_limit=", ok4, " second_buy=", ok3, " max_masks=", gm.max_masks,
				" bought=", gm.shop_bought(&"mask"))
		72:
			game._close_dialogue()
			print("ASSERT dialogue_closed=", not game.dialogue_open, " paused=", paused)
		82:
			game.debug_goto(&"r8", Vector2(1270, 620))
		90:
			var keeper = null
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/npc.gd") and String(n.npc_id) == "lorekeeper":
					keeper = n
			game.open_dialogue(keeper)
			game.dialogue_page = game.dialogue_pages.size() - 1
			game._sync_dialogue_hud()
			print("ASSERT lore_open=", game.dialogue_open, " pages=", game.dialogue_pages.size())
		96:
			Input.action_press("interact")
		101:
			Input.action_release("interact")
		114:
			print("ASSERT dialogue_e_closed=", not game.dialogue_open, " paused=", paused)
		122:
			print("ASSERT dialogue_no_reopen=", not game.dialogue_open, " paused=", paused)
		134:
			game.debug_goto(&"r9", Vector2(300, 1200))
		142:
			print("ASSERT r9=", game.world.room.room_name,
				" new_enemies=", _count_script("res://scripts/spitter.gd") + _count_script("res://scripts/hopper.gd"),
				" pickups=", _count_script("res://scripts/pickup.gd"))
		148:
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/pickup.gd") and int(n.kind) == 2:
					n._on_body_entered(game.world.player)
			print("ASSERT shard_max_masks=", gm.max_masks)
		158:
			game.debug_goto(&"r10", Vector2(400, 620))
		164:
			boss_node = _find_script("res://scripts/boss.gd")
			print("ASSERT boss_found=", boss_node != null,
				" name=", boss_node.boss_name if boss_node != null else "-",
				" hp=", boss_node.max_hp if boss_node != null else -1,
				" final=", boss_node.final_boss if boss_node != null else "?")
		170:
			boss_node.take_hit(48, Vector2.RIGHT, null)
			print("ASSERT boss_defeated=", gm.bosses_defeated.has("bell"),
				" echo=", gm.has_relic(&"echo"), " nail_bonus=", gm.nail_bonus,
				" max_soul=", gm.max_soul)
		178:
			print("ASSERT state_after_optional_boss=", game.state)
		190:
			game.debug_goto(&"r10", Vector2(400, 620))
		196:
			print("ASSERT boss_remains_defeated=", _count_script("res://scripts/boss.gd") == 0)
		204:
			quit()
	return false
