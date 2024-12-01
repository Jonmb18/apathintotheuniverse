extends CharacterBody2D
class_name Player

@export var playerTileSpeed: float = 2.5
@export var playerMaxSpeed: float = 100
@export var tileSize: int = 16

@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var pointingArrow = $PointingArrow
@onready var rayCast = $RayCast2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var canvas_layer: CanvasLayer = $Camera2D/CanvasLayer
@onready var canvas_layer2: CanvasLayer = $Camera2D/CanvasLayer2


var planetSpeed: float = 1.0
var facing: String

var canMine: bool = true
var mineCooldown: float = 1.0
var mineCooldownTimer: float = 1.0

var inventory_ores: int = 0
var inventory_plants: int = 0
@export var max_inventory_space: int = 10

signal toMine(collider, col_pos)
signal toCollect(collider, col_pos)

func _ready():
	$Camera2D/CanvasLayer2/VBoxContainer/Label2.text = "x" + str(inventory_plants) + " Plants"
	$Camera2D/CanvasLayer2/VBoxContainer/Label3.text = "x" + str(inventory_ores) + " Ores"

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * playerTileSpeed * tileSize * delta * playerMaxSpeed * planetSpeed
		velocity = clamp(velocity, Vector2(-playerMaxSpeed, -playerMaxSpeed), Vector2(playerMaxSpeed, playerMaxSpeed))
		if abs(velocity.y) > abs(velocity.x):
			if velocity.y > 0:
				animationPlayer.play("walk_down")
				changeDirection("down")
			else:
				animationPlayer.play("walk_up")
				changeDirection("up")
		elif abs(velocity.y) <= abs(velocity.x):
			if velocity.x != 0:
				sprite.flip_h = velocity.x < 0
				changeDirection("left" if sprite.flip_h else "right")
			animationPlayer.play("walk_side")
	else:
		velocity = Vector2.ZERO
		animationPlayer.pause()
	
	move_and_slide()
	mineCooldownTimer += delta
	mineCooldownTimer = clamp(mineCooldownTimer, 0, mineCooldown)
	
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		var col_point = rayCast.get_collision_point()
		if collider.is_in_group("Mineables"):
			
			if (mineCooldownTimer == mineCooldown):
				if facing == "left":
					col_point -= Vector2(16, 0)
				toMine.emit(collider, col_point)
				mineCooldownTimer = 0
				
	if Input.is_action_just_pressed("interact") && rayCast.is_colliding():
		var collider = rayCast.get_collider()
		var col_point = rayCast.get_collision_point()
		
		if collider.is_in_group("Resources"):
			if inventory_ores + inventory_plants < max_inventory_space:
				toCollect.emit(collider, col_point)
			else:
				print("Inventory full")

func setPlanetSpeed(speed: float):
	planetSpeed = speed

func changeDirection(dir: String):
	facing = dir
	if facing == "right" || facing == "left":
		#$RayCast2D.rotation = 0 if facing == "right" else PI
		$RayCast2D.set_target_position(Vector2i(8 if facing == "right" else -8, 0))
	else:
		#$RayCast2D.rotation = (PI/2) if facing == "down" else (2 * PI / 3)
		$RayCast2D.set_target_position(Vector2i(0, 8 if facing == "down" else -16))
		

func activateEffect(constraint: bool):
	$Camera2D/CanvasLayer.visible = constraint

func arrowPoint(target_pos: Vector2i):
	var target = target_pos * 16 + Vector2i(8, 8)
	
	pointingArrow.visible = target.distance_to(global_position) > 160
	pointingArrow.look_at(target)

func collect(type: String):
	if type == "Plant":
		inventory_plants += 1
		$Camera2D/CanvasLayer2/VBoxContainer/Label2.text = "x" + str(inventory_plants) + " Plants"
	elif type == "Ore":
		inventory_ores += 1
		$Camera2D/CanvasLayer2/VBoxContainer/Label3.text = "x" + str(inventory_ores) + " Ores"

func setTime(val: float, total: float):
	$Camera2D/CanvasLayer2/Label.text = str(round(total - val))
	$Camera2D/CanvasLayer2/VBoxContainer/Label2.text = "x" + str(inventory_plants) + " Plants"
	$Camera2D/CanvasLayer2/VBoxContainer/Label3.text = "x" + str(inventory_ores) + " Ores"
