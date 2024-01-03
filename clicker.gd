class_name Clicker extends Area2D


signal clicked
signal scale_changed(scale: float)
signal area_collided(area: Area2D)


@export_range (0, 1) var scale_increase_rate: float = 0.01
@export_range(0, 1) var scale_decrease_rate: float = 0.5
@export var max_scale_factor: int = 4


var is_scaling_down = false


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_increase_scale()
		clicked.emit()


func _process(delta: float) -> void:
	if is_scaling_down and scale != Vector2.ONE:
		scale *= 1 - scale_decrease_rate * delta
		
		if scale.x < 1:
			scale = Vector2.ONE
		
		scale_changed.emit(scale.x)
	
	if is_scaling_down and scale <= Vector2.ONE:
		is_scaling_down = false


func _on_scale_reset_timer_timeout() -> void:
	is_scaling_down = true


func _increase_scale() -> void:
	is_scaling_down = false
	
	if scale.x < max_scale_factor:
		scale += Vector2(scale_increase_rate, scale_increase_rate)
		scale_changed.emit(scale.x)
	
	if scale.x > max_scale_factor:
		scale = Vector2(max_scale_factor, max_scale_factor)
	
	%ScaleResetTimer.start()


func _on_area_entered(area: Area2D) -> void:
	area_collided.emit(area)
