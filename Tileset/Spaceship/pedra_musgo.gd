extends Area2D

@onready var panel: Panel = $Panel
@onready var interact_label: Label = $InteractLabel

var interact: bool = false

func _ready() -> void:
	panel.hide()
	interact_label.hide()
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact = true
		interact_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact = false
		panel.hide()
		interact_label.hide()

func _input(_event: InputEvent) -> void:
	if (interact == true) and Input.is_action_just_pressed("interact"):
		interact_label.hide()
		panel.show()
