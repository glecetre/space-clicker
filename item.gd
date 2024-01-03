extends Resource
class_name Item

enum ItemEffect { NONE, ACCELERATION_BOOST, AUTOCLICK, SHOP_LEVEL_INCREASE }

@export var code: String
@export var display_name: String
@export var display_description: String
@export var repeatable: bool = true
@export var effects: Array[ItemEffect]
@export var potency_scale: Dictionary
@export var price_scale: Dictionary


func get_price(level: int):
	var _scale_index = _get_scale_index(level)
	
	if _scale_index == null:
		return null

	return price_scale[_scale_index]


func get_potency(level: int):
	if potency_scale == null or potency_scale.size() == 0:
		return null
	
	var _scale_index = _get_scale_index(level)
	
	if _scale_index == null:
		return null
	
	return potency_scale[_scale_index]


func get_min_level():
	return price_scale.keys()[0]


func _get_scale_index(level: int):
	if price_scale.has(level):
		return level
	
	var _scale_index = null;
	for _index in price_scale.keys():
		if _index < level:
			_scale_index = _index
		else:
			break
	
	return _scale_index
