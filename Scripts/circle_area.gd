extends Sprite2D

@onready var Planet = $"../.."

func _process(delta):
	global_rotation += (delta / 2)

func _on_area_2d_body_entered(body):
	if body is Player:
		Planet.collectedOres += body.inventory_ores
		Planet.extendTime(body.inventory_plants)
		body.inventory_ores = 0
		body.inventory_plants = 0
		
		
