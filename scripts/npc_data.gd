class_name NpcData
extends RefCounted


static func get_npc(id: StringName) -> Dictionary:
	match id:
		&"merchant": return _merchant()
		&"lorekeeper": return _lorekeeper()
	return {}


static func _merchant() -> Dictionary:
	return {
		"id": &"merchant",
		"name": "灰烬商人·墨",
		"style": "merchant",
		"prompt": "E  与商人交谈",
		"pages": [
			"静默集市不做亏本的买卖。\n你带在身上的回响，我隔着半条街就听见了。",
			"吉欧是这片废墟里唯一还肯流通的东西。\n挑吧——只要付得起。",
		],
		"shop": [
			{"key": &"mask", "name": "面具碎片", "desc": "生命上限 +1", "price": 40, "max": 2},
			{"key": &"soul", "name": "灵魂容器", "desc": "灵魂上限 +33", "price": 70, "max": 1},
			{"key": &"nail", "name": "骨钉磨石", "desc": "骨钉伤害 +1", "price": 90, "max": 1},
			{"key": &"key", "name": "锈蚀钥匙", "desc": "开启集市深处的大门", "price": 40, "max": 1},
		],
		"shop_intro": "看中了，就用骨钉敲敲柜台。",
	}


static func _lorekeeper() -> Dictionary:
	return {
		"id": &"lorekeeper",
		"name": "记录者·铃",
		"style": "lorekeeper",
		"prompt": "E  倾听记录者",
		"pages": [
			"……你听见了吗？钟声。\n它从很深的地方传上来，像有人在水底敲一面破钟。",
			"这里从前叫静默集市。王国还没沉下去的时候，\n虫群在这里交换光、盐和名字。",
			"后来光熄了，盐化成了灰，名字被回响一点点吃掉。\n只剩下我们这些不肯走的。",
			"东边的洞窟里挂着那口钟。守着它的东西早就不是活物了，\n只剩一个不肯停下的念头。",
			"往里走吧。面具挡得住刀锋，挡不住回响——\n但有时候，回响也会替你把门打开。",
		],
		"shop": [],
	}
