extends Control

# Control Inputs
@onready var input_button_scene = preload("res://UI/Options/input_button.tscn")
@onready var action_list = $TabContainer/Controls/MarginContainer/VBoxContainer/ScrollContainer/ActionList

# Window Type
@onready var window_type = $TabContainer/Graphics/MarginContainer/VBoxContainer/ScrollContainer/GraphicsContainer/WindowType/WindowTypeLabel

# Audio Values
@onready var master_value = $"TabContainer/Audio Settings/MarginContainer/VBoxContainer/ScrollContainer/AudioContainer/HBoxMaster/VolValue"
@onready var sfx_value = $"TabContainer/Audio Settings/MarginContainer/VBoxContainer/ScrollContainer/AudioContainer/HBoxSFX/VolValue"

# Volume Warnings
@onready var music_recomended = $"TabContainer/Audio Settings/MarginContainer/VBoxContainer/ScrollContainer/AudioContainer/MusicRecomendation"
@onready var sfx_recomended = $"TabContainer/Audio Settings/MarginContainer/VBoxContainer/ScrollContainer/AudioContainer/SfxRecomendation"
@onready var music_warning = $"TabContainer/Audio Settings/MarginContainer/VBoxContainer/ScrollContainer/AudioContainer/MusicWarning"
@onready var sfx_warning = $"TabContainer/Audio Settings/MarginContainer/VBoxContainer/ScrollContainer/AudioContainer/SfxWarning"

var is_remapping = false
var action_to_remap = null
var remapping_button = null

## Control Settings

var input_actions_controls = {
	"move_up": "Move Up",
	"move_left": "Move Left",
	"move_down": "Move Down",
	"move_right": "Move Right",
	"interact": "Player Interaction"
}

func _ready():
	# Volume Warnings
	music_warning.hide()
	sfx_warning.hide()
	music_recomended.show()
	sfx_recomended.show()
	
	_create_action_list()

func _create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions_controls:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions_controls[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."


func _input(event):
	if is_remapping:
		if(
			event is InputEventKey ||
			(event is InputEventMouseButton && event.pressed)
		):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()

func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

## Audio Settings

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	master_value.text = str(value+50) + "%"
	
	if AudioServer.get_bus_volume_db(0) >= 0:
		music_recomended.show()
	
	if AudioServer.get_bus_volume_db(0) > 0 || AudioServer.get_bus_volume_db(0) < 0:
		music_recomended.hide()
	
	if AudioServer.get_bus_volume_db(0) >= 10:
		music_warning.show()
		music_warning.text = "Beware, going over 60% might cause some hearing issues."
	else:
		music_warning.hide()
	
	if AudioServer.get_bus_volume_db(0) >= 25:
		music_warning.show()
		music_warning.text = "Why are you like this? :("
	
	if AudioServer.get_bus_volume_db(0) >= 50:
		music_warning.show()
		music_warning.text = "Congratulations! You are now deaf!"

func _on_sfx_vol_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, value)
	sfx_value.text = str(value+50) + "%"
	
	if AudioServer.get_bus_volume_db(1) >= 0:
		sfx_recomended.show()
	
	if AudioServer.get_bus_volume_db(1) > 0 || AudioServer.get_bus_volume_db(1) < 0:
		sfx_recomended.hide()
	
	if AudioServer.get_bus_volume_db(1) >= 10:
		sfx_warning.show()
		sfx_warning.text = "Beware, going over 60% might cause some hearing issues."
	else:
		sfx_warning.hide()
	
	if AudioServer.get_bus_volume_db(1) >= 25:
		sfx_warning.show()
		sfx_warning.text = "Why are you like this? :("
	

func _on_mute_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)
	AudioServer.set_bus_mute(1,toggled_on)
	

## Graphics Settings

func _on_resolution_button_item_selected(index: int) -> void:
	match index :
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		3:
			DisplayServer.window_set_size(Vector2i(1152, 648))
		4:
			DisplayServer.window_set_size(Vector2i(800, 600))
	

func _on_window_type_toggled(toggled_on: bool) -> void:
	if toggled_on:
		window_type.text = "Fullscreen"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		window_type.text = "Windowed"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	

# Single Buttons

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_reset_pressed() -> void:
	_create_action_list()
	
