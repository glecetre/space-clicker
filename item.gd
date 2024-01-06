class_name Item
extends Resource


enum Code {
	CLICK_BOOSTER,
	SHOP_IMPROVEMENT,
	AUTOCLICKER,
	STAR_CATCHER,
	STAR_FIELD,
}

@export var code: Code
@export var display_name: String
@export var display_description: String
@export var is_repeatable: bool = false
@export var potency_scale: Dictionary
@export var price_scale: Dictionary
@export var shop_level_requirement: Dictionary


func get_price(item_level: int) -> int:
	if is_repeatable:
		return price_scale[1] * item_level
	
	if price_scale.has(item_level):
		return price_scale[item_level]
	
	return -1


func get_potency(item_level: int) -> int:
	if potency_scale == null or potency_scale.size() == 0:
		return -1
	
	if is_repeatable:
		return potency_scale[1] * item_level
	
	if potency_scale.has(item_level):
		return potency_scale[item_level]
	
	return -1


func get_min_shop_level() -> int:
	return shop_level_requirement[1]


func get_required_shop_level(item_level: int) -> int:
	if is_repeatable:
		return get_min_shop_level()
	
	if shop_level_requirement.has(item_level):
		return shop_level_requirement[item_level]
	
	return -1
