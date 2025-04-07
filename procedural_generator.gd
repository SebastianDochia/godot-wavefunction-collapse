extends Node2D

const DIRECTIONS := [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0,1)]
const MAP_SIZE_X := 5
const MAP_SIZE_Y := 20
@onready var START_TILE: Tile = Tile.create(1, [2], 0.2, false)
@onready var tile_options = create_tiles()
var map: Array[Array] = []
var entropy_map: Array[Array] = []

class Tile: 
	var identifier: int
	var allowed_neighbours: Array[int]
	var weight: float
	var is_placeholder: bool
	
	static func create(_id: int, _allowed_n: Array[int], _weight: float, _is_placeholder := false) -> Tile:
		var instance = Tile.new()
		instance.identifier = _id
		instance.allowed_neighbours = _allowed_n
		instance.weight = _weight
		instance.is_placeholder = _is_placeholder
		return instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_setup()
	smart_print_map()
	
	colapse_wave_function()

func initial_setup():
	make_initial_array(MAP_SIZE_X, MAP_SIZE_Y)
	set_start_at_coords(2, 0)
	compute_shannon_entropy_map()

func create_tiles() -> Array[Tile]:
	return [Tile.create(1, [1, 2], 0.2), Tile.create(2, [1, 2, 3], 0.3), Tile.create(3, [2, 3], 0.5)]

func make_initial_array(x: int, y: int):
	var empty_tile = Tile.create(0, [1, 2, 3], true)
	
	for x_coord in x:
		var new_array: Array[Tile] = []
		var new_entropy_array: Array[float] = []
		map.append(new_array)
		entropy_map.append(new_entropy_array)
		for y_coord in y:
			map[x_coord].append(empty_tile)
			entropy_map[x_coord].append(0)

func set_start_at_coords(x: int, y: int):
	map[x][y] = START_TILE

func smart_print_map():
	print("MAP ++++++++ MAP")
	for x in map:
		var array_to_print: Array[int] = []
		
		for y in x.size():
			array_to_print.append(x[y].identifier)
		
		print(array_to_print)
	
	print("ENTROPY ++++++++ ENTROPY")
	for x in entropy_map:
		print(x)

func compute_shannon_entropy_map():
	for x in MAP_SIZE_X:
		for y in MAP_SIZE_Y:
			entropy_map[x][y] = compute_shannon_entropy_for_tile(Vector2(x, y))

func compute_shannon_entropy_for_tile(position_to_compute: Vector2) -> float:
	if (!map[position_to_compute.x][position_to_compute.y].identifier == 0):
		return 100
	
	var tile_options_for_position: Array[Tile] = get_tile_options(position_to_compute)

	var sum_weight = tile_options_for_position.reduce(func(accum: float, tile): return accum + tile.weight, 0)
	
	var shannon_entropy = 0.0
	for tile in tile_options_for_position:
		var probability = tile.weight / sum_weight
		shannon_entropy -= probability * log(probability)
	
	return round_place(shannon_entropy, 4)

func get_tile_options(for_position: Vector2) -> Array[Tile]:
	var possible_tiles: Array[Tile] = []
	var neighbours: Array[Tile] = get_neighbours(for_position)
	
	if neighbours.is_empty():
		return tile_options.duplicate()
	
	for tile in tile_options:
		var is_valid = true
		
		for neighbour in neighbours:
			
			if neighbour.identifier == 0:
				continue
			
			if !neighbour.allowed_neighbours.has(tile.identifier):
				is_valid = false
				break
		
		if is_valid:
			possible_tiles.append(tile)
	
	return possible_tiles

func get_neighbours(for_position: Vector2) -> Array[Tile]:
	var neighbours: Array[Tile] = []
	
	for direction in DIRECTIONS:
		var place_to_check: Vector2 = for_position + direction
		
		if ((0 <= place_to_check.x && place_to_check.x < MAP_SIZE_X) && (0 <= place_to_check.y && place_to_check.y < MAP_SIZE_Y)):
			neighbours.append(map[int(place_to_check.x)][int(place_to_check.y)])
	
	return neighbours

func round_place(num: float, places: int) -> float:
	return (round(num*pow(10,places))/pow(10,places))

func colapse_wave_function():
	var min_entropy_position: Vector2 = get_min_entropy_position()
	
	if (is_negative_one_vector(min_entropy_position)):
		print("DONE DONE DONE DONE DONE DONE DONE DONE DONE")
		smart_print_map()
		return
	
	collapse_position(min_entropy_position)
	compute_shannon_entropy_map()
	#smart_print_map()
	colapse_wave_function()

func get_min_entropy_position() -> Vector2:
	var min_value = INF
	var min_position = Vector2(-1, -1)
	
	for x in MAP_SIZE_X:
		for y in MAP_SIZE_Y:
			var value = entropy_map[x][y]
			
			if (value == 100.0):
				continue
			
			if (value < min_value):
				min_value = value
				min_position = Vector2(x, y)
	
	return min_position

func collapse_position(position_to_collapse: Vector2):
	var options = get_tile_options(position_to_collapse)

	if (options.is_empty()):
		print("Contradiction Reached")
		initial_setup()
	
	map[position_to_collapse.x][position_to_collapse.y] = get_random_tile(options)

func get_random_tile(options: Array[Tile]) -> Tile:
	var total_weight := 0.0
	
	for option in options:
		total_weight += option.weight
	
	var random_value = randf() * total_weight
	
	var current_weight := 0.0
	for option in options:
		current_weight += option.weight
		if random_value <= current_weight:
			return option
	
	return options[options.size() - 1]

func is_negative_one_vector(vec: Vector2) -> bool:
	return vec.x == -1 and vec.y == -1
