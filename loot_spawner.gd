extends Node


signal item_looted(item: LootItem)


@export var LootItemScn: PackedScene
@export var spawn_time_range: Vector2 = Vector2(5, 10)
@export var loot_value_range: Vector2 = Vector2(2, 10)
@export var spawn_area_top_left: Marker2D
@export var spawn_area_bottom_right: Marker2D
@export var loot_end_position: Node2D


func _ready():
	$SpawnTimer.start()


func _on_spawn_timer_timeout():
	_spawn_falling_loot_item()
	_start_new_random_timer()


func _start_new_random_timer():
	var _wait_time = randf_range(spawn_time_range.x, spawn_time_range.y)
	$SpawnTimer.start(_wait_time)


func _loot_item(item: LootItem):
	item_looted.emit(item)


func _spawn_falling_loot_item():
	var _starting_position = Vector2.ZERO
	var _ending_position = loot_end_position.position
	var _area_size = spawn_area_bottom_right.position - spawn_area_top_left.position
	
	var _random_border = randi_range(1, 4)
	match randi_range(1, 4):
		1: # Top
			_starting_position.x = randf()
		2: # Right
			_starting_position.x = 1
			_starting_position.y = randf()
		3: # Bottom
			_starting_position.x = randf()
			_starting_position.y = 1
		4: # Left
			_starting_position.y = randf()
	
	_starting_position *= _area_size
	
	var _new_loot_item = LootItemScn.instantiate()
	_new_loot_item.position = _starting_position
	_new_loot_item.loot_value = randf_range(loot_value_range.x, loot_value_range.y)
	_new_loot_item.looted.connect(_loot_item)
	
	var _new_loot_item_tween = create_tween()
	_new_loot_item_tween.tween_property(_new_loot_item, "position", _ending_position, 6)
	
	add_child(_new_loot_item)

