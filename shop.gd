class_name Shop
extends Node


signal item_purchased(item: Item, level: int)


const ITEM_RESOURCES_FOLDER_PATH = "res://items"
const ShopButtonScn = preload("res://scenes/shop_button.tscn")
#region Items list
# Run shop_items_lister.gd to set this value
# Not working: https://github.com/godotengine/godot/issues/72563
const ITEM_RESOURCE_FILES = [
	"res://items/click_booster.tres",
	"res://items/shop_improvement.tres",
	"res://items/autoclicker.tres",
	"res://items/star_catcher.tres",
	"res://items/star_field.tres"
]
#endregion

var catalog: Dictionary
var purchased_items_levels: Dictionary
var level: int = 0 # Increased when scene ready
var current_credit := 0
@onready var items_list := %ItemsList
@onready var level_label := %LevelLabel


func _init():
	_load_catalog()
	
	
func _ready():
	_increase_level()


func update_credit(credit: int) -> void:
	current_credit = credit
	_update_buttons()


func _increase_level() -> void:
	level += 1
	level_label.text = tr("SHOP.SUBTITLE").format({"level" = level})
	_reset_buttons()


func _on_item_button_pressed(button: ShopButton) -> void:
	purchased_items_levels[button.item.code] = button.item_level
	
	if not button.item.is_repeatable:
		button.queue_free()
		_create_item_button_if_available(button.item)
	
	if button.item.code == Item.Code.SHOP_IMPROVEMENT:
		_increase_level()
	
	item_purchased.emit(button.item, button.item_level)


func _update_buttons() -> void:
	for button in items_list.get_children():
		button.disable(not _is_item_buyable(button.item))


func _reset_buttons() -> void:
	for item_button in items_list.get_children():
		item_button.queue_free()
	
	for item_code in catalog:
		_create_item_button_if_available(catalog[item_code])


func _create_item_button_if_available(item: Item) -> void:
	var purchased_item_level = _get_purchased_item_level(item)
	var next_item_level = \
		purchased_item_level + 1 if not item.is_repeatable \
		else level
	
	var required_shop_level = item.get_required_shop_level(next_item_level)
		
	if required_shop_level >= 0 and level >= required_shop_level:
		_create_item_button(item, next_item_level)


func _create_item_button(item: Item, item_level: int) -> void:
	var _button = ShopButtonScn.instantiate()
	_button.item = item
	_button.item_level = item_level
	
	items_list.add_child(_button)
	
	_button.disable(not _is_item_buyable(item))
	_button.pressed.connect(func(_item): _on_item_button_pressed(_button))


func _load_catalog() -> void:
	for item_resource_file in ITEM_RESOURCE_FILES:
		var item = load(item_resource_file)
		catalog[item.code] = item


func _is_item_buyable(item: Item) -> bool:
	var item_level: int = _get_purchased_item_level(item) + 1
	var required_shop_level = item.get_required_shop_level(item_level)
	
	return current_credit >= item.get_price(item_level) \
		and required_shop_level >= 0 \
		and required_shop_level <= level


func _get_purchased_item_level(item: Item) -> int:
	return purchased_items_levels[item.code] if item.code in purchased_items_levels else 0
