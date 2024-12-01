extends Node2D
class_name Planet_Cave

#@onready var player = $"../Player"
@onready var player = $Player

@onready var WallTiles = $Walls
@onready var WallSideTiles = $Walls_Sub
@onready var ResourcesTiles = $Resources
@onready var FloorTiles = $Floor
@onready var Spaceship = $Spaceship
@onready var circle = $CircleArea
@onready var BreakingTiles = $Breaking

var mapSeed: int = 0
var setSeed: bool = false

var mapSize: Vector2i
var caveSmoothing: int = 3
var caveGenerationValue: float = 0.5

var plantsGeneration: float = 0.5
var oresGeneration: float = 0.5

var resourceGenerationExtra: float = 3.5

var caveArray: Array[Array]
var damageArray: Array[Array]

var caveTiles := {
	208: Vector2i(0, 0), 214: Vector2i(1, 0), 22: Vector2i(2, 0), 16: Vector2i(3, 0), 80: Vector2i(4, 0),
	86: Vector2i(5, 0), 210: Vector2i(6, 0), 18: Vector2i(7, 0), 82: Vector2i(8, 0), 219: Vector2i(9, 0),
	248: Vector2i(0, 1), 255: Vector2i(1, 1), 31: Vector2i(2, 1), 24: Vector2i(3, 1), 120: Vector2i(4, 1),
	127: Vector2i(5, 1), 251: Vector2i(6, 1), 27: Vector2i(7, 1), 123: Vector2i(8, 1), 126: Vector2i(9, 1),
	104: Vector2i(0, 2), 107: Vector2i(1, 2), 11: Vector2i(2, 2), 8: Vector2i(3, 2), 216: Vector2i(4, 2),
	223: Vector2i(5, 2), 254: Vector2i(6, 2), 30: Vector2i(7, 2), 222: Vector2i(8, 2), 218: Vector2i(9, 2),
	94: Vector2i(10, 2), 64: Vector2i(0, 3), 66: Vector2i(1, 3), 2: Vector2i(2, 3), 0: Vector2i(3, 3),
	72: Vector2i(4, 3), 75: Vector2i(5, 3), 106: Vector2i(6, 3), 10: Vector2i(7, 3), 74: Vector2i(8, 3),
	122: Vector2i(9, 3), 91: Vector2i(10, 3), 88: Vector2i(4, 4), 95: Vector2i(5, 4), 250: Vector2i(6, 4),
	26: Vector2i(7, 4), 90: Vector2i(8, 4),
}


var spaceShipPos: Vector2i

var noise := FastNoiseLite.new() 
var playable: bool = false

var tilesetAmount: int = 1
var WallsTileSetID: Array[int]
var WallsSideTileSetID: Array[int]
var GroundTileSetID: Array[int]
var PlantTile: Array[Vector2i]
var ResourceTile: Array[Vector2i]

var playerSpeed: float = 1.0
var useEffect: bool

var requiredDamage: int = 5

func _preload(details: PlanetDetails):
	mapSeed = details.mapSeed
	setSeed = details.setSeed
	mapSize = details.mapSize
	
	caveSmoothing = details.caveSmoothing
	caveGenerationValue = details.caveGenerationValue
	
	plantsGeneration = details.plantsGeneration
	oresGeneration = details.oresGeneration
	resourceGenerationExtra = details.resourceGeneration
	
	tilesetAmount = details.tilesetAmount
	WallsTileSetID = details.WallsTileSetID
	WallsSideTileSetID = details.WallsSideTileSetID
	GroundTileSetID = details.GroundTileSetID
	PlantTile = details.PlantTile
	ResourceTile = details.ResourceTile
	
	playerSpeed = details.playerSpeedMultiplier
	
	useEffect = details.useCustomEffect
	
	$"../CanvasModulate".visible = useEffect
	if useEffect:
		print($"../CanvasModulate".color)
		$"../CanvasModulate".set_color(details.customEffectColor)
		print(details.customEffectColor)
	
	requiredDamage = details.DamageRequiredToMine
	
	start()

func start():
	mapSeed = mapSeed if setSeed else abs(randi())
	
	generateNoise(0)
	generateCave()
	
	generateNoise(-1)
	updateCells(Vector2i(0, 0), mapSize)
	#generateCells()
	
	generateResources()
	
	var availablePosition = Vector2i(-1, -1)
	nextCheck.append(Vector2i(mapSize.x / 2, mapSize.y / 2))
	while (availablePosition == Vector2i(-1, -1)):
		availablePosition = findNearestCaveAvailable(nextCheck[checkIterator])
	WallTiles.z_index = player.z_index + 2
	WallSideTiles.z_index = player.z_index - 2
	FloorTiles.z_index = player.z_index - 4
	BreakingTiles.z_index = player.z_index + 2
	generateNoise(-1)
	spawnSpaceship(availablePosition)
	
	print("loaded!")
	playable = true

func _process(_delta):
	if playable:
		player.arrowPoint(spaceShipPos)
		
		

func spawnSpaceship(position: Vector2i):
	spaceShipPos = position - Vector2i(0, 3)
	Spaceship.set_cell(spaceShipPos, 6, Vector2i(0, 0))
	
	var posToVerify: Vector2i
	for xi in range(7):
		xi -= 3
		for yi in range(7):
			yi -= 3
			posToVerify = spaceShipPos + Vector2i(xi, yi)
			
			if isValidCoordinate(posToVerify):
				caveArray[posToVerify.x][posToVerify.y] = 0
				if caveArray[posToVerify.x][posToVerify.y + 1] == 2:
					caveArray[posToVerify.x][posToVerify.y + 1] = 0
					WallSideTiles.erase_cell(posToVerify + Vector2i(0, 1))
				WallTiles.erase_cell(posToVerify)
				WallSideTiles.erase_cell(posToVerify)
				ResourcesTiles.erase_cell(posToVerify)
	
	Spaceship.z_index = player.z_index + 3
	
	player.global_position = position * 16 + Vector2i(8, 8)
	player.setPlanetSpeed(playerSpeed)
	player.activateEffect(useEffect)
	
	circle.global_position = spaceShipPos * 16 + Vector2i(8, 8)
	circle.z_index = player.z_index - 3
	
	updateCells(spaceShipPos - Vector2i(4, 4), spaceShipPos + Vector2i(7, 7))
	

func updateCells(from: Vector2i, to: Vector2i):
	var cellDividingAmount = 100.0 / tilesetAmount
	
	for xii in range(to.x - from.x):
		var xi = from.x + xii
		for yii in range(to.y - from.y):
			var yi = from.y + yii
			
			var cellTileType = int(((noise.get_noise_2d(xi * 2, yi * 2) + 1.0) / 2.0) * 100 / cellDividingAmount)
			
			if caveArray[xi][yi] == 1:
				var cellID = getCellType(Vector2i(xi, yi), false)
				if caveTiles.has(cellID):
					WallTiles.set_cell(Vector2i(xi, yi), WallsTileSetID[cellTileType], caveTiles[cellID])
			else:
				if isValidCoordinate(Vector2i(xi, yi - 1)) && caveArray[xi][yi - 1] == 1:
					WallSideTiles.set_cell(Vector2i(xi, yi), WallsSideTileSetID[int(((noise.get_noise_2d(xi * 2, (yi - 1) * 2) + 1.0) / 2.0) * 100 / cellDividingAmount)], Vector2i(1, 3))
					caveArray[xi][yi] = 2
				else:
					FloorTiles.set_cell(Vector2i(xi, yi), GroundTileSetID[cellTileType], Vector2i(1, 1))
		
		var cellTileType = int(((noise.get_noise_2d(xi, to.y) + 1.0) / 2.0) / cellDividingAmount)
		if isValidCoordinate(Vector2i(xi, to.y + 1)) && caveArray[xi][to.y] != 1:
			WallSideTiles.erase_cell(Vector2i(xi, to.y + 1))
			FloorTiles.set_cell(Vector2i(xi, to.y + 1), GroundTileSetID[cellTileType], Vector2i(1, 1))
			
			


func generateNoise(generationStatus: int):
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = mapSeed + generationStatus if setSeed else abs(randi())
	setSeed = true

func generateCave():
	for x in mapSize.x:
		caveArray.append([])
		damageArray.append([])
		for y in mapSize.y:
			caveArray[x].append([])
			damageArray[x].append([])
			caveArray[x][y] = 1 if ((noise.get_noise_2d(x, y) + 1.0) / 2.0) >= caveGenerationValue else 0
			damageArray[x][y] = 0
	
	smoothenCave(caveSmoothing)
			
func smoothenCave(generations: int):
	for it in range(generations):
		var newCave: Array[Array]
		for x in mapSize.x:
			newCave.append([])
			for y in mapSize.y:
				newCave[x].append([])
				var neighbors = verifyNeighbors(Vector2i(x, y))
				newCave[x][y] = 1 if neighbors >= 3 else caveArray[x][y]
		caveArray = newCave

func verifyNeighbors(coordinate: Vector2i) -> int:
	var neighbors := 0
	for xi in range(3):
		xi -= 1
		for yi in range(3):
			yi -= 1
			if isValidCoordinate(Vector2i(coordinate.x + xi, coordinate.y + yi)) && Vector2i(coordinate.x + xi, coordinate.y + yi) != coordinate:
				neighbors += 1 if caveArray[coordinate.x + xi][coordinate.y + yi] else 0
	return neighbors
	
func isValidCoordinate(target: Vector2i) -> bool:
	return target.x > 0 && target.x < mapSize.x - 1 && target.y > 0 && target.y < mapSize.y - 1

func getCellType(coordinate: Vector2i, _freeTiles: bool) -> int:
	var connections: Array[int]
	for xi in range(3):
		xi -= 1
		for yi in range(3):
			yi -= 1
			if isValidCoordinate(Vector2i(coordinate.x + xi, coordinate.y + yi)):
				if Vector2i(coordinate.x + xi, coordinate.y + yi) != coordinate:
					connections.push_front(1 if (caveArray[coordinate.x + xi][coordinate.y + yi] == 1) else 0)
			else:
				connections.push_front(0)
	return binArrayToInt(connections)

func binArrayToInt(source: Array[int]) -> int: #not actually a int to bin conversion, it just helps to remake the autotile algorithm
	var out := 0
	var corners = [0, 2, 5, 7]
	var sides = {
		0: [1, 3],
		2: [1, 4],
		5: [3, 6],
		7: [4, 6]
	}
	for i in range(source.size()):
		if i in corners:
			if source[sides[i][0]] && source[sides[i][1]]:
				out = out << 1
				out = out + source[i]
			else:
				out = out << 1
		else:
			out = out << 1
			out = out + source[i]
	return out

func generateCells():
	for x in mapSize.x:
		for y in mapSize.y:
			if caveArray[x][y] == 1:
				#WallTiles.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))
				#WallTiles.set_cells_terrain_connect([Vector2i(x, y)], 0, 0, true)
				var cellID = getCellType(Vector2i(x, y), false)
				if caveTiles.has(cellID):
					WallTiles.set_cell(Vector2i(x, y), 8, caveTiles[cellID])
				#else:
				#	WallTiles.set_cell(Vector2i(x, y), 8, caveTiles[0])
			else:
				if isValidCoordinate(Vector2i(x, y - 1)) && caveArray[x][y - 1] == 1:
					WallSideTiles.set_cell(Vector2i(x, y), 0, Vector2i(1, 3))
					caveArray[x][y] = 2
	for x in mapSize.x:
		for y in mapSize.y:
			if caveArray[x][y] == 0:
				#var cellID = getCellType(Vector2i(x, y), false)
				#FloorTiles.set_cell(Vector2i(x, y), 3, Vector2i(cellID % 8, cellID / 8))
				FloorTiles.set_cell(Vector2i(x, y), 1, Vector2i(1, 1))


var nextCheck: Array[Vector2i]
var checkIterator: int = 0
#@export var minCaveSizeSpawn: int = 25

func findNearestCaveAvailable(curCoordinate: Vector2i) -> Vector2i:
	var bottomTile = Vector2i(curCoordinate.x, curCoordinate.y + 1)
	var rightTile = Vector2i(curCoordinate.x + 1, curCoordinate.y)
	var leftTile = Vector2i(curCoordinate.x - 1, curCoordinate.y)
	var upTile = Vector2i(curCoordinate.x, curCoordinate.y - 1)
	
	if FloorTiles.get_cell_atlas_coords(curCoordinate) != Vector2i(-1, -1): # Verify if is a floor tile
		return curCoordinate
	else:
		if !nextCheck.has(bottomTile):
			nextCheck.append(bottomTile)
		if !nextCheck.has(rightTile):
			nextCheck.append(rightTile)
		if !nextCheck.has(leftTile):
			nextCheck.append(leftTile)
		if !nextCheck.has(upTile):
			nextCheck.append(upTile)
		checkIterator += 1
		
		return Vector2i(-1, -1)

var plantsArray: Array[Array]
var oresArray: Array[Array]

func generateResources():
	generateNoise(1)
	generatePlants()
	spawnPlants()
	
	generateNoise(2)
	generateOres()
	spawnOres()

func generatePlants():
	for x in mapSize.x:
		plantsArray.append([])
		for y in mapSize.y:
			plantsArray[x].append([])
			plantsArray[x][y] = 1 if ((noise.get_noise_2d(x * resourceGenerationExtra, y * resourceGenerationExtra) + 1.0) / 2.0) <= plantsGeneration else 0

func spawnPlants():
	for x in mapSize.x:
		for y in mapSize.y:
			if plantsArray[x][y] && !caveArray[x][y]:
				ResourcesTiles.set_cell(Vector2i(x, y), 4, PlantTile[0])

	
func generateOres():
	for x in mapSize.x:
		oresArray.append([])
		for y in mapSize.y:
			oresArray[x].append([])
			oresArray[x][y] = 1 if ((noise.get_noise_2d(x * resourceGenerationExtra, y * resourceGenerationExtra) + 1.0) / 2.0) <= oresGeneration else 0
			
func spawnOres():
	for x in mapSize.x:
		for y in mapSize.y:
			if oresArray[x][y] && !caveArray[x][y] && !plantsArray[x][y]:
				ResourcesTiles.set_cell(Vector2i(x, y), 14, ResourceTile[0])



func _MineOre(_collider, col_pos):
	var tile_pos = Vector2i(col_pos / 16.0)
	tile_pos = tile_pos if caveArray[tile_pos.x][tile_pos.y] == 1 else (tile_pos - Vector2i(0, 1))
	
	
	
	damageArray[tile_pos.x][tile_pos.y] += 1
	var breakTile = round((damageArray[tile_pos.x][tile_pos.y] * (1.0 / (requiredDamage))) * 4)
	BreakingTiles.set_cell(tile_pos, 17, Vector2i(breakTile, 0))
	
	var isBottom: bool = caveArray[tile_pos.x][tile_pos.y + 1] == 2
	if isBottom:
		damageArray[tile_pos.x][tile_pos.y + 1] += 1
	
	if damageArray[tile_pos.x][tile_pos.y] == requiredDamage:
		caveArray[tile_pos.x][tile_pos.y] = 0
		WallTiles.erase_cell(tile_pos)
		BreakingTiles.erase_cell(tile_pos)
		if isBottom:
			WallSideTiles.erase_cell(tile_pos + Vector2i(0, 1))
			caveArray[tile_pos.x][tile_pos.y + 1] = 0
		
		generateNoise(-1)
		updateCells(tile_pos - Vector2i(2, 2), tile_pos + Vector2i(2, 3))
		


func _CollectResource(_collider, col_pos):
	var tile_pos = Vector2i(col_pos / 16.0)
	
	if plantsArray[tile_pos.x][tile_pos.y]:
		player.collect("Plant")
		plantsArray[tile_pos.x][tile_pos.y] = 0
	elif oresArray[tile_pos.x][tile_pos.y]:
		player.collect("Ore")
		oresArray[tile_pos.x][tile_pos.y] = 0
	
	ResourcesTiles.erase_cell(tile_pos)
