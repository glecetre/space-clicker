class_name ShopButton
extends PanelContainer

@export var item: Item: set = _set_item

signal pressed(item: Item)

@onready var name_label = %NameLabel
@onready var price_label = %PriceLabel
@onready var description_label = %DescriptionLabel
@onready var buy_button = %BuyButton


func disable(is_disabled = true):
	buy_button.disabled = is_disabled


func update_item_level(item_level: int):
	_update_controls(item_level)


func _ready():
	_update_controls()


func _set_item(value: Item):
	item = value
	_update_controls()


func _update_controls(item_level = 1):
	if is_node_ready():
		name_label.text = tr(item.display_name)
		price_label.text = "%s$$" % item.get_price(item_level)
		
		var _potency = item.get_potency((item_level))
		description_label.text = tr(item.display_description).format({"potency": _potency})


func _on_buy_button_pressed():
	pressed.emit(item)
