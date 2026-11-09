extends SceneTree

var game
var frame := 0
var boss_hurt_phase := false
var boss_hurt_kill := false


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	root.add_child(game)


func player():
	return game.world.player


func boss():
	if game == null or game.world == null or game.world.room == null:
		return null
	for n in game.world.room.get_children():
		if n.get_script() == load("res://scripts/boss.gd"):
			return n
	return null


func _process(_delta: float) -> bool:
	frame += 1
	if frame % 30 == 0 and game != null and game.world != null:
		var p_dbg = game.world.player
		print("P%d room=%s pos=%s vel=%s paused=%s ts=%.2f" % [
			frame, str(game.world.room_id), str(p_dbg.global_position),
			str(p_dbg.velocity), str(paused), Engine.time_scale
		])

	# ---------- title ----------
	if frame == 60:
		game.debug_start()

	# ---------- R1: traversal, combat, room transition ----------
	if frame == 70:
		Input.action_press("move_right")
	if frame == 122:
		Input.action_press("jump")
	if frame == 130:
		Input.action_release("jump")
	if frame == 166:
		Input.action_press("attack")
	if frame == 173:
		Input.action_release("attack")
	if frame == 182:
		Input.action_press("attack")
	if frame == 189:
		Input.action_release("attack")
	if frame == 270:
		Input.action_release("move_right")
	if frame == 292:
		game.debug_cut(&"r3", Vector2(1500, 780))
	if frame == 302:
		var gm = root.get_node_or_null("Game")
		if gm != null:
			gm.masks = gm.max_masks
			gm.masks_changed.emit(gm.masks, gm.max_masks)
		var p0 = player()
		if p0 != null:
			p0.debug_invincible = true

	# ---------- R3: dash relic ----------
	if frame == 306:
		Input.action_press("move_right")
	if frame == 332:
		Input.action_release("move_right")
	if frame == 338:
		Input.action_press("move_right")
	if frame == 344:
		Input.action_press("dash")
	if frame == 349:
		Input.action_release("dash")
	if frame == 356:
		Input.action_release("move_right")
	if frame == 370:
		game.debug_cut(&"r4", Vector2(830, 1300))

	# ---------- R4: dash across the gap ----------
	if frame == 382:
		Input.action_press("move_right")
	if frame == 392:
		Input.action_press("jump")
	if frame == 398:
		Input.action_press("dash")
	if frame == 402:
		Input.action_release("dash")
	if frame == 400:
		Input.action_release("jump")
	if frame == 450:
		Input.action_release("move_right")
	if frame == 458:
		game.debug_cut(&"r5", Vector2(1000, 1000))

	# ---------- R5: wall cling relic + wall jump ----------
	if frame == 470:
		Input.action_press("move_left")
	if frame == 486:
		Input.action_release("move_left")
	if frame == 492:
		game.debug_cut(&"r5", Vector2(1500, 1340))
	if frame == 502:
		Input.action_press("move_right")
	if frame == 510:
		Input.action_press("jump")
	if frame == 516:
		Input.action_release("jump")
	if frame == 524:
		Input.action_press("jump")
	if frame == 530:
		Input.action_release("jump")
	if frame == 538:
		Input.action_release("move_right")
	if frame == 552:
		game.debug_cut(&"r6", Vector2(1180, 480))

	# ---------- R6: double jump relic ----------
	if frame == 564:
		Input.action_press("move_left")
	if frame == 574:
		Input.action_release("move_left")
	if frame == 586:
		Input.action_press("jump")
	if frame == 594:
		Input.action_release("jump")
	if frame == 602:
		Input.action_press("jump")
	if frame == 610:
		Input.action_release("jump")
	if frame == 655:
		game.debug_cut(&"r7", Vector2(350, 620))

	# ---------- R7: boss ----------
	if frame == 668:
		var p = player()
		if p != null:
			p.debug_invincible = true
	if frame == 672:
		Input.action_press("move_right")
	if frame == 738:
		Input.action_press("dash")
	if frame == 742:
		Input.action_release("dash")
	if frame == 746:
		Input.action_release("move_right")
	if frame == 750:
		Input.action_press("attack")
	if frame == 756:
		Input.action_release("attack")
	if frame == 762:
		var b = boss()
		if b != null:
			b.take_hit(30, Vector2.RIGHT, null)
	if frame == 768:
		Input.action_press("attack")
	if frame == 774:
		Input.action_release("attack")
	if frame == 780:
		var b2 = boss()
		if b2 != null:
			b2.take_hit(60, Vector2.RIGHT, null)

	if frame >= 900:
		quit()

	return false
