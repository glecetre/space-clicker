class_name ShopButton
extends PanelContainer


signal pressed(item: Item)


@export var item: Item: set = _set_item
@export var item_level: int = 1: set = _set_item_level
@onready var name_label = %NameLabel
@onready var price_label = %PriceLabel
@onready var description_label = %DescriptionLabel
@onready var buy_button = %BuyButton


func _ready() -> void:
	_update_controls()


func disable(is_disabled = true) -> void:
	buy_button.disabled = is_disabled


func _set_item(value: Item) -> void:
	item = value
	_update_controls()


func _set_item_level(value: int) -> void:
	item_level = value
	_update_controls()


func _update_controls() -> void:
	if is_node_ready():
		name_label.text = tr(item.display_name)
		price_label.text = "%s$$" % item.get_price(item_level)
		
		var _potency = item.get_potency(item_level)
		description_label.text = tr(item.display_description).format({"potency": _potency})


func _on_buy_button_pressed() -> void:
	pressed.emit(item)
