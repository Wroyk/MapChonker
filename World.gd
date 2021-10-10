extends Spatial

var chunk_scene = preload("res://Chonk.tscn")

export(NodePath) var center
export(int) var radius = 13
export(float) var chunk_size = 10
export(float) var height = 20
export var simplexnoise: OpenSimplexNoise

onready var center_node = get_node(center)

var active_chunks = {}

func _ready():
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	unload_unneded_chunks()
	update_lod()
	load_chunks_around_center()

func unload_unneded_chunks():
	var center_chunk = get_center_coords()

	for coord in active_chunks.keys():
		if abs(coord.x - center_chunk.x) > radius or abs(coord.y - center_chunk.y) > radius:
			unload_chunk(coord)

func get_center_coords() -> Vector2:
	var center_position = center_node.translation
	return Vector2(int(center_position.x / chunk_size), int(center_position.z / chunk_size))


func load_chunks_around_center():
	var center_chunk = get_center_coords()
	for x in range(center_chunk.x - radius, center_chunk.x + radius + 1):
		for y in range(center_chunk.y - radius, center_chunk.y + radius + 1):
			var coord = Vector2(x, y)
			if not active_chunks.has(coord):
				load_chunk(coord)

func load_chunk(coord: Vector2):
	var new_chunk = chunk_scene.instance()
	new_chunk.chunk_positon = coord
	new_chunk.simplexnoise = simplexnoise
	new_chunk.height = height
	new_chunk.translate(Vector3(coord.x * chunk_size, 0, coord.y * chunk_size))
	update_chunk_lod(new_chunk)
	add_child(new_chunk)
	active_chunks[coord] = new_chunk

func unload_chunk(coord: Vector2):
	remove_child(active_chunks[coord])
	active_chunks.erase(coord)

func update_lod():
	
	for chunk in active_chunks.values():
		update_chunk_lod(chunk)
		

func get_lod_tiles(offset:Vector2):
	var lenge = clamp(10 - offset.length()/20, 1, 10)
	return Vector2(lenge,lenge)

func update_chunk_lod(chunk):
	var center_position = center_node.translation
	var center_world:Vector2 = Vector2(center_position.x , center_position.z)
	var chunk_center = Vector2(chunk.translation.x, chunk.translation.z) + chunk.size/2
	var offset:Vector2 = center_world-chunk_center
	var tilelings = get_lod_tiles(offset)

	if (chunk.x_tiles != int(tilelings.x) or chunk.y_tiles != int(tilelings.y)):
		chunk.x_tiles = int(tilelings.x)
		chunk.y_tiles = int(tilelings.y)
		chunk.create_mash()
