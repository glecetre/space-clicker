extends Node


const FLOAT_EFFECT_MAX_STRAY = 10

@onready var floating_node = %SubtitleLabel
var initial_title_position: Vector2


func _ready():
	floating_node.pivot_offset = floating_node.size / 2
	initial_title_position = floating_node.position
	_start_title_movement()


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _start_title_movement():
	# Calculate next position
	var _current_position = floating_node.position
	
	var _delta_x = randf_range(-5, 5)
	if abs(initial_title_position.x - _current_position.x + _delta_x) > FLOAT_EFFECT_MAX_STRAY:
		_delta_x *= -1 
	
	var _delta_y = randf_range(-5, 5)
	if abs(initial_title_position.y - _current_position.y + _delta_y) > FLOAT_EFFECT_MAX_STRAY:
		_delta_y *= -1 
		
	var _next_position = _current_position + Vector2(_delta_x, _delta_y)
	
	# Calculate next rotation
	var _current_rotation_degrees = floating_node.rotation_degrees
	
	var _delta_rotation_degrees = randf_range(-1, 1)
	if abs(_current_rotation_degrees + _delta_rotation_degrees) > FLOAT_EFFECT_MAX_STRAY:
		_delta_rotation_degrees *= -1
	
	var _next_rotation_degrees = _current_rotation_degrees + _delta_rotation_degrees
	
	# Tween the changes
	var _tween = create_tween().set_parallel()
	_tween.tween_property(floating_node, "position", _next_position, 1)
	_tween.tween_property(floating_node, "rotation_degrees", _next_rotation_degrees, 1)
	_tween.chain().tween_callback(_start_title_movement)

