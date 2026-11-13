extends Control

# 手机端触摸控制：左侧虚拟摇杆 + 右侧动作键 + 地图/暂停键。
# 只在触摸设备（手机/平板/触屏浏览器）上显示；桌面保持原有键盘操作。

const STICK_RADIUS := 104.0
const STICK_DEADZONE := 0.18
const AIM_IN := 0.55
const AIM_OUT := 0.35
const TAP_HOLD := 0.12
const MIN_HOLD := 0.08

var time := 0.0
var stick_center := Vector2.ZERO
var stick_knob := Vector2.ZERO
var stick_index := -1
var stick_live := false
var aim_state := 0
var touch_owner := {}
var button_down := {}
var pending_release := {}
var buttons: Array = []
var last_size := Vector2.ZERO
var game_root: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	Game.touch_mode = visible
	game_root = get_tree().get_first_node_in_group("game_root")
	if not visible:
		set_process(false)
		set_process_input(false)
	_layout()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_release_all()


func _layout() -> void:
	var w := size.x
	var h := size.y
	if w < 64.0 or h < 64.0:
		w = 1280.0
		h = 720.0
	last_size = size
	stick_center = Vector2(168.0, h - 152.0)
	buttons = [
		{"name": "jump", "label": "跳", "action": "jump", "pos": Vector2(w - 116.0, h - 116.0), "r": 62.0, "hold": true},
		{"name": "attack", "label": "打", "action": "attack", "pos": Vector2(w - 248.0, h - 150.0), "r": 54.0, "hold": false},
		{"name": "dash", "label": "冲", "action": "dash", "pos": Vector2(w - 104.0, h - 270.0), "r": 44.0, "hold": false},
		{"name": "spell", "label": "法", "action": "spell", "pos": Vector2(w - 214.0, h - 294.0), "r": 40.0, "hold": false},
		{"name": "focus", "label": "聚", "action": "focus", "pos": Vector2(w - 324.0, h - 250.0), "r": 38.0, "hold": true},
		{"name": "interact", "label": "互", "action": "interact", "pos": Vector2(w - 340.0, h - 136.0), "r": 36.0, "hold": false},
		{"name": "map", "label": "图", "action": "map", "pos": Vector2(w - 248.0, 132.0), "r": 28.0, "hold": false},
		{"name": "pause", "label": "停", "action": "pause", "pos": Vector2(w - 58.0, 132.0), "r": 28.0, "hold": false},
	]


func _process(delta: float) -> void:
	time += delta
	for action in pending_release.keys():
		var left := float(pending_release[action]) - delta
		if left <= 0.0:
			pending_release.erase(action)
			_release_action(String(action))
		else:
			pending_release[action] = left
	if last_size != size:
		_layout()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var st := _game_state()
	if st == 0 or st == 3:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_down(event.index, event.position):
				get_viewport().set_input_as_handled()
		else:
			touch_up(event.index)
	elif event is InputEventScreenDrag:
		touch_drag(event.index, event.position)


func touch_down(index: int, pos: Vector2) -> bool:
	if _overlay_open():
		var sys := _system_button_at(pos)
		if sys.is_empty():
			return false
		var sname := String(sys["name"])
		touch_owner[index] = sname
		button_down[sname] = time
		if sname == "pause":
			_game_call("touch_toggle_pause")
		else:
			_game_call("touch_toggle_map")
		return true
	if stick_index < 0 and pos.distance_to(stick_center) <= STICK_RADIUS * 1.28:
		stick_index = index
		stick_live = true
		_update_stick(pos)
		return true
	var b := _button_at(pos)
	if b.is_empty():
		return false
	var name := String(b["name"])
	touch_owner[index] = name
	button_down[name] = time
	if String(b["action"]) == "pause":
		_game_call("touch_toggle_pause")
		return true
	if String(b["action"]) == "map":
		_game_call("touch_toggle_map")
		return true
	Input.action_press(String(b["action"]))
	if not bool(b["hold"]):
		pending_release[String(b["action"])] = TAP_HOLD
	return true


func touch_drag(index: int, pos: Vector2) -> void:
	if index == stick_index:
		_update_stick(pos)


func touch_up(index: int) -> void:
	if index == stick_index:
		stick_index = -1
		stick_live = false
		stick_knob = Vector2.ZERO
		aim_state = 0
		_release_action("move_left")
		_release_action("move_right")
		_release_action("aim_up")
		_release_action("aim_down")
		return
	var name := String(touch_owner.get(index, ""))
	if name.is_empty():
		return
	touch_owner.erase(index)
	var b := _button_by_name(name)
	if b.is_empty():
		return
	var action := String(b["action"])
	if action == "pause" or action == "map":
		return
	if bool(b["hold"]):
		var held := time - float(button_down.get(name, time))
		if held < MIN_HOLD:
			pending_release[action] = maxf(float(pending_release.get(action, 0.0)), MIN_HOLD - held)
		else:
			_release_action(action)


func _update_stick(pos: Vector2) -> void:
	var v := pos - stick_center
	stick_knob = v.limit_length(STICK_RADIUS)
	var nx := clampf(v.x / STICK_RADIUS, -1.0, 1.0)
	var ny := clampf(v.y / STICK_RADIUS, -1.0, 1.0)
	if absf(nx) > STICK_DEADZONE:
		if nx > 0.0:
			Input.action_press("move_right", absf(nx))
			Input.action_release("move_left")
		else:
			Input.action_press("move_left", absf(nx))
			Input.action_release("move_right")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")

	var next_aim := 0
	if ny < -AIM_IN:
		next_aim = -1
	elif ny > AIM_IN:
		next_aim = 1
	elif absf(ny) < AIM_OUT:
		next_aim = 0
	else:
		next_aim = aim_state
	if next_aim != aim_state:
		aim_state = next_aim
		Input.action_release("aim_up")
		Input.action_release("aim_down")
		if aim_state < 0:
			Input.action_press("aim_up")
		elif aim_state > 0:
			Input.action_press("aim_down")


func _button_at(pos: Vector2) -> Dictionary:
	for i in range(buttons.size() - 1, -1, -1):
		var b: Dictionary = buttons[i]
		if pos.distance_to(b["pos"]) <= float(b["r"]) * 1.16:
			return b
	return {}


func _button_by_name(name: String) -> Dictionary:
	for b in buttons:
		if String(b["name"]) == name:
			return b
	return {}


func _release_action(action: String) -> void:
	if action == "pause" or action == "map":
		return
	Input.action_release(action)


func _game_call(method: String) -> void:
	if game_root == null or not is_instance_valid(game_root):
		game_root = get_tree().get_first_node_in_group("game_root")
	if game_root != null and game_root.has_method(method):
		game_root.call(method)


func _release_all() -> void:
	stick_index = -1
	stick_live = false
	stick_knob = Vector2.ZERO
	aim_state = 0
	touch_owner.clear()
	button_down.clear()
	pending_release.clear()
	for action in ["move_left", "move_right", "aim_up", "aim_down", "jump",
			"attack", "dash", "spell", "focus", "interact"]:
		Input.action_release(action)


func is_portrait() -> bool:
	var win := get_window()
	if win == null:
		return false
	var ws := win.size
	return ws.y > ws.x


func _game_root_node() -> Node:
	if game_root == null or not is_instance_valid(game_root):
		game_root = get_tree().get_first_node_in_group("game_root")
	return game_root


func _game_state() -> int:
	var root := _game_root_node()
	if root == null:
		return -1
	return int(root.get("state"))


func _overlay_open() -> bool:
	var root := _game_root_node()
	if root == null:
		return false
	return bool(root.get("map_open")) or bool(root.get("paused"))


func _system_allowed(button_name: String) -> bool:
	var root := _game_root_node()
	if root == null:
		return button_name == "map" or button_name == "pause"
	var map_open := bool(root.get("map_open"))
	var is_paused := bool(root.get("paused"))
	if map_open:
		return button_name == "map"
	if is_paused:
		return button_name == "pause"
	return button_name == "map" or button_name == "pause"


func _system_button_at(pos: Vector2) -> Dictionary:
	for b in buttons:
		var n := String(b["name"])
		if not _system_allowed(n):
			continue
		if pos.distance_to(b["pos"]) <= float(b["r"]) * 1.16:
			return b
	return {}


func _draw() -> void:
	if not visible:
		return
	var font := Utils.font()
	var w := size.x
	var h := size.y
	var overlay_open := _overlay_open()

	if not overlay_open:
		# --- 虚拟摇杆 ---
		draw_circle(stick_center, STICK_RADIUS, Color(0.02, 0.04, 0.06, 0.34))
		draw_arc(stick_center, STICK_RADIUS, 0.0, TAU, 48, Color(Utils.C_RIM, 0.38), 2.0, true)
		draw_arc(stick_center, STICK_RADIUS * 0.62, 0.0, TAU, 40, Color(Utils.C_RIM, 0.16), 1.2, true)
		var knob := stick_center + stick_knob
		draw_circle(knob, 44.0, Color(Utils.C_SLATE, 0.62))
		draw_arc(knob, 44.0, 0.0, TAU, 36, Color(Utils.C_GLOW, 0.7), 2.0, true)
		draw_circle(knob, 16.0, Color(Utils.C_GLOW, 0.34))
		var move_sz := font.get_string_size("移动", HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		draw_string(font, stick_center + Vector2(-move_sz.x * 0.5, STICK_RADIUS + 26.0), "移动",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Utils.C_TEXT_DIM, 0.75))

	# --- 动作键（地图/暂停浮层打开时只保留右上角的图/停）---
	for b in buttons:
		if overlay_open and not _system_allowed(String(b["name"])):
			continue
		var bname := String(b["name"])
		var c: Vector2 = b["pos"]
		var r: float = b["r"]
		var pressed := false
		for idx in touch_owner:
			if String(touch_owner[idx]) == bname:
				pressed = true
		var fill := Color(0.05, 0.1, 0.14, 0.55 if not pressed else 0.82)
		draw_circle(c, r, fill)
		draw_arc(c, r, 0.0, TAU, 40, Color(Utils.C_RIM, 0.55 if pressed else 0.34), 2.2, true)
		var label: String = b["label"]
		var sz := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, int(r * 0.62))
		draw_string(font, c + Vector2(-sz.x * 0.5, sz.y * 0.34), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, int(r * 0.62), Color(Utils.C_IVORY, 0.9))

	# --- 竖屏提示（覆盖整个游戏区域）---
	if is_portrait():
		draw_rect(Rect2(0, 0, w, h), Color(0.006, 0.01, 0.018, 0.88))
		var title := "请横屏游玩"
		var tsz := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 46)
		draw_string(font, Vector2((w - tsz.x) * 0.5, h * 0.46), title,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Utils.C_IVORY)
		var tip := "旋转设备，让摇杆出现在左下角"
		var ssz := font.get_string_size(tip, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
		draw_string(font, Vector2((w - ssz.x) * 0.5, h * 0.53), tip,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Utils.C_TEXT_DIM)
