extends SceneTree

var game
var frame := 0


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate()
	root.add_child(game)


func _process(_delta: float) -> bool:
	frame += 1

	if frame == 4:
		game.debug_start()
		print("ASSERT started")
	if frame == 24:
		Input.action_press("move_right")
	if frame >= 30 and frame % 30 == 0:
		var p = game.world.player
		var gm = root.get_node_or_null("Game")
		var masks := -1
		var geo := -1
		if gm != null:
			masks = gm.masks
			geo = gm.geo
		print("T%d pos=%s vel=%s room=%s masks=%d geo=%d" % [
			frame, str(p.global_position), str(p.velocity), str(game.world.room_id),
			masks, geo
		])
	if frame == 110:
		Input.action_press("jump")
	if frame == 118:
		Input.action_release("jump")
	if frame == 150:
		Input.action_press("attack")
	if frame == 160:
		Input.action_release("attack")
	if frame == 190:
		Input.action_press("dash")
	if frame == 196:
		Input.action_release("dash")
	if frame == 240:
		Input.action_press("attack")
	if frame == 250:
		Input.action_release("attack")
	if frame == 300:
		Input.action_release("move_right")
	if frame == 310:
		var p = game.world.player
		print("ASSERT pos=", p.global_position, " on_floor=", p.is_on_floor(), " room=", game.world.room_id)
	if frame >= 420:
		quit()

	return false
