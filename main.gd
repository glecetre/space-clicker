extends Node


const STAR_CATCHER_SCN = preload("res://scenes/star_catcher.tscn")


var apm_clicks_count = 0
var star_catcher: StarCatcher


func _on_clicker_clicked() -> void :
	apm_clicks_count += 1
	$GameState.click()


func _on_clicker_area_collided(area: Area2D) -> void:
	if not area is LootItem:
		return
	
	var _area_tween = create_tween().set_parallel()
	_area_tween.tween_property(area, "scale", area.scale * Vector2(0.5, 0.5), 0.1)
	_area_tween.tween_property(area, "modulate", Color(area.modulate, 0), 0.1)
	_area_tween.chain().tween_callback(area.queue_free)


func _on_clicker_scale_changed(scale: float, size: Vector2) -> void:
	$GameState.set_clicker_scale(scale)
	
	if star_catcher:
		star_catcher.inner_radius = size.x + 40


func _on_game_state_score_changed(new_score: int, new_acceleration: int):
	%UserInterface.score = new_score
	%UserInterface.acceleration = new_acceleration
	%Shop.update_credit(new_score)


func _on_game_state_permanent_item_changed(item: Item, level: int):
	if item.code == Item.Code.STAR_CATCHER:
		_update_star_catcher(item, level)


func _on_shop_item_purchased(item: Item, level: int):
	$GameState.purchase_item(item, level)


func _on_loot_spawner_item_looted(loot_item: LootItem):
	_loot_item(loot_item)


func _on_star_catcher_loot_item_entered(item: LootItem) -> void:
	_loot_item(item)


func _on_apm_timer_timeout():
	%UserInterface.apm = apm_clicks_count / %APMTimer.wait_time
	apm_clicks_count = 0


func _show_popup_label(label: Label):
	add_child(label)
	
	var _label_tween = create_tween().set_parallel()
	_label_tween.tween_property(label, "modulate", Color(label.modulate, 0), 2)
	_label_tween.tween_property(label, "position", label.position + Vector2(0, -50), 2) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT)
	_label_tween.tween_property(label, "scale", label.scale * Vector2(1.2, 1.2), 1.5) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)
	_label_tween.chain().tween_callback(label.queue_free)


func _loot_item(loot_item: LootItem) -> void:
	var _score_increment = $GameState.loot(loot_item.loot_value)
	
	var _label = Label.new()
	_label.text = "+ %s $$" % _score_increment
	_label.position = loot_item.position
	_label.theme_type_variation = "LootValuePopupLabel"
	_show_popup_label(_label)
	
	var _loot_item_tween = create_tween().set_parallel()
	_loot_item_tween.tween_property(loot_item, "scale", loot_item.scale * Vector2(1.2, 1.2), 0.1)
	_loot_item_tween.tween_property(loot_item, "modulate", Color(loot_item.modulate, 0), 0.1)
	_loot_item_tween.chain().tween_callback(loot_item.queue_free)


func _update_star_catcher(item: Item, level: int) -> void:
	if not star_catcher:
		star_catcher = STAR_CATCHER_SCN.instantiate()
		star_catcher.position = $Clicker.position
		star_catcher.loot_item_entered.connect(_loot_item)
		add_child(star_catcher)
	
	star_catcher.outer_radius = 260
	star_catcher.inner_radius = 88
	star_catcher.to_angle_deg = item.get_potency(level)
	star_catcher.rotation_speed = 36
