extends Resource
class_name PlanetDetails


@export_group("Main Settings")
@export var planetName: String

@export_group("Map Settings")
@export var mapSeed: int = 0
@export var setSeed: bool = false
@export var mapSize: Vector2i
@export var caveSmoothing: int = 3
@export_range(0.0, 1.0) var caveGenerationValue: float = 0.5

@export_subgroup("Resource Generation")
@export var resourceGeneration: float = 0.5
@export_range(0.0, 1.0) var plantsGeneration: float = 0.5
@export_range(0.0, 1.0) var oresGeneration: float = 0.5

@export_group("TileMap Settings")
@export var tilesetAmount: int = 1
@export var WallsTileSetID: Array[int]
@export var WallsSideTileSetID: Array[int]
@export var GroundTileSetID: Array[int]
@export var PlantTile: Array[Vector2i]
@export var ResourceTile: Array[Vector2i]
@export var DamageRequiredToMine: int = 1

@export_group("Gameplay Settings")
@export var playerSpeedMultiplier: float = 1.0
@export var useCustomEffect: bool
@export var customEffectColor: Color = Color(1, 1, 1, 1)
