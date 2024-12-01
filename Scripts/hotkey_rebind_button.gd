class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Action as Label
@onready var button = $HBoxContainer/ActionKey as Button

@export var action_name : String = "player_1_left"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()

func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"player_1_up":
			label.text = "Move Up"
		"player_1_left":
			label.text = "Move Left"
		"player_1_down":
			label.text = "Move Down"
		"player_1_right":
			label.text = "Move Right"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	if action_events.size() > 0:
		var action_event = action_events[0]
		var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
		button.text = "%s" % action_keycode
	else:
		button.text = "No key assigned"

func _on_action_key_toggled(toggled_on):
	if toggled_on:
		button.text = "Press any key..."
		set_process_unhandled_key_input(true)
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
				
		set_text_for_key()

func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		rebind_action_key(event)
		button.set_pressed_no_signal(false)  # Use this method to set the button state without emitting the signal
	
func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
	reset_buttons()

func reset_buttons():
	for i in get_tree().get_nodes_in_group("hotkey_button"):
		i.button.toggle_mode = true
		i.set_process_unhandled_key_input(false)
