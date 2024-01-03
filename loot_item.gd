class_name LootItem
extends Area2D


signal looted(item: LootItem)


@export var loot_value: float = 0


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		_on_click()


func _on_click():
	looted.emit(self)

