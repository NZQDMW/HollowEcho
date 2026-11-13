extends Control

var font: Font
var time := 0.0

var title_visible := true
var pause_visible := false
var map_visible := false
var ending_visible := false

var banner_text := ""
var banner_timer := 0.0
var toasts: Array[Dictionary] = []
var prompt_text := ""

var dialogue_visible := false
var dialogue_name := ""
var dialogue_text := ""
var dialogue_shop: Array = []
var dialogue_index := 0
var dialogue_mode := ""
var dialogue_feedback := ""

var boss_active := false
var boss_title := ""
var boss_hp := 0
var boss_max := 1

var map_rooms := {
	&"r1": Rect2(0, 80, 110, 58),
	&"r2": Rect2(176, 80, 110, 58),
	&"r3": Rect2(352, 80, 110, 58),
	&"r8": Rect2(528, 80, 110, 58),
	&"r9": Rect2(704, 80, 110, 58),
	&"r10": Rect2(880, 80, 110, 58),
	&"r4": Rect2(176, 200, 110, 58),
	&"r5": Rect2(352, 200, 110, 58),
	&"r6": Rect2(528, 200, 110, 58),
	&"r7": Rect2(704, 200, 110, 58),
	&"r11": Rect2(528, 320, 110, 58),
	&"r12": Rect2(390, 320, 110, 58),
	&"r13": Rect2(252, 320, 110, 58),
	&"r14": Rect2(114, 320, 110, 58),
}
var map_links := [
	[&"r1", &"r2"], [&"r2", &"r3"], [&"r3", &"r8"], [&"r8", &"r9"], [&"r9", &"r10"],
	[&"r2", &"r4"], [&"r4", &"r5"], [&"r5", &"r6"], [&"r6", &"r7"], [&"r2", &"r6"],
	[&"r6", &"r11"], [&"r11", &"r12"], [&"r12", &"r13"], [&"r13", &"r14"],
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	font = Utils.font()
	Game.room_changed.connect(_on_room_changed)
	Game.toast.connect(_on_toast)
	Game.boss_state.connect(_on_boss_state)
	Game.prompt_changed.connect(_on_prompt_changed)


func set_title(v: bool) -> void:
	title_visible = v
	queue_redraw()


func set_paused(v: bool) -> void:
	pause_visible = v
	queue_redraw()


func set_map(v: bool) -> void:
	map_visible = v
	queue_redraw()


func show_ending() -> void:
	ending_visible = true
	title_visible = false
	pause_visible = false
	map_visible = false
	queue_redraw()


func set_prompt(text: String) -> void:
	prompt_text = text
	queue_redraw()


func set_dialogue(v: bool, npc_name := "", text := "", shop: Array = [], index := 0, mode := "") -> void:
	dialogue_visible = v
	dialogue_name = npc_name
	dialogue_text = text
	dialogue_shop = shop
	dialogue_index = index
	dialogue_mode = mode
	queue_redraw()


func set_dialogue_feedback(text: String) -> void:
	dialogue_feedback = text
	queue_redraw()


func _on_room_changed(_id: StringName, rname: String) -> void:
	if title_visible:
		return
	banner_text = rname
	banner_timer = 2.8
	queue_redraw()


func _on_toast(text: String) -> void:
	toasts.append({"text": text, "timer": 3.4})
	while toasts.size() > 3:
		toasts.pop_front()
	queue_redraw()


func _on_boss_state(active: bool, title: String, hp: int, max_hp: int) -> void:
	boss_active = active
	boss_title = title
	boss_hp = hp
	boss_max = maxi(1, max_hp)
	queue_redraw()


func _on_prompt_changed(text: String) -> void:
	set_prompt(text)


func _process(delta: float) -> void:
	time += delta
	banner_timer = maxf(0.0, banner_timer - delta)
	for t in toasts:
		t["timer"] = float(t["timer"]) - delta
	while not toasts.is_empty() and float(toasts[0]["timer"]) <= 0.0:
		toasts.pop_front()
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y

	if title_visible:
		_draw_title(w, h)
		return

	_draw_masks()
	_draw_soul()
	_draw_items()
	_draw_geo(w)
	_draw_banner(w)
	if not (dialogue_visible or map_visible or pause_visible):
		_draw_toasts(w, h)
		if not boss_active:
			_draw_prompt(w, h)
		_draw_boss(w, h)
	_draw_dialogue(w, h)

	if pause_visible:
		_draw_pause(w, h)
	if map_visible:
		_draw_map(w, h)
	if ending_visible:
		_draw_ending(w, h)


func _ctext(text: String, y: float, fs: int, col: Color) -> void:
	var sz := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	draw_string(font, Vector2((size.x - sz.x) * 0.5, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _mask_shape(c: Vector2, s: float, col: Color) -> void:
	var pts := PackedVector2Array([
		c + Vector2(0, 9) * s, c + Vector2(-4, -5) * s, c + Vector2(-15, -10) * s,
		c + Vector2(-10, 7) * s, c + Vector2(0, 15) * s, c + Vector2(10, 7) * s,
		c + Vector2(15, -10) * s, c + Vector2(4, -5) * s
	])
	draw_colored_polygon(pts, col)


func _draw_masks() -> void:
	for i in range(Game.max_masks):
		var c := Vector2(58.0 + i * 52.0, 56.0)
		if i < Game.masks:
			_mask_shape(c, 1.0, Utils.C_IVORY)
		else:
			_mask_shape(c, 1.0, Color(0.16, 0.2, 0.26, 0.85))


func _draw_soul() -> void:
	var c := Vector2(84, 148)
	var r := 27.0
	draw_circle(c, r, Color(0.03, 0.05, 0.08, 0.9))
	var ratio: float = clampf(Game.soul / Game.max_soul, 0.0, 1.0)
	draw_arc(c, r - 2.0, 0.0, TAU, 40, Color(0.12, 0.2, 0.26, 0.9), 4.0, true)
	if ratio > 0.01:
		draw_arc(c, r - 2.0, -PI * 0.5, -PI * 0.5 + TAU * ratio, 40, Color(Utils.C_SOUL, 0.95), 4.0, true)
	draw_circle(c, 17.0 * ratio, Color(Utils.C_SOUL, 0.18 + ratio * 0.25))
	draw_circle(c + Vector2(-6, -7), 4.0, Color(0.8, 0.97, 1.0, 0.55))
	draw_circle(c + Vector2(7, 5), 2.5, Color(0.8, 0.97, 1.0, 0.35))


func _draw_items() -> void:
	var slots := [&"feather", &"lantern", &"pain_heart"]
	for i in range(slots.size()):
		var id: StringName = slots[i]
		var c := Vector2(46.0 + i * 54.0, 204.0)
		var box := Rect2(c - Vector2(20, 20), Vector2(40, 40))
		draw_rect(box, Color(0.03, 0.05, 0.07, 0.55))
		draw_rect(box, Color(Utils.C_RIM, 0.4 if Game.has_item(id) else 0.1), false, 1.2)
		if not Game.has_item(id):
			continue
		match id:
			&"feather":
				for k in range(3):
					draw_line(c + Vector2(-11 + k * 3, 8 - k * 2), c + Vector2(9 - k * 4, -10 + k * 4),
						Color(Utils.C_IVORY, 0.85 - k * 0.16), 2.4 - k * 0.4)
			&"lantern":
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(-7, -9), c + Vector2(7, -9), c + Vector2(9, 9), c + Vector2(-9, 9)
				]), Color(0.32, 0.28, 0.2, 0.95))
				draw_circle(c + Vector2(0, 0), 4.5, Color(1.0, 0.84, 0.5, 0.95))
				draw_circle(c + Vector2(0, 0), 10.0, Color(1.0, 0.75, 0.4, 0.14))
			&"pain_heart":
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(0, 11), c + Vector2(-11, 0), c + Vector2(-7, -10),
					c + Vector2(0, -4), c + Vector2(7, -10), c + Vector2(11, 0)
				]), Color(0.72, 0.18, 0.2, 0.95))
				draw_line(c + Vector2(0, 8), c + Vector2(0, -3), Color(1.0, 0.72, 0.55, 0.8), 1.2)


func _draw_geo(w: float) -> void:
	var x := w - 230.0
	var y := 52.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, y), Vector2(x + 16, y + 6), Vector2(x + 11, y + 22),
		Vector2(x - 3, y + 24), Vector2(x - 12, y + 12)
	]), Utils.C_GEO)
	draw_polyline(PackedVector2Array([
		Vector2(x, y), Vector2(x + 16, y + 6), Vector2(x + 11, y + 22), Vector2(x - 3, y + 24), Vector2(x - 12, y + 12), Vector2(x, y)
	]), Color(0.55, 0.45, 0.2, 0.9), 1.5, true)
	draw_string(font, Vector2(x + 30, y + 20), str(Game.geo), HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.93, 0.9, 0.8))


func _draw_banner(w: float) -> void:
	if banner_timer <= 0.0:
		return
	var a: float = clampf(banner_timer, 0.0, 1.0)
	var fs := 30
	var sz := font.get_string_size(banner_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var box := Rect2((w - sz.x) * 0.5 - 34.0, 18.0, sz.x + 68.0, 52.0)
	draw_rect(box, Color(0.02, 0.03, 0.05, 0.62 * a))
	draw_line(Vector2(box.position.x + 20, box.end.y), Vector2(box.end.x - 20, box.end.y), Color(Utils.C_RIM, 0.5 * a), 1.5)
	draw_string(font, Vector2((w - sz.x) * 0.5, box.position.y + 36.0), banner_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Utils.C_TEXT, a))


func _draw_toasts(w: float, h: float) -> void:
	var idx := 0
	for t in toasts:
		var timer: float = t["timer"]
		var a: float = clampf(timer, 0.0, 1.0)
		var lines: PackedStringArray = String(t["text"]).split("\n")
		var fs := 22
		var maxw := 0.0
		for line in lines:
			maxw = maxf(maxw, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
		var box_h := 14.0 + lines.size() * 30.0
		var y := h - 120.0 - idx * (box_h + 12.0)
		var box := Rect2((w - maxw) * 0.5 - 22.0, y, maxw + 44.0, box_h)
		draw_rect(box, Color(0.02, 0.03, 0.05, 0.66 * a))
		var ly := y + 30.0
		for line in lines:
			var sz := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
			draw_string(font, Vector2((w - sz.x) * 0.5, ly), line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Utils.C_TEXT, a))
			ly += 30.0
		idx += 1


func _draw_prompt(w: float, h: float) -> void:
	if prompt_text.is_empty():
		return
	var fs := 20
	var sz := font.get_string_size(prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var box := Rect2((w - sz.x) * 0.5 - 16.0, h - 74.0, sz.x + 32.0, 36.0)
	draw_rect(box, Color(0.02, 0.03, 0.05, 0.62))
	draw_string(font, Vector2((w - sz.x) * 0.5, h - 49.0), prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Utils.C_TEXT)


func _draw_boss(w: float, h: float) -> void:
	if not boss_active:
		return
	var bw := 620.0
	var bx := (w - bw) * 0.5
	var by := h - 74.0
	var name_sz := font.get_string_size(boss_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
	draw_string(font, Vector2((w - name_sz.x) * 0.5, by - 12.0), boss_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.9, 0.82, 0.74))
	draw_rect(Rect2(bx - 2.0, by - 2.0, bw + 4.0, 14.0), Color(0.05, 0.04, 0.04, 0.9))
	var ratio: float = clampf(float(boss_hp) / float(boss_max), 0.0, 1.0)
	draw_rect(Rect2(bx, by, bw * ratio, 10.0), Color(0.78, 0.28, 0.24))
	draw_line(Vector2(bx, by + 10.0), Vector2(bx + bw, by + 10.0), Color(0.45, 0.2, 0.18, 0.8), 1.0)


func _draw_dialogue(w: float, h: float) -> void:
	if not dialogue_visible:
		return
	var panel_w := 880.0
	var panel := Rect2((w - panel_w) * 0.5, h - 460.0, panel_w, 420.0)
	draw_rect(panel, Color(0.012, 0.02, 0.033, 0.985))
	draw_rect(panel, Color(Utils.C_RIM, 0.3), false, 1.5)

	# name plate
	var plate := Rect2(panel.position.x + 30, panel.position.y - 22, 260, 44)
	draw_rect(plate, Color(0.025, 0.04, 0.06, 0.98))
	draw_rect(plate, Color(Utils.C_WARM, 0.45), false, 1.2)
	draw_string(font, Vector2(plate.position.x + 18, plate.position.y + 29), dialogue_name,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(Utils.C_WARM, 0.95))

	# dialogue text
	var ty := panel.position.y + 66.0
	for line in dialogue_text.split("\n"):
		draw_string(font, Vector2(panel.position.x + 44, ty), line,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Utils.C_TEXT)
		ty += 32.0

	if dialogue_mode == "shop":
		ty += 14.0
		draw_line(Vector2(panel.position.x + 32, ty - 22), Vector2(panel.end.x - 32, ty - 22),
			Color(Utils.C_RIM, 0.25), 1.0)
		for i in range(dialogue_shop.size()):
			var item: Dictionary = dialogue_shop[i]
			var row_y := ty + i * 46.0
			if i == dialogue_index:
				draw_rect(Rect2(panel.position.x + 26, row_y - 27, panel_w - 52, 40), Color(Utils.C_RIM, 0.1))
				draw_rect(Rect2(panel.position.x + 26, row_y - 27, 3, 40), Color(Utils.C_SOUL, 0.9))
			var key: StringName = item.get("key", &"")
			var sold_out := Game.shop_bought(key) >= int(item.get("max", 1))
			var name_col := Color(Utils.C_TEXT_DIM, 0.55) if sold_out else Utils.C_TEXT
			draw_string(font, Vector2(panel.position.x + 68, row_y), String(item.get("name", "")),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 21, name_col)
			draw_string(font, Vector2(panel.position.x + 250, row_y), String(item.get("desc", "")),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(Utils.C_TEXT_DIM, 0.8))
			var price_text := "已售罄" if sold_out else "%d 吉欧" % int(item.get("price", 0))
			var price_col := Color(Utils.C_TEXT_DIM, 0.75) if sold_out else Utils.C_GEO
			var psz := font.get_string_size(price_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 19)
			draw_string(font, Vector2(panel.end.x - 44.0 - psz.x, row_y), price_text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 19, price_col)
		draw_string(font, Vector2(panel.position.x + 44, panel.end.y - 28),
			"摇杆 选择    互 购买    停 离开" if Game.touch_mode else "W/S 选择    E 购买    Esc 离开",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(Utils.C_TEXT_DIM, 0.85))
		if not dialogue_feedback.is_empty():
			draw_string(font, Vector2(panel.position.x + 44, panel.end.y - 62), dialogue_feedback,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(Utils.C_WARM, 0.95))
		var geo_text := "持有 %d 吉欧" % Game.geo
		var gsz := font.get_string_size(geo_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
		draw_string(font, Vector2(panel.end.x - 44.0 - gsz.x, panel.end.y - 28), geo_text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(Utils.C_GEO, 0.8))
	else:
		var blink := 0.55 + 0.45 * sin(time * 3.0)
		draw_string(font, Vector2(panel.end.x - 160, panel.end.y - 28), "%s  继续" % Game.interact_label(),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color(Utils.C_SOUL, blink))


func _draw_title(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), Color(0.008, 0.012, 0.022, 0.84))
	var cx := w * 0.5
	for i in range(7):
		draw_circle(Vector2(cx, h * 0.33), 210.0 - i * 26.0, Color(0.12, 0.26, 0.32, 0.035))
	_ctext("空谷回响", h * 0.34, 92, Utils.C_IVORY)
	_ctext("H O L L O W   E C H O", h * 0.40, 18, Color(Utils.C_RIM, 0.75))
	draw_line(Vector2(cx - 160, h * 0.435), Vector2(cx + 160, h * 0.435), Color(Utils.C_RIM, 0.35), 1.0)
	_ctext("在沉没的王国里，捡起散落的回响", h * 0.49, 21, Utils.C_TEXT_DIM)

	var rows := [
		"A / D  移动          空格  跳跃（长按更高）",
		"J  挥钉（W/S 改变方向）    K  冲刺",
		"L  法术          长按 F  聚集灵魂治愈伤口",
		"E  互动          Tab  地图          Esc  暂停",
	]
	if Game.touch_mode:
		rows = [
			"左侧摇杆  移动 · 上推 / 下推改变挥钉方向",
			"右侧  跳 / 打 / 冲 / 法 / 聚 / 互",
			"右上  图（地图）   停（暂停）",
			"建议横屏游玩，双手持机",
		]
	var y := h * 0.60
	for row in rows:
		_ctext(row, y, 20, Color(Utils.C_TEXT, 0.82))
		y += 34.0

	var blink := 0.55 + 0.45 * sin(time * 3.0)
	_ctext("点击屏幕开始" if Game.touch_mode else "按任意键开始", h * 0.88, 26, Color(Utils.C_SOUL, blink))
	_ctext("所有画面均由代码实时绘制", h * 0.94, 15, Color(Utils.C_TEXT_DIM, 0.6))


func _draw_pause(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), Color(0.008, 0.012, 0.022, 0.72))
	_ctext("已暂停", h * 0.40, 56, Utils.C_IVORY)
	if Game.touch_mode:
		_ctext("停  继续游戏", h * 0.50, 22, Utils.C_TEXT)
		_ctext("左侧摇杆移动 · 跳 / 打 / 冲 / 法 / 聚 / 互", h * 0.56, 18, Utils.C_TEXT_DIM)
	else:
		_ctext("Esc  继续游戏", h * 0.50, 22, Utils.C_TEXT)
		_ctext("A/D 移动 · 空格 跳跃 · J 挥钉 · K 冲刺 · L 法术 · F 聚集", h * 0.56, 18, Utils.C_TEXT_DIM)


func _room_color(id: StringName) -> Color:
	if id == Game.current_room:
		return Color(Utils.C_RIM, 0.85)
	if Game.visited.has(id):
		return Color(0.22, 0.3, 0.4, 0.9)
	return Color(0.1, 0.13, 0.18, 0.7)


func _draw_map(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), Color(0.008, 0.012, 0.022, 0.85))
	_ctext("地图", 96, 34, Utils.C_IVORY)
	var panel := Rect2(120, 120, 1040, 480)
	draw_rect(panel, Color(0.02, 0.035, 0.055, 0.85))
	draw_rect(panel, Color(Utils.C_RIM, 0.25), false, 1.5)
	var origin := panel.position + Vector2(20, 0)
	var centers := {}
	for id in map_rooms:
		var r: Rect2 = map_rooms[id]
		centers[id] = origin + r.position + r.size * 0.5
	for link in map_links:
		var a: StringName = link[0]
		var b: StringName = link[1]
		var col := Color(Utils.C_RIM, 0.25)
		if Game.visited.has(a) and Game.visited.has(b):
			col = Color(Utils.C_RIM, 0.5)
		draw_line(centers[a], centers[b], col, 2.0, true)
	for id in map_rooms:
		var r: Rect2 = map_rooms[id]
		var rr := Rect2(origin + r.position, r.size)
		draw_rect(rr, _room_color(id))
		draw_rect(rr, Color(Utils.C_RIM, 0.5 if id == Game.current_room else 0.15), false, 2.0)
		var label := "？"
		if Game.visited.has(id):
			label = RoomData.room_name(id)
		var fs := 17
		var sz := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		if sz.x > r.size.x - 8.0:
			fs = 13
			sz = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		draw_string(font, rr.position + Vector2((r.size.x - sz.x) * 0.5, r.size.y * 0.5 + 6.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Utils.C_TEXT, 0.9))
	var explored := 0
	for id in map_rooms:
		if Game.visited.has(id):
			explored += 1
	var lx := panel.position.x + 40.0
	var ly := panel.end.y - 56.0
	draw_rect(Rect2(lx, ly - 16, 26, 18), Color(Utils.C_RIM, 0.85))
	draw_string(font, Vector2(lx + 34, ly), "当前房间", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Utils.C_TEXT_DIM, 0.9))
	draw_rect(Rect2(lx + 150, ly - 16, 26, 18), Color(0.22, 0.3, 0.4, 0.9))
	draw_string(font, Vector2(lx + 184, ly), "已探索", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Utils.C_TEXT_DIM, 0.9))
	draw_rect(Rect2(lx + 290, ly - 16, 26, 18), Color(0.1, 0.13, 0.18, 0.7))
	draw_string(font, Vector2(lx + 324, ly), "未探索", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Utils.C_TEXT_DIM, 0.9))
	var count_text := "已探索 %d / %d" % [explored, map_rooms.size()]
	var csz := font.get_string_size(count_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(font, Vector2(panel.end.x - 40.0 - csz.x, ly), count_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Utils.C_TEXT_DIM, 0.9))
	_ctext("图  关闭地图" if Game.touch_mode else "Tab  关闭地图", h - 58, 20, Utils.C_TEXT_DIM)


func _draw_ending(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), Color(0.006, 0.01, 0.018, 0.9))
	_ctext("回响终结", h * 0.34, 76, Utils.C_IVORY)
	_ctext("残破的守卫倒下了，王座上的回声终于安静。", h * 0.43, 22, Utils.C_TEXT)
	var mins := int(Game.play_seconds) / 60
	var secs := int(Game.play_seconds) % 60
	var stats := "吉欧 %d     倒下 %d 次     旅途 %d 分 %d 秒" % [Game.geo, Game.deaths, mins, secs]
	_ctext(stats, h * 0.52, 22, Utils.C_TEXT_DIM)
	draw_line(Vector2(w * 0.35, h * 0.58), Vector2(w * 0.65, h * 0.58), Color(Utils.C_RIM, 0.3), 1.0)
	if Game.bosses_defeated.has("bell"):
		_ctext("钟声停了。所有的回响都已安息。", h * 0.65, 19, Color(Utils.C_TEXT_DIM, 0.8))
	else:
		_ctext("但深井之下，还有别的回响在等待。", h * 0.65, 19, Color(Utils.C_TEXT_DIM, 0.8))
	if Game.has_item(&"pain_heart"):
		_ctext("你也走完了苦痛之路。王座深处的痛，从此有了名字。", h * 0.71, 19, Color(0.96, 0.72, 0.55, 0.9))
	var blink := 0.55 + 0.45 * sin(time * 3.0)
	_ctext("按 R 重新开始", h * 0.82, 26, Color(Utils.C_SOUL, blink))
