extends SceneTree

# 苦痛之路的平台机制回归：移动石台必须把玩家一起带走（水平/垂直）。

var game
var gm
var frame := 0
var mover = null


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	root.add_child(game)


func _find_mover(index: int = 0):
	if game.world.room == null:
		return null
	var found := 0
	for child in game.world.room.get_children():
		if child.get_script() == load("res://scripts/moving_platform.gd"):
			if found == index:
				return child
			found += 1
	return null


func _process(_delta: float) -> bool:
	frame += 1
	if gm == null:
		gm = root.get_node_or_null("Game")

	match frame:
		4:
			game.debug_start()
		20:
			game.debug_goto(&"r12", Vector2(170, 1200))
			var p = game.world.player
			p.debug_invincible = true
			p.invuln = 999.0
		30:
			mover = _find_mover(0)
			var p = game.world.player
			if mover != null:
				p.global_position = mover.global_position + Vector2(0, -13)
				p.velocity = Vector2.ZERO
			print("ASSERT h_platform_found=", mover != null, " pos=", mover.position if mover != null else "-")
		80:
			var p = game.world.player
			if mover != null:
				var dx: float = absf(p.global_position.x - mover.global_position.x)
				print("ASSERT horizontal_carry=", dx < 46.0 and p.is_on_floor(),
					" dx=", dx, " on_floor=", p.is_on_floor())
		90:
			game.debug_goto(&"r13", Vector2(180, 2400))
			var p2 = game.world.player
			p2.debug_invincible = true
			p2.invuln = 999.0
		100:
			mover = _find_mover(0)
			var p3 = game.world.player
			if mover != null:
				p3.global_position = mover.global_position + Vector2(0, -13)
				p3.velocity = Vector2.ZERO
			print("ASSERT v_platform_found=", mover != null, " pos=", mover.position if mover != null else "-")
		150:
			var p4 = game.world.player
			if mover != null:
				var dy: float = absf(p4.global_position.y - (mover.global_position.y - 12.0))
				print("ASSERT vertical_carry=", dy < 32.0 and p4.is_on_floor(),
					" dy=", dy, " on_floor=", p4.is_on_floor())
		160:
			quit()
	return false
