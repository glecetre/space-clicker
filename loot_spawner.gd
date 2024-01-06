class_name LootSpawner
extends Node


const LOOT_ITEM_SCN = preload("res://scenes/loot_item.tscn")


signal item_looted(item: LootItem)
signal frenzy_changed(is_frenzy: bool)


@export_group("Spawn")
@export var spawn_time_range: Vector2 = Vector2(5, 10)
@export var spawn_area_top_left: Marker2D
@export var spawn_area_bottom_right: Marker2D
@export var loot_end_position: Node2D
@export_group("Loot")
@export var loot_value_range: Vector2i = Vector2i(2, 10)
@export var loot_falling_duration: Vector2 = Vector2(2, 6)
@export_group("Frenzy")
@export var is_frenzy_enabled := false: set = _set_frenzy_enabled
@export var frenzy_spawn_time_range: Vector2 = Vector2(0.5, 1)
@export var frenzy_interval_range: Vector2 = Vector2(60, 120)
@export var frenzy_duration_range: Vector2 = Vector2(20, 40)
@export var frenzy_falling_duration_factor: float = 0.5
var is_frenzy := false


func _ready() -> void:
	_start_loot_timer()


func _on_spawn_timer_timeout() -> void:
	_spawn_falling_loot_item()
	_start_loot_timer()


func _on_frenzy_timer_timeout() -> void:
	if is_frenzy:
		print_debug("End of frenzy time :-(")
		is_frenzy = false
		_start_next_frenzy_timer()
	else:
		print_debug("Start of frenzy time!")
		is_frenzy = true
		_start_frenzy_duration_timer()
	
	frenzy_changed.emit(is_frenzy)


func _set_frenzy_enabled(value: bool) -> void:
	is_frenzy_enabled = value
	if is_frenzy_enabled:
		_start_next_frenzy_timer()
	else:
		$FrenzyTimer.stop()


func _start_loot_timer() -> void:
	var wait_time = 0
	
	if is_frenzy:
		wait_time = randf_range(frenzy_spawn_time_range.x, frenzy_spawn_time_range.y)
	else:
		wait_time = randf_range(spawn_time_range.x, spawn_time_range.y)
	
	if wait_time > 0:
		$SpawnTimer.start(wait_time)


func _start_next_frenzy_timer() -> void:
	var wait_time = randf_range(frenzy_interval_range.x, frenzy_interval_range.y)
	$FrenzyTimer.start(wait_time)
	print_debug("Next frenzy in %s seconds" % wait_time)


func _start_frenzy_duration_timer() -> float:
	var wait_time = randf_range(frenzy_duration_range.x, frenzy_duration_range.y)
	$FrenzyTimer.start(wait_time)
	print_debug("Frenzy duration is %s seconds" % wait_time)
	return wait_time


func _loot_item(item: LootItem) -> void:
	item_looted.emit(item)


func _spawn_falling_loot_item() -> void:
	var starting_position = Vector2.ZERO
	var ending_position = loot_end_position.position
	var area_size = spawn_area_bottom_right.position - spawn_area_top_left.position
	
	match randi_range(1, 4):
		1: # Top
			starting_position.x = randf()
		2: # Right
			starting_position.x = 1
			starting_position.y = randf()
		3: # Bottom
			starting_position.x = randf()
			starting_position.y = 1
		4: # Left
			starting_position.y = randf()
	
	starting_position *= area_size
	
	var new_loot_item: LootItem = LOOT_ITEM_SCN.instantiate()
	new_loot_item.position = starting_position
	new_loot_item.loot_value = randi_range(loot_value_range.x, loot_value_range.y)
	new_loot_item.looted.connect(_loot_item)
	
	var falling_duration = randf_range(loot_falling_duration.x, loot_falling_duration.y)
	if is_frenzy:
		falling_duration *= frenzy_falling_duration_factor
	
	var new_loot_item_tween = create_tween()
	new_loot_item_tween.tween_property(new_loot_item, "position", ending_position, falling_duration)
	
	add_child(new_loot_item)

