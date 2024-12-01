extends Node

@onready var arkana: PlanetDetails = preload("res://resources/planets/planet_arkana.tres")
@onready var casley: PlanetDetails = preload("res://resources/planets/planet_casley.tres")
@onready var lungyos: PlanetDetails = preload("res://resources/planets/planet_lungyos.tres")

var current_planet: int

var array_planetas: Array[PlanetDetails]
func _ready():
	array_planetas.append(arkana)
	array_planetas.append(casley)
	array_planetas.append(lungyos)

func get_planet():
	return array_planetas[current_planet]
