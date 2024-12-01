class_name CardScroller
extends ScrollContainer


@export var card_scale: float = 1.0 # (float, 0.5, 1, 0.1)
@export var card_current_scale: float = 1.3 # (float, 1, 1.5, 0.1)
@export var scroll_duration: float = 1.3 # (float, 0.1, 1, 0.1)

var card_current_index: int = 0
var card_x_positions: Array = []

@onready var scroll_tween: Tween 
@onready var margin_r: int = $CenterContainer/MarginContainer.get("theme_override_constants/margin_right")
@onready var card_space: int = $CenterContainer/MarginContainer/HBoxContainer.get("theme_override_constants/separation")
@onready var card_nodes: Array = $CenterContainer/MarginContainer/HBoxContainer.get_children()

@onready var arkana_label: Label = $CenterContainer/MarginContainer/HBoxContainer/Arkana/ArkanaLabel
@onready var casley_label: Label = $CenterContainer/MarginContainer/HBoxContainer/Casley/CasleyLabel
@onready var lungyos_label: Label = $CenterContainer/MarginContainer/HBoxContainer/Lungyos/LungyosLabel



func _ready() -> void:	
	get_h_scroll_bar().modulate.a = 0	
	call_deferred("_set_initial_positions")
	arkana_label.hide()
	casley_label.hide()
	lungyos_label.hide()

func _set_initial_positions()->void:
	for _card in card_nodes:
		var _card_pos_x: float = (margin_r + _card.position.x) - ((size.x - _card.size.x) / 2)		
		_card.pivot_offset = (_card.size / 2)
		card_x_positions.append(_card_pos_x)
	scroll_horizontal = card_x_positions[card_current_index]
	scroll()

func _process(_delta: float) -> void:
	for _index in range(card_x_positions.size()):
		var _card_pos_x: float = card_x_positions[_index]
		var _swipe_length: float = (card_nodes[_index].size.x / 2.0) + (card_space / 2.0)
		var _swipe_current_length: float = abs(_card_pos_x - scroll_horizontal)
		var _card_scale: float = remap(_swipe_current_length, _swipe_length, 0, card_scale, card_current_scale)
		var _card_opacity: float = remap(_swipe_current_length, _swipe_length, 0, 0.3, 1)
		
		_card_scale = clamp(_card_scale, card_scale, card_current_scale)
		_card_opacity = clamp(_card_opacity, 0.3, 1)
		
		card_nodes[_index].scale = Vector2(_card_scale, _card_scale)
		card_nodes[_index].modulate.a = _card_opacity
		
		if _swipe_current_length < _swipe_length:
			card_current_index = _index
	
	

func scroll() -> void:	
	scroll_tween = create_tween().set_parallel(true)
	scroll_tween.tween_property(
		self,
		"scroll_horizontal",
		card_x_positions[card_current_index],
		scroll_duration).from(scroll_horizontal).set_trans(scroll_tween.TRANS_BACK).set_ease(scroll_tween.EASE_OUT)
	
	for _index in range(card_nodes.size()):
		var _card_scale: float = card_current_scale if _index == card_current_index else card_scale
		scroll_tween.tween_property(
			card_nodes[_index],
			"scale",
			Vector2(_card_scale,_card_scale),
			scroll_duration,).from(card_nodes[_index].scale).set_trans(scroll_tween.TRANS_QUAD).set_ease(scroll_tween.EASE_OUT)
		
		
	
	match card_current_index:
		0:
			arkana_label.show()
			casley_label.hide()
			lungyos_label.hide()
			arkana_label.text = "Arkana"
			PlanetLoad.current_planet = 0
			
		1:
			casley_label.show()
			arkana_label.hide()
			lungyos_label.hide()
			casley_label.text = "Casley"
			PlanetLoad.current_planet = 1
		2:
			lungyos_label.show()
			arkana_label.hide()
			casley_label.hide()
			lungyos_label.text = "Lungyos"
			PlanetLoad.current_planet = 2
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		
		# Planet Scroller
		if event.is_action_pressed("move_right") and card_current_index < card_x_positions.size() - 1:
			card_current_index += 1
			scroll()
		if event.is_action_pressed("move_left") and card_current_index > 0:
			card_current_index -= 1
			scroll()
