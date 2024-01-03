extends PanelContainer


@export var score = 0: set = _set_score
@export var acceleration = 0: set = _set_acceleration
@export var apm = 0.0: set = _set_apm
@export var game_state: GameState

var score_label_tween: Tween
var acceleration_label_tween: Tween
var label_tweens: Dictionary
@onready var acceleration_multiplier_gauge_steps = {
	1: %AccelerationMultiplierGaugeStep1Label,
	2: %AccelerationMultiplierGaugeStep2Label,
	4: %AccelerationMultiplierGaugeStep3Label,
	8: %AccelerationMultiplierGaugeStep4Label
}


func add_permanent_item(item: Item):
	var _new_upgrade_label = Label.new()
	_new_upgrade_label.text = item.display_name
	_new_upgrade_label.theme_type_variation = "WithBackgroundLabel"
	
	for _upgrade_node in %PermanentUpgradesList.get_children():
		if _new_upgrade_label.text < _upgrade_node.text:
			_upgrade_node.add_sibling(_new_upgrade_label)
			return
	
	%PermanentUpgradesList.add_child(_new_upgrade_label)


func _ready():
	game_state.acceleration_multiplier_changed.connect(_update_acceleration_multiplier)



func _set_acceleration(value: int):
	if acceleration == value:
		return
	
	var _old_acceleration = acceleration
	acceleration = value
	_update_label_text(%AccelerationValueLabel, _old_acceleration, acceleration)


func _set_score(value: int):
	if score == value:
		return

	var _score_delta = value - score
	
	score = value
	_update_label_text(%ScoreLabel, score - _score_delta, score)
	_update_last_score_increase_label(_score_delta)


func _set_apm(value: float):
	if apm == value:
		return
	
	apm = value
	%APMLabel.text = str(apm)


func _update_label_text(label: Label, from: Variant, to: Variant):
	if not is_node_ready():
		label.text = str(to)
		return
	
	if label_tweens.has(label):
		label_tweens[label].kill()
	
	label_tweens[label] = create_tween()
	label_tweens[label].tween_method(
		func(new_value: int): label.text = str(new_value),
		from,
		to,
		0.5
	)


func _update_last_score_increase_label(score_delta: int):
	if score_delta <= 0:
		return
	
	var _score_delta_label = %LastScoreIncreaseLabel.duplicate()
	_score_delta_label.position = %LastScoreIncreaseLabel.global_position
	_score_delta_label.text = "+%d" % score_delta
	%PopupTextLayer.add_child(_score_delta_label)
	
	var _score_delta_label_tween = create_tween().set_parallel()
	_score_delta_label_tween.tween_property(_score_delta_label, "modulate", Color(_score_delta_label.modulate, 0), 2)
	_score_delta_label_tween \
		.tween_property(_score_delta_label, "position", Vector2(_score_delta_label.position.x, _score_delta_label.position.y - 100), 2) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT)
	_score_delta_label_tween.chain().tween_callback(_score_delta_label.queue_free)


func _update_acceleration_multiplier(old_multiplier: int, new_multiplier: int) -> void:
	acceleration_multiplier_gauge_steps[old_multiplier].theme_type_variation = "GaugeLevelStepInactiveLabel"
	acceleration_multiplier_gauge_steps[new_multiplier].theme_type_variation = "GaugeLevelStepActiveLabel"
