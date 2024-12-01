extends Node2D

@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.stop()
	player.point_light_2d.hide()
	player.pointingArrow.hide()
	player.canvas_layer.hide()
	player.canvas_layer2.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
