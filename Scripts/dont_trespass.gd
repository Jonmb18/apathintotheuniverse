extends Area2D

@onready var interact_label: Label = $InteractLabel
var interact: bool = false

func _ready() -> void:
	interact_label.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact = true
		interact_label.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact = false
		interact_label.hide()
