extends Node
class_name GameState


signal score_changed(new_score: int, new_acceleration: int)
signal acceleration_multiplier_changed(old_multiplier: int, new_multiplier: int)
signal permanent_item_added(item: Item)


@export var score: int = 0
@export var acceleration: int = 1
@export var is_autoclicking: bool = false


var acceleration_multiplier: int = 1


func _init():
	score_changed.emit(score, acceleration)


func purchase_item(item: Item, level: int) -> void:
	for effect in item.effects:
		match effect:
			Item.ItemEffect.ACCELERATION_BOOST:
				acceleration += item.get_potency(level)
			Item.ItemEffect.AUTOCLICK:
				permanent_item_added.emit(item)
				%AutoclickTimer.start()
				
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
