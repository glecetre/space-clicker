class_name GameState
extends Node


signal score_changed(new_score: int, new_acceleration: int)
signal acceleration_multiplier_changed(old_multiplier: int, new_multiplier: int)
signal permanent_item_changed(item: Item, level: int)


@export var score: int = 0
@export var acceleration: int = 1
var acceleration_multiplier: int = 1
var permanent_items_levels: Dictionary


func _init():
	score_changed.emit(score, acceleration)


func purchase_item(item: Item, level: int) -> void:
	match item.code:
		Item.Code.CLICK_BOOSTER:
			acceleration += item.get_potency(level)
		Item.Code.AUTOCLICKER:
			%AutoclickTimer.start()
	
	if not item.is_repeatable:
		permanent_items_levels[item.code] = level
		permanent_item_changed.emit(item, level)
	
	_buy(item.get_price(level))


func click() -> void:
	score += acceleration * acceleration_multiplier
	score_changed.emit(score, acceleration)


func loot(loot_value: float) -> int:
	var _score_increment = roundi(loot_value * float(acceleration))
	score += _score_increment
	score_changed.emit(score, acceleration)
	return _score_increment


func set_clicker_scale(clicker_scale: float) -> void:
	var _old_multiplier = acceleration_multiplier
	acceleration_multiplier = _get_acceleration_multiplier(clicker_scale)
	acceleration_multiplier_changed.emit(_old_multiplier, acceleration_multiplier)


func _get_acceleration_multiplier(clicker_scale: float) -> int:
	if clicker_scale < 1.3:
		return 1
	if clicker_scale < 1.7:
		return 2
	if clicker_scale < 2.1:
		return 4
	
	return 8


func _buy(cost: int) -> void:
	score -= cost
	score_changed.emit(score, acceleration)
