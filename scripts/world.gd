class_name GameWorld
extends Node2D

signal room_loaded(room_id: StringName, room_name: String)
signal transition_requested(target: StringName, door_index: int)

var player: Player
var room: Room
var room_id: StringName = &"r1"
var camera: CameraRig
var backdrop: Backdrop
var transition_cooldown := 0.0


func _ready() -> void:
	add_to_group("world")
	var canvas := CanvasLayer.new()
	canvas.layer = -10
	add_child(canvas)
	backdrop = Backdrop.new()
	backdrop.name = "Backdrop"
	canvas.add_child(backdrop)

	player = Player.new()
	player.name = "Player"
	add_child(player)
	player.focus_completed.connect(_on_focus_completed)


func set_camera(cam: CameraRig) -> void:
	camera = cam
	camera.target = player
	backdrop.camera = cam


func _physics_process(delta: float) -> void:
	transition_cooldown = maxf(0.0, transition_cooldown - delta)


func load_room(id: StringName, door_index := -1, custom_pos = null) -> void:
	if room != null:
		room.free()
		room = null
	var data := RoomData.get_room(id)
	room = Room.new()
	room.name = "Room"
	room.setup(data)
	add_child(room)
	move_child(room, 0)
	room.door_entered.connect(_on_door_entered)

	var spawn: Vector2 = data.get("spawn", Vector2(200, 400))
	if custom_pos != null:
		spawn = custom_pos
	elif door_index >= 0:
		var dlist: Array = data.get("doors", [])
		if door_index < dlist.size():
			spawn = dlist[door_index].get("spawn", spawn)

	player.position = spawn
	player.velocity = Vector2.ZERO

	room_id = id
	Game.current_room = id
	Game.visited[id] = true
	var rname: String = data.get("name", "")
	Game.room_changed.emit(id, rname)

	backdrop.setup(data.get("theme", {}), int(data.get("seed", 1)))
	if camera != null:
		camera.set_bounds(Rect2(Vector2.ZERO, data.get("size", Vector2(1280, 720))))
		camera.snap_to_target()

	_spawn_shade_if_needed()
	transition_cooldown = 0.5
	room_loaded.emit(id, rname)


func load_room_at(id: StringName, pos: Vector2) -> void:
	load_room(id, -1, pos)


func _on_door_entered(target: StringName, door_index: int) -> void:
	if transition_cooldown > 0.0:
		return
	transition_requested.emit(target, door_index)


func _spawn_shade_if_needed() -> void:
	if Game.shade.is_empty():
		return
	if StringName(Game.shade.get("room", &"")) != room_id:
		return
	var scr := _load_script("res://scripts/shade.gd")
	if scr == null:
		return
	var node = scr.new()
	node.setup_shade(Game.shade.get("pos", Vector2(400, 400)))
	room.add_child(node)


func _load_script(path: String) -> GDScript:
	if ResourceLoader.exists(path):
		return load(path) as GDScript
	return null


func _fx_parent() -> Node:
	return room if room != null else self


func spawn_hit(pos: Vector2, _dir: Vector2) -> void:
	var burst := SparkBurst.new()
	burst.setup(pos, Utils.C_GLOW, 11, 280.0, 3.2, 0.42)
	_fx_parent().add_child(burst)
	if camera != null:
		camera.add_shake(3.0)


func spawn_death_burst(pos: Vector2, color: Color) -> void:
	var burst := SparkBurst.new()
	burst.setup(pos, color, 24, 360.0, 4.0, 0.8, TAU)
	_fx_parent().add_child(burst)


func spawn_focus_burst(pos: Vector2) -> void:
	var burst := SparkBurst.new()
	burst.setup(pos, Utils.C_SOUL, 14, 160.0, 3.0, 0.6, TAU)
	_fx_parent().add_child(burst)


func spawn_geo(pos: Vector2, amount: int) -> void:
	var scr := _load_script("res://scripts/pickup.gd")
	if scr == null:
		return
	var node = scr.new()
	node.setup_geo(pos, amount)
	_fx_parent().add_child(node)


func spawn_spell(pos: Vector2, facing: int) -> void:
	var scr := _load_script("res://scripts/projectile.gd")
	if scr == null:
		return
	var node = scr.new()
	node.setup_spell(pos, facing)
	_fx_parent().add_child(node)


func spawn_shockwave(pos: Vector2, dir: int) -> void:
	var scr := _load_script("res://scripts/projectile.gd")
	if scr == null:
		return
	var node = scr.new()
	node.setup_shockwave(pos, dir)
	_fx_parent().add_child(node)


func _on_focus_completed() -> void:
	spawn_focus_burst(player.global_position + Vector2(0, -58))
