extends Node
class_name Shop


const ITEM_RESOURCES_FOLDER_PATH = "res://items"
const ShopButtonScn = preload("res://scenes/shop_button.tscn")


signal item_purchased(item: Item, level: int)


# Run shop_items_lister.gd to set this value
# Not working: https://github.com/godotengine/godot/issues/72563
@export var item_resource_files: Array[String] = ["res://items/click_booster.tres", "res://items/shop_improvement.tres", "res://items/autoclicker.tres"]


@onready var items_list := %ItemsList
@onready var level_label := %LevelLabel
var catalog: Dictionary
var tree: Dictionary
var one_time_purchases: Dictionary
var level: int = 0
var current_credit := 0


func update_credit(credit: int) -> void:
	current_credit = credit
	_update_buttons()

func _init():
	_load_catalog()
	
	
func _ready():
	_increase_level()


func _increase_level() -> void:
	level += 1
	level_label.text = tr("SHOP.SUBTITLE").format({"level" = level})
	_unlock_level_items(level)


func _on_item_button_pressed(button: ShopButton) -> void:
	if !button.item.repeatable:
		one_time_purchases[button.item.code] = true
		button.queue_free()
	
	if button.item.effects.has(Item.ItemEffect.SHOP_LEVEL_INCREASE):
		_increase_level()
		item_purchased.emit(button.item, level - 1)
	else:
		item_purchased.emit(button.item, level)


func _update_buttons() -> void:
	for _button in items_list.get_children():
		_button.disable(current_credit < _button.item.get_price(level))
		_button.update_item_level(level)


func _unlock_level_items(level_to_unlock: int) -> void:
	if not tree.has(level_to_unlock):
		return
		
	for item in tree[level_to_unlock]:
		_create_item_button(item)


func _create_item_button(item: Item) -> void:
	var _button = ShopButtonScn.instantiate()
	_button.item = item
	items_list.add_child(_button)
	_button.disable(current_credit < item.get_price(level))
	_button.pressed.connect(func(_item): _on_item_button_pressed(_button))


func _load_catalog() -> void:
	for item_resource_file in item_resource_files:
		var item = load(item_resource_file)
		catalog[item.code] = item
	
		var _item_min_level = item.get_min_level()
		if tree.has(_item_min_level):
			tree[_item_min_level].append(item)
		else:
			tree[_item_min_level] = [item]

