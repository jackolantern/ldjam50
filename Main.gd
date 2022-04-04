extends Node2D

enum Item {
	Empty,
	Mirror,
	Garlic,
	Coffin,
	Person1,
	Person2,
	Person3,
	VanHelsing
}

const CellSize = 32
const ViewWidth = 10
const ViewHeight = 5

const RightBit = 0
const LeftBit = (RightBit + 2) % 4 # == 2
const DownBit = 1
const UpBit = (DownBit + 2) % 4 # == 3

const RightMask = int(pow(2, RightBit))
const LeftMask = int(pow(2, LeftBit))
const DownMask = int(pow(2, DownBit))
const UpMask = int(pow(2, UpBit))

const UpVec = Vector2(0, -1)
const RightVec = Vector2(1, 0)
const DownVec = Vector2(0, 1)
const LeftVec = Vector2(-1, 0)

const directions = {
	UpBit: UpVec,
	DownBit: DownVec,
	LeftBit: LeftVec,
	RightBit: RightVec,
}

const CenterAT = Vector2(0, 0)
const UpAT = Vector2(0, 1)
const DownAT = Vector2(1, 0)
const RightAT = Vector2(2, 0)
const LeftAT = Vector2(0, 2)

const tileBitToAt = {
	UpBit: UpAT,
	DownBit: DownAT,
	LeftBit: LeftAT,
	RightBit: RightAT,
}

const tileBitMaskToIndex = {0: CenterAT}

class Tile:
	var item = false
	var openings = [false, false, false, false]

	func _to_string():
		return "Tile({item}, {openings})".format({"item": item, "openings": openings})

	func to_index(map):
		var index = 0
		for i in range(len(openings)):
			if openings[i]:
				index += int(pow(2, i))
		return map[index]

	static func make(tile_mask: int, item: int):
		var tile = Tile.new()
		for i in range(UpBit + 1):
			tile.openings[i] = (tile_mask & int(pow(2, i))) == int(pow(2, i))
		tile.item = item
		return tile

const tiles = {}
var rng = RandomNumberGenerator.new()
var highmark = 0
var highmarks = []
onready var player = $TileMap/Vampire

var score = 1 # Thanks for playing!
var mirrors = 0
var garlics = 0
var clothspins = 0
var hammers = 0
var moves = 0
var slow_down = 0

func sun_speed():
	return 1 + max(slow_down, 0) + int(log(1 + moves * slow_down))

func get_highmarks(map):
	var max_y = 0
	var found = []
	for tile in tiles:
		if tile.y < max_y and not map[tile].openings[UpBit]:
			max_y = tile.y
			found.resize(0)
			found.append(tile)
		if tile.y == max_y:
			found.append(tile)
	return found

func random_walk(length: int, pos: Vector2, low: int, map):
	var new = {}
	for _i in range(length):
		if not map.get(pos):
			map[pos] = Tile.new()
		new[pos] = map[pos]
		# We want Up to be more likely than the other directions.
		# Just increase the range to increase the probability.
		var dir = rng.randi_range(0, 5)
		while dir == DownBit and pos.y >= low:
			dir = rng.randi_range(0, 5)
		if dir <= UpBit:
			map[pos].openings[dir] = true
			pos += directions[dir]
			if not map.get(pos):
				map[pos] = Tile.new()
			new[pos] = map[pos]
			map[pos].openings[(dir + 2) % 4] = true
		else:
			map[pos].openings[UpBit] = true
			pos += directions[UpBit]
			if not map.get(pos):
				map[pos] = Tile.new()
			new[pos] = map[pos]
			map[pos].openings[DownBit] = true
	return new

func random_object(pos):
	var n = rng.randi_range(0, 100)
	if n <= 10:
		$TileMap.add_child(preload("res://Item.tscn").instance().initialize(pos, "Coin", "Coin"))
	elif n == 11:
		n = rng.randi_range(1, 3)
		$TileMap.add_child(preload("res://Item.tscn").instance().initialize(pos, "Person-%d" % n, "A Person Full of Delicious Blood"))
	#elif n == 2:
	#	$TileMap.add_child(preload("res://Item.tscn").instance().initialize(pos, "Hammer", "Hammer"))
	#elif n == 3:
	#	$TileMap.add_child(preload("res://Item.tscn").instance().initialize(pos, "Clothespin", "Clothespin"))
	elif n <= 30:
		$TileMap.add_child(preload("res://Item.tscn").instance().initialize(pos, "Mirror", "Mirror"))
	elif n <= 50:
		$TileMap.add_child(preload("res://Item.tscn").instance().initialize(pos, "Garlic", "Garlic"))


func extend_map(map):
	for mark in highmarks:
		for _i in range(4):
			for pos in random_walk(30, mark, mark.y, map):
				if not map[pos].item:
					map[pos].item = true
					random_object(pos)
				$TileMap.set_cell(pos[0], pos[1], 0, false, false, false, map[pos].to_index(tileBitMaskToIndex))
	highmarks = get_highmarks(map)
	highmark = highmarks[0].y

func update_gui():
	$GUI/CoinCount/Count.text = str(player.coins)
	$GUI/MoveCount/Count.text = str(moves)

func _ready():
	rng.randomize()
	for i in range(32):
		var at = CenterAT
		for j in range(UpBit + 1):
			var n = int(pow(2, j))
			if i & n == n:
				at += tileBitToAt[j]
		tileBitMaskToIndex[i] = at

	# TODO: too fiddly
	highmarks = [Vector2(4, 5)]
	extend_map(tiles)
	highmarks = [Vector2(4, 2)]
	extend_map(tiles)
	player.initialize(Vector2(4, 2))

func _physics_process(delta):
	if player.moving:
		return
	if Input.is_action_just_pressed("ui_left"):
		if tiles[player.map_position].openings[LeftBit]:
			player.move(LeftVec)
			$TileMap/Sun.global_position.x -= CellSize
		else:
			return
	elif Input.is_action_just_pressed("ui_right"):
		if tiles[player.map_position].openings[RightBit]:
			player.move(RightVec)
			$TileMap/Sun.global_position.x += CellSize
		else:
			return
	elif Input.is_action_just_pressed("ui_down"):
		if tiles[player.map_position].openings[DownBit]:
			player.move(DownVec)
		else:
			return
	elif Input.is_action_just_pressed("ui_up"):
		if tiles[player.map_position].openings[UpBit]:
			player.move(UpVec)
		else:
			return
	else:
		return
	$TileMap/Sun.global_position.y -= sun_speed()
	moves += 1
	update_gui()


func _process(delta):
	if highmark >= player.global_position.y - 2 * ViewHeight: 
		extend_map(tiles)


func _on_Vampire_inventory_update(item, count):
	update_gui()


func _on_Vampire_slow_down():
	slow_down += 1


func _on_Vampire_speed_up():
	slow_down -= 1


func _on_Vampire_dead():
	$Timer.start()


func _on_Timer_timeout():
	get_tree().change_scene("res://Start.tscn")
