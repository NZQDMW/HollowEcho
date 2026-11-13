extends Node

signal masks_changed(masks: int, max_masks: int)
signal soul_changed(soul: float, max_soul: float)
signal geo_changed(geo: int)
signal relic_gained(relic_id: StringName, title: String)
signal room_changed(room_id: StringName, room_name: String)
signal toast(text: String)
signal boss_state(active: bool, title: String, hp: int, max_hp: int)
signal shade_changed(active: bool)
signal prompt_changed(text: String)
signal dialogue_requested(npc: Node)
signal ending

const MAX_SOUL := 99.0
const HEAL_COST := 33.0
const SPELL_COST := 33.0

var max_masks := 4
var masks := 4
var max_soul := MAX_SOUL
var soul := 0.0
var geo := 0
var nail_bonus := 0
var relics := {
	"dash": false, "wall": false, "double": false,
	"key": false, "echo": false,
}
var visited := {}
var taken_pickups := {}
var shop_purchases := {}
var bosses_defeated := {}
var current_room: StringName = &"r1"
var bench_room: StringName = &"r1"
var bench_pos := Vector2(360.0, 760.0)
var shade := {}
var boss_defeated := false
var deaths := 0
var play_seconds := 0.0
var running := false
var dialogue_cooldown := 0.0


func _process(delta: float) -> void:
	if running:
		play_seconds += delta
	dialogue_cooldown = maxf(0.0, dialogue_cooldown - delta)


func reset_run() -> void:
	max_masks = 4
	masks = 4
	max_soul = MAX_SOUL
	soul = 0.0
	geo = 0
	nail_bonus = 0
	relics = {
		"dash": false, "wall": false, "double": false,
		"key": false, "echo": false,
	}
	visited = {"r1": true}
	taken_pickups = {}
	shop_purchases = {}
	bosses_defeated = {}
	current_room = &"r1"
	bench_room = &"r1"
	bench_pos = Vector2(360.0, 680.0)
	shade = {}
	boss_defeated = false
	deaths = 0
	play_seconds = 0.0
	running = false
	dialogue_cooldown = 0.0
	masks_changed.emit(masks, max_masks)
	soul_changed.emit(soul, max_soul)
	geo_changed.emit(geo)
	shade_changed.emit(false)


func hurt(amount: int) -> bool:
	masks = maxi(0, masks - amount)
	masks_changed.emit(masks, max_masks)
	return masks <= 0


func heal(amount: int) -> void:
	masks = mini(max_masks, masks + amount)
	masks_changed.emit(masks, max_masks)


func add_masks(amount: int) -> void:
	max_masks += amount
	masks = max_masks
	masks_changed.emit(masks, max_masks)


func add_soul(amount: float) -> void:
	soul = clampf(soul + amount, 0.0, max_soul)
	soul_changed.emit(soul, max_soul)


func spend_soul(amount: float) -> bool:
	if soul < amount:
		return false
	soul = maxf(0.0, soul - amount)
	soul_changed.emit(soul, max_soul)
	return true


func add_soul_cap(amount: float) -> void:
	max_soul += amount
	soul = max_soul
	soul_changed.emit(soul, max_soul)


func add_geo(amount: int) -> void:
	geo += amount
	geo_changed.emit(geo)


func gain_relic(relic_id: StringName, title: String) -> void:
	relics[relic_id] = true
	relic_gained.emit(relic_id, title)
	toast.emit("获得 · %s" % title)


func has_relic(relic_id: StringName) -> bool:
	return bool(relics.get(relic_id, false))


func shop_bought(key: StringName) -> int:
	return int(shop_purchases.get(key, 0))


func purchase(item: Dictionary) -> bool:
	var key: StringName = item.get("key", &"")
	var price := int(item.get("price", 0))
	var max_count := int(item.get("max", 1))
	var bought := shop_bought(key)
	if bought >= max_count:
		toast.emit("这件东西你已经买过了。")
		return false
	if geo < price:
		toast.emit("吉欧不够。再去外面找找吧。")
		return false
	geo -= price
	geo_changed.emit(geo)
	shop_purchases[key] = bought + 1
	match key:
		&"mask":
			add_masks(1)
			toast.emit("拾得面具碎片 · 生命上限提升")
		&"soul":
			add_soul_cap(33.0)
			toast.emit("获得 · 灵魂容器 · 灵魂上限提升")
		&"nail":
			nail_bonus += 1
			toast.emit("骨钉被磨得更锋利了 · 伤害提升")
		&"key":
			gain_relic(&"key", "锈蚀钥匙")
	return true


func reward_echo_boss() -> void:
	add_masks(1)
	nail_bonus += 1
	add_soul_cap(33.0)
	gain_relic(&"echo", "回响之心")
	toast.emit("钟鸣守卫倒下了。回响之心在你胸腔里跳动。")


func save_bench(room_id: StringName, pos: Vector2) -> void:
	bench_room = room_id
	bench_pos = pos
	masks = max_masks
	masks_changed.emit(masks, max_masks)
	toast.emit("已在此处留下印记。生命与灵魂已恢复。")


func on_player_death(room_id: StringName, pos: Vector2) -> void:
	deaths += 1
	if not shade.is_empty():
		shade = {}
	if geo > 0:
		shade = {"room": room_id, "pos": pos, "geo": geo}
		geo = 0
		geo_changed.emit(geo)
	shade_changed.emit(not shade.is_empty())
	masks = max_masks
	masks_changed.emit(masks, max_masks)
	soul = 0.0
	soul_changed.emit(soul, MAX_SOUL)


func reclaim_shade() -> void:
	if shade.is_empty():
		return
	var amount: int = int(shade.get("geo", 0))
	geo += amount
	shade = {}
	geo_changed.emit(geo)
	shade_changed.emit(false)
	if amount > 0:
		toast.emit("取回了 %d 吉欧。" % amount)
	else:
		toast.emit("回响消散了。")


func trigger_ending() -> void:
	if boss_defeated:
		return
	boss_defeated = true
	ending.emit()
