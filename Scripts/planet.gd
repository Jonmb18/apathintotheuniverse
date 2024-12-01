extends Node2D
class_name Planet

@onready var tileMapLayer = $TileMapLayer
@onready var player = $TileMapLayer/Player

@export var planetResource: PlanetDetails

var collectedOres: int = 0
var collectedPlants: int = 0

var totalTime: float = 120.0
var spentTime: float = 0.0

func _ready():
	planetResource = PlanetLoad.get_planet()
	tileMapLayer._preload(planetResource)

func extendTime(qtd: int):
	collectedPlants += qtd
	totalTime += (qtd * 0.3)

func _process(delta):
	spentTime += delta
	player.setTime(spentTime, totalTime)
	
	if spentTime >= totalTime:
		print("Time's over!")
		print(collectedOres)
		print(collectedPlants)
		var totalOresCollected: int = Ores.ore_quantity + collectedOres
		Ores.ore_quantity += collectedOres
		print(totalOresCollected)
		get_tree().change_scene_to_file("res://Scenes/Mothership.tscn")
