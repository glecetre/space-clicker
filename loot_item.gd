class_name LootItem
extends Area2D


signal looted(item: LootItem)


enum ValueColor {
	GREY,
	GREEN,
	BLUE,
	PURPLE,
	YELLOW,
	RED,
}


const LOOT_COLOR_ANIMATION = {
	ValueColor.GREY: "grey",
	ValueColor.GREEN: "green",
	ValueColor.BLUE: "blue",
	ValueColor.PURPLE: "purple",
	ValueColor.YELLOW: "yellow",
	ValueColor.RED: "red",
}
const LOOT_COLOR_FACTOR = {
	ValueColor.GREY: 2,
	ValueColor.GREEN: 3,
	ValueColor.BLUE: 4,
	ValueColor.PURPLE: 6,
	ValueColor.YELLOW: 7,
	ValueColor.RED: 10,
}


@export var value_color: ValueColor = ValueColor.GREY


func _ready() -> void:
	rotation_degrees = randi_range(0, 359)
	%LootItemSprite.play(LOOT_COLOR_ANIMATION[value_color])


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		_on_click()


func _on_click():
	looted.emit(self)


func get_value() -> int:
	return LOOT_COLOR_FACTOR[value_color]
