extends Node2D

enum State { TITLE, PLAYING, DEAD, ENDING }

const HudScript := preload("res://scripts/hud.gd")

var state := State.TITLE
var world: GameWorld
var camera: CameraRig
var hud: Control
var fade_layer: CanvasLayer
var fade_rect: ColorRect
var transitioning := false
var paused := false
var map_open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.reset_run()
	_build()
	_enter_title()


func _build() -> void:
	world = GameWorld.new()
	world.name = "World"
	add_child(world)

	camera = CameraRig.new()
	camera.name = "Camera"
	add_child(camera)
	camera.make_current()
	world.set_camera(camera)

	var hud_layer := CanvasLayer.new()
	hud_layer.name = "HudLayer"
	hud_layer.layer = 10
	add_child(hud_layer)
	hud = HudScript.new()
	hud.name = "Hud"
	hud_layer.add_child(hud)

	fade_layer = CanvasLayer.new()
	fade_layer.name = "FadeLayer"
	fade_layer.layer = 20
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0.01, 0.012, 0.02, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.position = Vector2.ZERO
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_rect.modulate.a = 1.0
	fade_layer.add_child(fade_rect)

	world.transition_requested.connect(_on_transition_requested)
	world.player.died.connect(_on_player_died)
	world.player.attack_hit.connect(_on_attack_hit)
	world.player.damaged.connect(_on_player_damaged)
	world.player.focus_completed.connect(_on_focus_completed)
	Game.ending.connect(_on_ending)


func _enter_title() -> void:
	state = State.TITLE
	Game.running = false
	world.load_room(&"r1", -1)
	world.player.set_physics_process(false)
	world.player.control_enabled = false
	hud.set_title(true)
	var tw := create_tween()
	tw.tween_property(fade_rect, "modulate:a", 0.0, 0.8)


func debug_start() -> void:
	start_game()


func debug_cut(room_id: StringName, pos: Vector2) -> void:
	if transitioning:
		return
	transitioning = true
	await _fade_to(1.0, 0.18)
	debug_goto(room_id, pos)
	await get_tree().process_frame
	await _fade_to(0.0, 0.22)
	transitioning = false


func debug_goto(room_id: StringName, pos: Vector2) -> void:
	transitioning = false
	paused = false
	map_open = false
	get_tree().paused = false
	hud.set_paused(false)
	hud.set_map(false)
	state = State.PLAYING
	Game.running = true
	world.load_room_at(room_id, pos)
	world.player.respawn_at(pos)
	world.player.invuln = 0.0
	world.player.control_enabled = true


func start_game() -> void:
	if state != State.TITLE:
		return
	state = State.PLAYING
	Game.reset_run()
	Game.running = true
	world.load_room(&"r1", -1)
	world.player.set_physics_process(true)
	world.player.control_enabled = true
	world.player.visible = true
	hud.set_title(false)
	Game.toast.emit("遗迹在脚下沉眠。向前走，找回失落的回响。")
	var tw := create_tween()
	tw.tween_property(fade_rect, "modulate:a", 0.0, 0.5)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if state == State.TITLE:
		start_game()
		get_viewport().set_input_as_handled()
		return
	if state == State.ENDING:
		if event.keycode == KEY_R:
			_restart()
		return
	if state != State.PLAYING:
		return
	if event.is_action_pressed("pause"):
		_toggle_pause()
	elif event.is_action_pressed("map"):
		_toggle_map()


func _toggle_pause() -> void:
	if map_open:
		return
	paused = not paused
	get_tree().paused = paused
	hud.set_paused(paused)


func _toggle_map() -> void:
	map_open = not map_open
	paused = map_open
	get_tree().paused = paused
	hud.set_map(map_open)


func _fade_to(alpha: float, duration: float) -> void:
	var tw := create_tween()
	tw.tween_property(fade_rect, "modulate:a", alpha, duration)
	await tw.finished


func _on_transition_requested(target: StringName, door_index: int) -> void:
	if state != State.PLAYING or transitioning:
		return
	transitioning = true
	world.player.control_enabled = false
	await _fade_to(1.0, 0.22)
	world.load_room(target, door_index)
	await get_tree().process_frame
	world.player.control_enabled = true
	await _fade_to(0.0, 0.25)
	transitioning = false


func _on_player_died() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	Game.running = false
	world.player.control_enabled = false
	Game.on_player_death(world.room_id, world.player.global_position)
	await _fade_to(1.0, 0.55)
	await get_tree().create_timer(0.4).timeout
	var respawn_room := Game.bench_room
	var respawn_pos := Game.bench_pos
	world.load_room_at(respawn_room, respawn_pos)
	world.player.respawn_at(respawn_pos)
	state = State.PLAYING
	Game.running = true
	await _fade_to(0.0, 0.6)
	Game.toast.emit("你在长椅处苏醒。失去的吉欧仍留在倒下之处。")


func _on_attack_hit(_hit_pos: Vector2, _dir: Vector2) -> void:
	camera.add_shake(2.0)


func _on_player_damaged() -> void:
	camera.add_shake(9.0)


func _on_focus_completed() -> void:
	world.spawn_focus_burst(world.player.global_position + Vector2(0, -58))


func _on_ending() -> void:
	if state == State.ENDING:
		return
	state = State.ENDING
	Game.running = false
	world.player.control_enabled = false
	paused = false
	get_tree().paused = false
	hud.set_paused(false)
	hud.set_map(false)
	hud.show_ending()


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
