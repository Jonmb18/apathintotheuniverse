extends Control

@onready var card_info: Control = $"."
@onready var planet_name: Label = $PlanetName
@onready var planet_description: Label = $PlanetDescription
@onready var enter_planet: Button = $EnterPlanet



func _ready():
	card_info.hide()
	planet_name.text = ""
	planet_description.text = ""
	enter_planet.disabled = true
	enter_planet.text = "Start Game"

func _on_enter_planet_pressed() -> void:
	print("Game started")
	get_tree().change_scene_to_file("res://Scenes/loadingplanet.tscn")
	
	
	
