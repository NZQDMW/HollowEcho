extends SceneTree

# 回归测试：王座密道 / 苦痛之路 / 特殊道具 / 新房间与地图连通性。
# 遵循 SceneTree 脚本的编译顺序限制：不直接引用 Game 或依赖 Game 的全局类，
# 一律通过 root.get_node("Game") 与 load(...) 访问。

var game
var gm
var frame := 0
var flat_before := 0
var soul_before := 0.0
var mover_before := Vector2.ZERO


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


func _surface_under(room_data: Dictionary, pos: Vector2) -> bool:
	var rects: Array = []
	rects.append_array(room_data.get("ground", []))
	rects.append_array(room_data.get("ledges", []))
	for entry in rects:
		var r: Rect2 = entry["rect"]
		if pos.x >= r.position.x - 4.0 and pos.x <= r.end.x + 4.0:
			if absf(pos.y - r.position.y) <= 12.0:
				return true
	return false


func _process(_delta: float) -> bool:
	frame += 1
	if gm == null:
		gm = root.get_node_or_null("Game")

	match frame:
		4:
			game.debug_start()

		# ---------- 静态结构：房间、门、连通性 ----------
		20:
			var rd = load("res://scripts/room_data.gd")
			var ids := [&"r11", &"r12", &"r13", &"r14"]
			var names_ok := true
			for id in ids:
				var data: Dictionary = rd.get_room(id)
				if data.is_empty() or String(data.get("name", "")) == "":
					names_ok = false
			print("ASSERT new_rooms=", names_ok,
				" names=", rd.room_name(&"r11"), "/", rd.room_name(&"r12"), "/",
				rd.room_name(&"r13"), "/", rd.room_name(&"r14"))
			var doors_ok := true
			var spawns_ok := true
			for i in range(1, 15):
				var rid := StringName("r%d" % i)
				var data: Dictionary = rd.get_room(rid)
				var size: Vector2 = data.get("size", Vector2.ZERO)
				var dlist: Array = data.get("doors", [])
				for d in dlist:
					var target: StringName = d["target"]
					var tdata: Dictionary = rd.get_room(target)
					if tdata.is_empty() or String(tdata.get("name", "")) == "未知之地":
						doors_ok = false
						continue
					var ti := int(d["target_door"])
					var tdoors: Array = tdata.get("doors", [])
					if ti < 0 or ti >= tdoors.size():
						doors_ok = false
						continue
					var back: Dictionary = tdoors[ti]
					if StringName(back["target"]) != rid:
						doors_ok = false
					var sp: Vector2 = d["spawn"]
					if sp.x < 0.0 or sp.y < 0.0 or sp.x > size.x or sp.y > size.y:
						spawns_ok = false
					if rid in ids and not _surface_under(data, sp):
						print("  BAD SPAWN ", rid, " ", sp)
						spawns_ok = false
			print("ASSERT door_reciprocity=", doors_ok, " door_spawns=", spawns_ok)

		# ---------- r11 王座密道 + 特殊道具：轻羽斗篷 ----------
		30:
			game.debug_goto(&"r11", Vector2(1700, 1100))
		40:
			var special_count := 0
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/pickup.gd") and int(n.kind) == 3:
					special_count += 1
			print("ASSERT r11=", game.world.room.room_name,
				" specials=", special_count,
				" enemies=", _count_script("res://scripts/crawler.gd") + _count_script("res://scripts/flyer.gd"))
			var p = game.world.player
			p.respawn_at(Vector2(380, 320))
			p.invuln = 5.0
		50:
			print("ASSERT feather=", gm.has_item(&"feather"), " dash_charm=", gm.dash_charm)
		60:
			game.debug_goto(&"r11", Vector2(1700, 1100))
		66:
			var feather_pickups := 0
			for n in game.world.room.get_children():
				if n.get_script() == load("res://scripts/pickup.gd") and int(n.kind) == 3 \
					and String(n.special_id) == "feather":
					feather_pickups += 1
			print("ASSERT feather_not_respawn=", feather_pickups == 0)

		# ---------- r12 苦痛之路·回廊：移动台 / 碎裂台 / 锯刃 / 深坑 ----------
		76:
			game.debug_goto(&"r12", Vector2(300, 1200))
		86:
			var movers := _count_script("res://scripts/moving_platform.gd")
			var crumbles := _count_script("res://scripts/crumble_platform.gd")
			var saws := _count_script("res://scripts/sawblade.gd")
			var pits: int = game.world.room.pits.size()
			print("ASSERT r12=", game.world.room.room_name,
				" movers=", movers, " crumble=", crumbles, " saws=", saws, " pits=", pits)
			var mover = _find_script("res://scripts/moving_platform.gd")
			mover_before = mover.position if mover != null else Vector2.ZERO
		96:
			var mover2 = _find_script("res://scripts/moving_platform.gd")
			print("ASSERT mover_moves=", mover2 != null and mover2.position.distance_to(mover_before) > 1.0,
				" delta=", mover2.position.distance_to(mover_before) if mover2 != null else -1.0)
			# 锯刃伤害
			var saw = _find_script("res://scripts/sawblade.gd")
			gm.masks = 4
			gm.masks_changed.emit(gm.masks, gm.max_masks)
			var p2 = game.world.player
			p2.invuln = 0.0
			p2.debug_invincible = false
			if saw != null:
				p2.global_position = saw.global_position + Vector2(0, 48)
				p2.velocity = Vector2.ZERO
		104:
			var p3 = game.world.player
			print("ASSERT saw_damage masks=", gm.masks, " invuln=", p3.invuln > 0.0)
			# 碎裂台被踩后消失（直接推进计时，避免依赖帧率）
			var crumbler = _find_script("res://scripts/crumble_platform.gd")
			if crumbler != null:
				crumbler._on_body_entered(p3)
				var triggered := int(crumbler.state) == 1
				crumbler._process(0.7)
				print("ASSERT crumble_triggered=", triggered, " crumble_gone=", int(crumbler.state) == 2)

		# ---------- r13 苦痛之路·深井 ----------
		140:
			game.debug_goto(&"r13", Vector2(300, 2400))
		150:
			print("ASSERT r13=", game.world.room.room_name,
				" movers=", _count_script("res://scripts/moving_platform.gd"),
				" saws=", _count_script("res://scripts/sawblade.gd"),
				" walls=", game.world.room.data.get("walls", []).size(),
				" pits=", game.world.room.pits.size())

		# ---------- r14 王座之心：苦痛之心 ----------
		160:
			flat_before = gm.nail_bonus
			soul_before = gm.soul_gain_bonus
			game.debug_goto(&"r14", Vector2(700, 640))
			var p4 = game.world.player
			p4.invuln = 5.0
		170:
			print("ASSERT r14=", game.world.room.room_name,
				" pain_heart=", gm.has_item(&"pain_heart"),
				" nail_bonus=", gm.nail_bonus, " (was ", flat_before, ")",
				" soul_gain=", gm.soul_gain_bonus, " (was ", soul_before, ")",
				" bench=", _count_script("res://scripts/bench.gd"))

		# ---------- 商店特殊道具：守梦者之灯 ----------
		180:
			var nd = load("res://scripts/npc_data.gd")
			var merchant: Dictionary = nd.get_npc(&"merchant")
			var items: Array = merchant.get("shop", [])
			var lantern_ok := false
			if items.size() >= 5:
				var row: Dictionary = items[4]
				if String(row.get("key", "")) == "lantern":
					gm.geo = 500
					gm.geo_changed.emit(gm.geo)
					lantern_ok = gm.purchase(row)
			print("ASSERT lantern_bought=", lantern_ok, " has_lantern=", gm.has_item(&"lantern"),
				" focus_scale=", gm.focus_scale, " max_soul=", gm.max_soul,
				" shop_rows=", items.size())

		# ---------- 地图包含全部 14 个房间 ----------
		190:
			var ids_ok := true
			for i in range(1, 15):
				if not game.hud.map_rooms.has(StringName("r%d" % i)):
					ids_ok = false
			var links_ok := true
			for link in game.hud.map_links:
				if not game.hud.map_rooms.has(link[0]) or not game.hud.map_rooms.has(link[1]):
					links_ok = false
			print("ASSERT map_rooms=", game.hud.map_rooms.size(), " all_ids=", ids_ok, " links=", links_ok)

		# ---------- 死亡后特殊道具仍然保留 ----------
		200:
			var p5 = game.world.player
			p5.invuln = 0.0
			gm.masks = 1
			gm.masks_changed.emit(gm.masks, gm.max_masks)
			p5.take_damage(5, p5.global_position + Vector2(60, 0))
		230:
			print("ASSERT after_death items=", gm.has_item(&"feather"), "/", gm.has_item(&"pain_heart"),
				"/", gm.has_item(&"lantern"), " state=", game.state, " masks=", gm.masks)
		250:
			quit()
	return false
