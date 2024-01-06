class_name StarCatcher
extends Area2D


signal loot_item_entered(item: LootItem)


@export var color := Color("#86deef64"): set = _set_color
@export var outer_radius: float = 0: set = _set_outer_radius
@export var inner_radius: float = 0: set = _set_inner_radius
@export_range(0, 360) var from_angle_deg: float = 0: set = _set_from_angle_deg
@export_range(0, 360) var to_angle_deg: float = 0: set = _set_to_angle_deg
@export var rotation_speed: float = 0: set = _set_rotation_speed
@export var points_count: int = 32: set = _set_points_count
var drawing_tween: Tween
var drawing_tween_value: float


func _ready() -> void:
	_start_drawing()


func _draw() -> void:
	var points = _get_polygon_points(drawing_tween_value)
	draw_polygon(points, PackedColorArray([color]))
	$CollisionPolygon.polygon = points


func _process(delta: float) -> void:
	if rotation_speed > 0:
		rotation_degrees += rotation_speed * delta


func _start_drawing(previous_to_angle_deg: float = 0) -> void:
	if not is_node_ready():
		return
	
	if drawing_tween:
		drawing_tween.kill()
	
	drawing_tween = create_tween() \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT)
	
	drawing_tween.tween_method(
		func(value: float): 
			drawing_tween_value = value
			queue_redraw(), 
		previous_to_angle_deg,
		to_angle_deg,
		2
	)


func _get_polygon_points(to_angle_deg_override: float) -> PackedVector2Array:
	var outer_line_points = PackedVector2Array()
	var inner_line_points = PackedVector2Array()
	
	for i in range(points_count + 1):
		var angle_point = deg_to_rad(from_angle_deg + i * (to_angle_deg_override - from_angle_deg) / points_count - 90)
		var normalized_coordinated = Vector2(cos(angle_point), sin(angle_point))
		outer_line_points.append(normalized_coordinated * outer_radius)
		inner_line_points.append(normalized_coordinated * inner_radius)
	
	inner_line_points.reverse()
	outer_line_points.append_array(inner_line_points)
	return outer_line_points


func _on_area_entered(area: Area2D) -> void:
	if area is LootItem:
		loot_item_entered.emit(area)


func _set_color(value: Color) -> void:
	color = value
	_start_drawing()


func _set_outer_radius(value: float) -> void:
	outer_radius = value
	_start_drawing()


func _set_inner_radius(value: float) -> void:
	inner_radius = value
	_start_drawing()


func _set_from_angle_deg(value: float) -> void:
	from_angle_deg = value
	_start_drawing()


func _set_to_angle_deg(value: float) -> void:
	var previous_to_angle_deg = to_angle_deg
	to_angle_deg = value
	_start_drawing(previous_to_angle_deg)


func _set_rotation_speed(value: float) -> void:
	rotation_speed = value
	_start_drawing()


func _set_points_count(value: int) -> void:
	points_count = value
	_start_drawing()

