class_name CameraRig
extends Camera2D

var target: Node2D
var bounds := Rect2(0, 0, 1280, 720)
var shake_amount := 0.0
var _initialized := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	position_smoothing_enabled = false


func set_bounds(rect: Rect2) -> void:
	bounds = rect


func add_shake(amount: float) -> void:
	shake_amount = maxf(shake_amount, amount)


func snap_to_target() -> void:
	if target == null:
		return
	position = _goal_position()
	offset = Vector2.ZERO


func _goal_position() -> Vector2:
	if target == null:
		return position
	var goal := target.global_position + Vector2(0, -96)
	var lead: float = 0.0
	if "facing" in target:
		lead = float(target.get("facing")) * 68.0
	if "velocity" in target:
		lead += clampf(float(target.get("velocity").x) * 0.14, -70.0, 70.0)
	goal.x += lead
	var view := get_viewport().get_visible_rect().size / zoom
	var half := view * 0.5
	if bounds.size.x <= view.x:
		goal.x = bounds.get_center().x
	else:
		goal.x = clampf(goal.x, bounds.position.x + half.x, bounds.end.x - half.x)
	if bounds.size.y <= view.y:
		goal.y = bounds.get_center().y
	else:
		goal.y = clampf(goal.y, bounds.position.y + half.y, bounds.end.y - half.y)
	return goal


func _process(delta: float) -> void:
	if target == null:
		return
	var goal := _goal_position()
	if not _initialized:
		position = goal
		_initialized = true
	else:
		position = position.lerp(goal, 1.0 - exp(-7.5 * delta))
	shake_amount = move_toward(shake_amount, 0.0, delta * 42.0)
	if shake_amount > 0.2:
		offset = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * shake_amount
	else:
		offset = Vector2.ZERO
