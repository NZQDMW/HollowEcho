class_name RoomData
extends RefCounted


static func room_name(id: StringName) -> String:
	match id:
		&"r1": return "遗忘十字路"
		&"r2": return "苔藓甬道"
		&"r3": return "沉眠圣所"
		&"r4": return "回响深井"
		&"r5": return "石壁回廊"
		&"r6": return "王座前厅"
		&"r7": return "破碎王座"
		&"r8": return "静默集市"
		&"r9": return "钟鸣洞窟"
		&"r10": return "回响之厅"
		&"r11": return "王座密道"
		&"r12": return "苦痛之路·回廊"
		&"r13": return "苦痛之路·深井"
		&"r14": return "王座之心"
	return "未知之地"


static func get_room(id: StringName) -> Dictionary:
	match id:
		&"r2": return _r2()
		&"r3": return _r3()
		&"r4": return _r4()
		&"r5": return _r5()
		&"r6": return _r6()
		&"r7": return _r7()
		&"r8": return _r8()
		&"r9": return _r9()
		&"r10": return _r10()
		&"r11": return _r11()
		&"r12": return _r12()
		&"r13": return _r13()
		&"r14": return _r14()
	return _r1()


static func _r1() -> Dictionary:
	return {
		"id": &"r1",
		"name": "遗忘十字路",
		"seed": 11,
		"size": Vector2(2400, 800),
		"spawn": Vector2(360, 680),
		"theme": {"bg1": Color(0.025, 0.045, 0.075), "bg2": Color(0.07, 0.11, 0.17), "accent": Color(0.35, 0.68, 0.78)},
		"ground": [
			{"rect": Rect2(0, 680, 1020, 140), "seed": 12},
			{"rect": Rect2(1140, 680, 1260, 140), "seed": 19},
		],
		"ledges": [
			{"rect": Rect2(520, 540, 300, 26), "seed": 31},
			{"rect": Rect2(1350, 520, 300, 26), "seed": 32},
			{"rect": Rect2(1800, 560, 250, 26), "seed": 33},
		],
		"doors": [
			{"side": "right", "trigger": Rect2(2320, 460, 80, 240), "spawn": Vector2(2200, 680), "target": &"r2", "target_door": 0},
		],
		"gates": [],
		"enemies": [
			{"type": "crawler", "pos": Vector2(1450, 680), "min_x": 1180, "max_x": 1700},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(800, 470), "amount": 5},
			{"type": "geo", "pos": Vector2(1620, 450), "amount": 8},
		],
		"relics": [],
		"mask_shards": [],
		"benches": [Vector2(260, 680)],
		"lanterns": [Vector2(720, 680), Vector2(1980, 680)],
		"signs": [
			{"pos": Vector2(430, 680), "text": "A/D 移动 · 空格 跳跃 · J 挥钉\n长按 F 用灵魂治愈伤口。\n前方的甬道通向沉没的王国。"},
		],
		"hazards": [],
		"boss": {},
		"arena": Rect2(),
	}


static func _r2() -> Dictionary:
	return {
		"id": &"r2",
		"name": "苔藓甬道",
		"seed": 23,
		"size": Vector2(2600, 1400),
		"spawn": Vector2(170, 1200),
		"theme": {"bg1": Color(0.018, 0.05, 0.055), "bg2": Color(0.05, 0.12, 0.13), "accent": Color(0.3, 0.8, 0.7)},
		"ground": [
			{"rect": Rect2(0, 1200, 900, 200), "seed": 41},
			{"rect": Rect2(1050, 1200, 650, 200), "seed": 42},
			{"rect": Rect2(1850, 1200, 750, 200), "seed": 43},
			{"rect": Rect2(1500, 820, 1100, 60), "seed": 44},
		],
		"ledges": [
			{"rect": Rect2(1800, 700, 220, 24), "seed": 45},
			{"rect": Rect2(2050, 560, 220, 24), "seed": 46},
			{"rect": Rect2(2300, 480, 240, 26), "seed": 47},
			{"rect": Rect2(1700, 1060, 220, 24), "seed": 48},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 960, 80, 260), "spawn": Vector2(170, 1200), "target": &"r1", "target_door": 0},
			{"side": "right", "trigger": Rect2(2520, 960, 80, 260), "spawn": Vector2(2430, 1200), "target": &"r3", "target_door": 0},
			{"side": "down", "trigger": Rect2(900, 1180, 150, 120), "spawn": Vector2(1100, 1200), "target": &"r4", "target_door": 0},
			{"side": "up", "trigger": Rect2(2380, 240, 220, 100), "spawn": Vector2(2480, 480), "target": &"r6", "target_door": 1},
		],
		"gates": [
			{"rect": Rect2(2320, 120, 280, 260), "relic": &"wall", "hint": "高处的通路被石壁封住了。"},
		],
		"enemies": [
			{"type": "flyer", "pos": Vector2(1050, 940)},
			{"type": "crawler", "pos": Vector2(1950, 820), "min_x": 1550, "max_x": 2350},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(1600, 740), "amount": 6},
			{"type": "geo", "pos": Vector2(2350, 400), "amount": 10},
		],
		"relics": [],
		"mask_shards": [],
		"benches": [],
		"lanterns": [Vector2(400, 1200), Vector2(1600, 1200), Vector2(2250, 820)],
		"signs": [
			{"pos": Vector2(1150, 1200), "text": "苔藓覆盖的甬道。\n右侧的圣所里有微光，下方的深井传来风声。"},
		],
		"hazards": [],
		"boss": {},
		"arena": Rect2(),
	}


static func _r3() -> Dictionary:
	return {
		"id": &"r3",
		"name": "沉眠圣所",
		"seed": 37,
		"size": Vector2(2200, 900),
		"spawn": Vector2(170, 780),
		"theme": {"bg1": Color(0.04, 0.03, 0.07), "bg2": Color(0.1, 0.08, 0.16), "accent": Color(0.6, 0.55, 0.9)},
		"ground": [
			{"rect": Rect2(0, 780, 900, 160), "seed": 51},
			{"rect": Rect2(1050, 780, 1150, 160), "seed": 52},
		],
		"ledges": [
			{"rect": Rect2(500, 640, 260, 26), "seed": 53},
			{"rect": Rect2(1150, 620, 300, 26), "seed": 54},
			{"rect": Rect2(1650, 520, 300, 26), "seed": 55},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 560, 80, 260), "spawn": Vector2(170, 780), "target": &"r2", "target_door": 1},
			{"side": "right", "trigger": Rect2(2120, 540, 80, 260), "spawn": Vector2(2030, 780), "target": &"r8", "target_door": 0},
		],
		"gates": [],
		"enemies": [
			{"type": "husk", "pos": Vector2(1300, 780), "min_x": 1100, "max_x": 1750},
			{"type": "crawler", "pos": Vector2(700, 780), "min_x": 120, "max_x": 850},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(1300, 560), "amount": 10},
		],
		"relics": [
			{"id": &"dash", "title": "风纹披风", "pos": Vector2(1850, 690)},
		],
		"mask_shards": [],
		"benches": [],
		"lanterns": [Vector2(350, 780), Vector2(1750, 780)],
		"signs": [
			{"pos": Vector2(320, 780), "text": "沉眠圣所。\n守卫的长矛已经锈蚀，但仇恨没有。"},
		],
		"hazards": [],
		"boss": {},
		"arena": Rect2(),
	}


static func _r4() -> Dictionary:
	return {
		"id": &"r4",
		"name": "回响深井",
		"seed": 41,
		"size": Vector2(1400, 1500),
		"spawn": Vector2(700, 220),
		"theme": {"bg1": Color(0.015, 0.035, 0.06), "bg2": Color(0.04, 0.09, 0.15), "accent": Color(0.35, 0.75, 0.9)},
		"ground": [
			{"rect": Rect2(0, 1300, 960, 200), "seed": 61},
			{"rect": Rect2(1250, 1300, 150, 200), "seed": 62},
		],
		"ledges": [
			{"rect": Rect2(150, 1050, 270, 26), "seed": 63},
			{"rect": Rect2(900, 1050, 300, 26), "seed": 64},
			{"rect": Rect2(500, 870, 300, 26), "seed": 65},
			{"rect": Rect2(900, 690, 300, 26), "seed": 66},
			{"rect": Rect2(300, 510, 300, 26), "seed": 67},
			{"rect": Rect2(900, 330, 300, 26), "seed": 68},
		],
		"doors": [
			{"side": "up", "trigger": Rect2(600, 0, 260, 80), "spawn": Vector2(700, 220), "target": &"r2", "target_door": 2},
			{"side": "right", "trigger": Rect2(1360, 1040, 40, 300), "spawn": Vector2(1320, 1300), "target": &"r5", "target_door": 0},
		],
		"gates": [],
		"enemies": [
			{"type": "flyer", "pos": Vector2(400, 760)},
			{"type": "flyer", "pos": Vector2(1000, 560)},
			{"type": "crawler", "pos": Vector2(500, 1300), "min_x": 120, "max_x": 900},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(600, 820), "amount": 8},
			{"type": "geo", "pos": Vector2(1000, 640), "amount": 8},
		],
		"relics": [],
		"mask_shards": [
			{"pos": Vector2(1050, 1000)},
		],
		"benches": [],
		"lanterns": [Vector2(200, 1300), Vector2(1200, 1300)],
		"signs": [
			{"pos": Vector2(220, 1300), "text": "回响深井。\n落在井底的声音，从未真正消失。"},
			{"pos": Vector2(860, 1300), "text": "裂隙之下是无底的黑暗。\n若坠入深渊，它会将你送回岸边，但会夺走一格生命。"},
		],
		"hazards": [],
		"pits": [
			{"rect": Rect2(960, 1440, 290, 60), "respawn": Vector2(900, 1300)},
		],
		"boss": {},
		"arena": Rect2(),
	}


static func _r5() -> Dictionary:
	return {
		"id": &"r5",
		"name": "石壁回廊",
		"seed": 53,
		"size": Vector2(1800, 1600),
		"spawn": Vector2(170, 1340),
		"theme": {"bg1": Color(0.03, 0.04, 0.06), "bg2": Color(0.07, 0.1, 0.14), "accent": Color(0.45, 0.7, 0.85)},
		"ground": [
			{"rect": Rect2(0, 1340, 1800, 200), "seed": 71},
		],
		"ledges": [
			{"rect": Rect2(250, 1150, 350, 26), "seed": 72},
			{"rect": Rect2(750, 1000, 300, 26), "seed": 73},
			{"rect": Rect2(1250, 850, 300, 26), "seed": 74},
			{"rect": Rect2(900, 700, 280, 26), "seed": 75},
			{"rect": Rect2(400, 550, 320, 26), "seed": 76},
			{"rect": Rect2(600, 480, 220, 26), "seed": 77},
			{"rect": Rect2(760, 360, 420, 26), "seed": 78},
		],
		"walls": [
			{"rect": Rect2(1600, 260, 40, 1080), "seed": 79},
			{"rect": Rect2(200, 560, 40, 780), "seed": 80},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 1100, 80, 260), "spawn": Vector2(170, 1340), "target": &"r4", "target_door": 1},
			{"side": "up", "trigger": Rect2(760, 120, 380, 100), "spawn": Vector2(950, 360), "target": &"r6", "target_door": 0},
		],
		"gates": [
			{"rect": Rect2(740, 80, 420, 260), "relic": &"wall", "hint": "石壁中藏着攀附之力。"},
		],
		"enemies": [
			{"type": "flyer", "pos": Vector2(600, 700)},
			{"type": "husk", "pos": Vector2(1200, 1340), "min_x": 900, "max_x": 1550},
			{"type": "spitter", "pos": Vector2(520, 1340), "min_x": 260, "max_x": 760},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(500, 500), "amount": 10},
		],
		"relics": [
			{"id": &"wall", "title": "螳螂爪", "pos": Vector2(900, 930)},
		],
		"mask_shards": [],
		"benches": [],
		"lanterns": [Vector2(300, 1340), Vector2(1500, 1340), Vector2(950, 1000)],
		"signs": [
			{"pos": Vector2(220, 1340), "text": "石壁回廊。\n风从裂隙中穿过，岩壁似乎在呼吸。"},
		],
		"hazards": [],
		"boss": {},
		"arena": Rect2(),
	}


static func _r6() -> Dictionary:
	return {
		"id": &"r6",
		"name": "王座前厅",
		"seed": 67,
		"size": Vector2(2000, 900),
		"spawn": Vector2(170, 760),
		"theme": {"bg1": Color(0.04, 0.035, 0.05), "bg2": Color(0.11, 0.08, 0.1), "accent": Color(0.85, 0.62, 0.4)},
		"ground": [
			{"rect": Rect2(0, 760, 1440, 160), "seed": 81},
			{"rect": Rect2(1560, 760, 440, 160), "seed": 82},
		],
		"ledges": [
			{"rect": Rect2(300, 600, 220, 24), "seed": 83},
			{"rect": Rect2(700, 620, 240, 26), "seed": 84},
			{"rect": Rect2(980, 480, 240, 26), "seed": 85},
			{"rect": Rect2(1250, 600, 220, 26), "seed": 86},
			{"rect": Rect2(1560, 380, 240, 26), "seed": 87},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 540, 80, 260), "spawn": Vector2(170, 760), "target": &"r5", "target_door": 1},
			{"side": "down", "trigger": Rect2(1440, 740, 120, 120), "spawn": Vector2(1620, 760), "target": &"r2", "target_door": 3},
			{"side": "right", "trigger": Rect2(1920, 540, 80, 260), "spawn": Vector2(1840, 760), "target": &"r7", "target_door": 0},
			{"side": "up", "trigger": Rect2(1600, 220, 160, 140), "spawn": Vector2(1680, 380), "target": &"r11", "target_door": 0},
		],
		"gates": [],
		"enemies": [
			{"type": "husk", "pos": Vector2(900, 760), "min_x": 500, "max_x": 1350},
			{"type": "flyer", "pos": Vector2(1400, 500)},
			{"type": "hopper", "pos": Vector2(900, 760), "min_x": 600, "max_x": 1380},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(1250, 560), "amount": 12},
		],
		"relics": [
			{"id": &"double", "title": "王翼", "pos": Vector2(1100, 430)},
		],
		"mask_shards": [],
		"benches": [Vector2(360, 760)],
		"lanterns": [Vector2(200, 760), Vector2(1750, 760)],
		"signs": [
			{"pos": Vector2(260, 760), "text": "王座前厅。\n长椅旁仍残留着旧日骑士的气息。"},
			{"pos": Vector2(1330, 760), "text": "王座背后似乎有一道被遗忘的裂隙。\n高处的冷风不是从王座吹来的。"},
		],
		"hazards": [],
		"boss": {},
		"arena": Rect2(),
	}


static func _r7() -> Dictionary:
	return {
		"id": &"r7",
		"name": "破碎王座",
		"seed": 79,
		"size": Vector2(1800, 800),
		"spawn": Vector2(170, 620),
		"theme": {"bg1": Color(0.05, 0.02, 0.025), "bg2": Color(0.13, 0.05, 0.05), "accent": Color(0.9, 0.4, 0.3)},
		"ground": [
			{"rect": Rect2(0, 620, 1800, 180), "seed": 91},
		],
		"ledges": [
			{"rect": Rect2(300, 470, 200, 24), "seed": 92},
			{"rect": Rect2(1300, 470, 200, 24), "seed": 93},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 400, 80, 260), "spawn": Vector2(250, 620), "target": &"r6", "target_door": 2},
		],
		"gates": [],
		"enemies": [],
		"pickups": [],
		"relics": [],
		"mask_shards": [],
		"benches": [],
		"lanterns": [Vector2(400, 620), Vector2(1400, 620)],
		"signs": [],
		"hazards": [],
		"boss": {
			"id": &"guard", "pos": Vector2(1250, 620),
			"arena": Rect2(160, 0, 1480, 620),
			"name": "残破守卫", "hp": 60, "final": true,
		},
		"arena": Rect2(160, 0, 1480, 620),
	}


static func _r8() -> Dictionary:
	return {
		"id": &"r8",
		"name": "静默集市",
		"seed": 89,
		"size": Vector2(2000, 900),
		"spawn": Vector2(170, 760),
		"theme": {"bg1": Color(0.03, 0.04, 0.06), "bg2": Color(0.08, 0.11, 0.15), "accent": Color(1.0, 0.7, 0.42)},
		"ground": [
			{"rect": Rect2(0, 760, 2000, 140), "seed": 101},
		],
		"ledges": [
			{"rect": Rect2(300, 620, 240, 26), "seed": 102},
			{"rect": Rect2(1150, 620, 260, 26), "seed": 103},
			{"rect": Rect2(1580, 640, 240, 26), "seed": 104},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 520, 80, 260), "spawn": Vector2(170, 760), "target": &"r3", "target_door": 1},
			{"side": "right", "trigger": Rect2(1920, 520, 80, 260), "spawn": Vector2(1760, 760), "target": &"r9", "target_door": 0},
		],
		"gates": [
			{"rect": Rect2(1820, 280, 40, 480), "relic": &"key", "hint": "门锁锈死了。集市里也许有人卖钥匙。"},
		],
		"enemies": [],
		"pickups": [
			{"type": "geo", "pos": Vector2(1000, 700), "amount": 6},
		],
		"relics": [],
		"mask_shards": [],
		"benches": [Vector2(250, 760)],
		"lanterns": [Vector2(420, 760), Vector2(1050, 760), Vector2(1720, 760)],
		"signs": [
			{"pos": Vector2(880, 760), "text": "静默集市。\n王国沉没之后，只有这里的灯还亮着。"},
			{"pos": Vector2(1500, 760), "text": "东边的门通向钟鸣洞窟。\n记录者说，钟声从来没有停过。"},
		],
		"npcs": [
			{"id": &"merchant", "pos": Vector2(620, 760)},
			{"id": &"lorekeeper", "pos": Vector2(1270, 620)},
		],
		"props": [
			{"type": "stall", "pos": Vector2(430, 760)},
			{"type": "stall", "pos": Vector2(1440, 760)},
			{"type": "crate", "pos": Vector2(760, 760)},
			{"type": "crate", "pos": Vector2(1780, 760)},
		],
		"hazards": [],
		"boss": {},
		"arena": Rect2(),
	}


static func _r9() -> Dictionary:
	return {
		"id": &"r9",
		"name": "钟鸣洞窟",
		"seed": 97,
		"size": Vector2(2400, 1400),
		"spawn": Vector2(170, 1200),
		"theme": {"bg1": Color(0.025, 0.05, 0.045), "bg2": Color(0.07, 0.12, 0.1), "accent": Color(0.85, 0.75, 0.4)},
		"ground": [
			{"rect": Rect2(0, 1200, 1000, 200), "seed": 111},
			{"rect": Rect2(1200, 1200, 500, 200), "seed": 112},
			{"rect": Rect2(1800, 1200, 600, 200), "seed": 113},
		],
		"ledges": [
			{"rect": Rect2(250, 1060, 280, 26), "seed": 114},
			{"rect": Rect2(620, 920, 260, 26), "seed": 115},
			{"rect": Rect2(1000, 1060, 240, 26), "seed": 116},
			{"rect": Rect2(1380, 900, 280, 26), "seed": 117},
			{"rect": Rect2(1720, 1060, 260, 26), "seed": 118},
			{"rect": Rect2(2020, 920, 300, 26), "seed": 119},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 960, 80, 260), "spawn": Vector2(170, 1200), "target": &"r8", "target_door": 1},
			{"side": "right", "trigger": Rect2(2320, 960, 80, 260), "spawn": Vector2(2250, 1200), "target": &"r10", "target_door": 0},
		],
		"gates": [],
		"enemies": [
			{"type": "hopper", "pos": Vector2(400, 1200), "min_x": 180, "max_x": 820},
			{"type": "crawler", "pos": Vector2(1500, 1200), "min_x": 1250, "max_x": 1680},
			{"type": "spitter", "pos": Vector2(2120, 1200), "min_x": 1850, "max_x": 2330},
			{"type": "flyer", "pos": Vector2(900, 760)},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(700, 880), "amount": 8},
			{"type": "geo", "pos": Vector2(1900, 1000), "amount": 10},
			{"type": "geo", "pos": Vector2(2250, 860), "amount": 12},
		],
		"relics": [],
		"mask_shards": [
			{"pos": Vector2(2140, 860)},
		],
		"benches": [],
		"lanterns": [Vector2(300, 1200), Vector2(1450, 1200), Vector2(2150, 1200)],
		"signs": [
			{"pos": Vector2(260, 1200), "text": "钟鸣洞窟。\n岩壁里嵌着旧钟的碎片，踩上去会发出很低的嗡鸣。"},
			{"pos": Vector2(1290, 1200), "text": "裂隙很深。掉下去会被送回崖边，但会失去一格生命。"},
		],
		"npcs": [],
		"props": [
			{"type": "bell", "pos": Vector2(1700, 300)},
		],
		"hazards": [],
		"pits": [
			{"rect": Rect2(1000, 1340, 200, 60), "respawn": Vector2(950, 1200)},
		],
		"boss": {},
		"arena": Rect2(),
	}


static func _r10() -> Dictionary:
	return {
		"id": &"r10",
		"name": "回响之厅",
		"seed": 103,
		"size": Vector2(1800, 800),
		"spawn": Vector2(250, 620),
		"theme": {"bg1": Color(0.04, 0.03, 0.05), "bg2": Color(0.11, 0.08, 0.12), "accent": Color(0.9, 0.78, 0.42)},
		"ground": [
			{"rect": Rect2(0, 620, 1800, 180), "seed": 121},
		],
		"ledges": [
			{"rect": Rect2(280, 470, 200, 24), "seed": 122},
			{"rect": Rect2(1320, 470, 200, 24), "seed": 123},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 400, 80, 260), "spawn": Vector2(250, 620), "target": &"r9", "target_door": 1},
		],
		"gates": [],
		"enemies": [],
		"pickups": [],
		"relics": [],
		"mask_shards": [],
		"benches": [],
		"lanterns": [Vector2(400, 620), Vector2(1400, 620)],
		"signs": [
			{"pos": Vector2(360, 620), "text": "回响之厅。\n一口没有绳子的钟悬在头顶，钟舌却一直在响。"},
		],
		"npcs": [],
		"props": [
			{"type": "bell", "pos": Vector2(1200, 180)},
			{"type": "pillar", "pos": Vector2(520, 620)},
			{"type": "pillar", "pos": Vector2(1280, 620)},
		],
		"hazards": [],
		"boss": {
			"id": &"bell", "pos": Vector2(1250, 620),
			"arena": Rect2(180, 0, 1440, 620),
			"name": "钟鸣守卫", "hp": 48, "final": false,
			"phase2_text": "钟壳裂开了。里面的回响涌了出来。",
		},
		"arena": Rect2(180, 0, 1440, 620),
	}


static func _r11() -> Dictionary:
	return {
		"id": &"r11",
		"name": "王座密道",
		"seed": 131,
		"size": Vector2(2000, 1300),
		"spawn": Vector2(1840, 1100),
		"theme": {"bg1": Color(0.028, 0.032, 0.05), "bg2": Color(0.075, 0.085, 0.12), "accent": Color(0.72, 0.82, 0.88)},
		"ground": [
			{"rect": Rect2(0, 1100, 700, 200), "seed": 132},
			{"rect": Rect2(1300, 1100, 700, 200), "seed": 133},
		],
		"ledges": [
			{"rect": Rect2(1420, 950, 240, 26), "seed": 134},
			{"rect": Rect2(1150, 800, 240, 26), "seed": 135},
			{"rect": Rect2(880, 660, 240, 26), "seed": 136},
			{"rect": Rect2(560, 520, 260, 26), "seed": 137},
			{"rect": Rect2(60, 640, 300, 26), "seed": 138},
			{"rect": Rect2(260, 400, 240, 26), "seed": 139},
		],
		"doors": [
			{"side": "right", "trigger": Rect2(1920, 840, 80, 260), "spawn": Vector2(1840, 1100), "target": &"r6", "target_door": 3},
			{"side": "left", "trigger": Rect2(0, 380, 80, 260), "spawn": Vector2(180, 640), "target": &"r12", "target_door": 0},
		],
		"gates": [],
		"enemies": [
			{"type": "flyer", "pos": Vector2(1100, 920)},
			{"type": "crawler", "pos": Vector2(1500, 1100), "min_x": 1350, "max_x": 1850},
		],
		"pickups": [
			{"type": "geo", "pos": Vector2(500, 1040), "amount": 12},
			{"type": "geo", "pos": Vector2(1000, 610), "amount": 10},
		],
		"relics": [],
		"mask_shards": [],
		"specials": [
			{"id": &"feather", "title": "轻羽斗篷", "pos": Vector2(380, 320)},
		],
		"benches": [],
		"lanterns": [Vector2(300, 1100), Vector2(1500, 1100), Vector2(180, 640)],
		"signs": [
			{"pos": Vector2(1650, 1100), "text": "王座之下，还有一条路。\n它不通向王座，只通向痛。"},
			{"pos": Vector2(300, 640), "text": "没有长椅，也没有回头路。\n走之前，把该带的都带上。"},
		],
		"hazards": [],
		"pits": [
			{"rect": Rect2(700, 1180, 600, 120), "respawn": Vector2(640, 1100)},
		],
		"boss": {},
		"arena": Rect2(),
	}


static func _r12() -> Dictionary:
	return {
		"id": &"r12",
		"name": "苦痛之路·回廊",
		"seed": 141,
		"size": Vector2(4200, 1600),
		"spawn": Vector2(170, 1200),
		"theme": {"bg1": Color(0.045, 0.04, 0.035), "bg2": Color(0.12, 0.1, 0.08), "accent": Color(0.95, 0.72, 0.4)},
		"ground": [
			{"rect": Rect2(0, 1200, 520, 400), "seed": 142},
			{"rect": Rect2(3800, 900, 400, 700), "seed": 143},
		],
		"ledges": [
			{"rect": Rect2(900, 1120, 260, 26), "seed": 144},
			{"rect": Rect2(1400, 800, 300, 26), "seed": 145},
			{"rect": Rect2(2300, 740, 280, 26), "seed": 146},
			{"rect": Rect2(3050, 560, 300, 26), "seed": 147},
			{"rect": Rect2(3600, 440, 200, 26), "seed": 148},
		],
		"platforms": [
			{"pos": Vector2(680, 1150), "size": Vector2(160, 24), "move": Vector2(120, 0), "period": 3.2, "phase": 0.0},
			{"pos": Vector2(1260, 1000), "size": Vector2(160, 24), "move": Vector2(0, -160), "period": 3.0, "phase": 0.0},
			{"pos": Vector2(1830, 760), "size": Vector2(160, 24), "move": Vector2(0, -140), "period": 3.4, "phase": 0.0},
			{"pos": Vector2(2120, 780), "size": Vector2(160, 24), "move": Vector2(0, 140), "period": 3.4, "phase": 3.14159},
			{"pos": Vector2(3480, 620), "size": Vector2(160, 24), "move": Vector2(0, -180), "period": 3.0, "phase": 0.0},
		],
		"crumble": [
			{"pos": Vector2(2700, 690), "size": Vector2(140, 22), "delay": 0.6, "respawn": 2.8},
			{"pos": Vector2(2900, 620), "size": Vector2(140, 22), "delay": 0.6, "respawn": 2.8},
		],
		"saws": [
			{"pos": Vector2(1060, 1000), "radius": 26, "move": Vector2(0, 90), "period": 2.2},
			{"pos": Vector2(1550, 660), "radius": 24, "move": Vector2(160, 0), "period": 2.8},
			{"pos": Vector2(2800, 470), "radius": 26, "move": Vector2(0, 80), "period": 2.0, "phase": 1.0},
			{"pos": Vector2(3300, 500), "radius": 26, "move": Vector2(120, 0), "period": 2.6},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 900, 80, 300), "spawn": Vector2(170, 1200), "target": &"r11", "target_door": 1},
			{"side": "right", "trigger": Rect2(4120, 620, 80, 300), "spawn": Vector2(4000, 900), "target": &"r13", "target_door": 0},
		],
		"gates": [],
		"enemies": [],
		"pickups": [
			{"type": "geo", "pos": Vector2(1500, 740), "amount": 15},
			{"type": "geo", "pos": Vector2(3150, 500), "amount": 15},
		],
		"relics": [],
		"mask_shards": [],
		"benches": [],
		"lanterns": [Vector2(110, 1200)],
		"signs": [
			{"pos": Vector2(150, 1200), "text": "苦痛之路。\n脚下没有长椅，只有下一次跳跃。"},
			{"pos": Vector2(2350, 740), "text": "痛会记得你。\n石台也是。"},
		],
		"hazards": [],
		"pits": [
			{"rect": Rect2(520, 1500, 800, 100), "respawn": Vector2(470, 1200)},
			{"rect": Rect2(1320, 1500, 900, 100), "respawn": Vector2(1450, 800)},
			{"rect": Rect2(2220, 1500, 900, 100), "respawn": Vector2(2350, 740)},
			{"rect": Rect2(3120, 1500, 700, 100), "respawn": Vector2(3100, 560)},
		],
		"boss": {},
		"arena": Rect2(),
	}


static func _r13() -> Dictionary:
	return {
		"id": &"r13",
		"name": "苦痛之路·深井",
		"seed": 151,
		"size": Vector2(1800, 2600),
		"spawn": Vector2(180, 2400),
		"theme": {"bg1": Color(0.03, 0.032, 0.042), "bg2": Color(0.085, 0.09, 0.12), "accent": Color(0.8, 0.86, 0.92)},
		"ground": [
			{"rect": Rect2(0, 2400, 700, 200), "seed": 152},
		],
		"ledges": [
			{"rect": Rect2(220, 2260, 240, 26), "seed": 153},
			{"rect": Rect2(520, 2120, 240, 26), "seed": 154},
			{"rect": Rect2(820, 1980, 240, 26), "seed": 155},
			{"rect": Rect2(900, 1840, 600, 26), "seed": 156},
			{"rect": Rect2(1150, 560, 300, 26), "seed": 157},
			{"rect": Rect2(60, 440, 300, 26), "seed": 158},
		],
		"walls": [
			{"rect": Rect2(1200, 580, 40, 1070), "seed": 159},
			{"rect": Rect2(1440, 580, 40, 1070), "seed": 160},
		],
		"platforms": [
			{"pos": Vector2(950, 560), "size": Vector2(160, 24), "move": Vector2(0, -100), "period": 3.0, "phase": 0.0},
			{"pos": Vector2(700, 560), "size": Vector2(160, 24), "move": Vector2(140, 0), "period": 3.2, "phase": 0.0},
		],
		"saws": [
			{"pos": Vector2(1340, 1250), "radius": 28, "move": Vector2(0, 260), "period": 3.2},
			{"pos": Vector2(1340, 900), "radius": 28, "move": Vector2(0, 260), "period": 3.2, "phase": 3.14159},
			{"pos": Vector2(760, 480), "radius": 24, "move": Vector2(0, 80), "period": 2.6},
		],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 2140, 80, 260), "spawn": Vector2(180, 2400), "target": &"r12", "target_door": 1},
			{"side": "left", "trigger": Rect2(0, 340, 80, 260), "spawn": Vector2(180, 440), "target": &"r14", "target_door": 0},
		],
		"gates": [],
		"enemies": [],
		"pickups": [],
		"relics": [],
		"mask_shards": [],
		"benches": [],
		"lanterns": [Vector2(150, 2400), Vector2(920, 1800)],
		"signs": [
			{"pos": Vector2(140, 2400), "text": "苦痛之路·深井。\n向上，或者重新开始。"},
		],
		"hazards": [],
		"pits": [
			{"rect": Rect2(700, 2450, 1100, 150), "respawn": Vector2(620, 2400)},
		],
		"boss": {},
		"arena": Rect2(),
	}


static func _r14() -> Dictionary:
	return {
		"id": &"r14",
		"name": "王座之心",
		"seed": 161,
		"size": Vector2(1400, 900),
		"spawn": Vector2(180, 700),
		"theme": {"bg1": Color(0.035, 0.028, 0.03), "bg2": Color(0.11, 0.08, 0.07), "accent": Color(0.96, 0.62, 0.45)},
		"ground": [
			{"rect": Rect2(0, 700, 1400, 200), "seed": 162},
		],
		"ledges": [],
		"doors": [
			{"side": "left", "trigger": Rect2(0, 460, 80, 240), "spawn": Vector2(180, 700), "target": &"r13", "target_door": 1},
		],
		"gates": [],
		"enemies": [],
		"pickups": [],
		"relics": [],
		"mask_shards": [],
		"specials": [
			{"id": &"pain_heart", "title": "苦痛之心", "pos": Vector2(700, 560)},
		],
		"benches": [Vector2(240, 700)],
		"lanterns": [Vector2(200, 700), Vector2(1200, 700)],
		"signs": [
			{"pos": Vector2(560, 700), "text": "王座之心。\n苦痛没有尽头，但这里有一个。"},
		],
		"props": [
			{"type": "pillar", "pos": Vector2(440, 700)},
			{"type": "pillar", "pos": Vector2(960, 700)},
		],
		"hazards": [],
		"boss": {},
		"arena": Rect2(),
	}
