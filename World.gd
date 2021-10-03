extends Spatial

var chunk_scene = preload("res://Chonk.tscn")

export(NodePath) var center
export(int) var world_seed = 0

onready var center_node = get_node(center)

var active_chunks = {}

func _ready():
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var center_position = center_node.translation
	var center_chunk = Vector2(int(center_position.x / 10), int(center_position.z / 10))

	for coord in active_chunks.keys():
		if abs(coord.x - center_chunk.x) > 5 or abs(coord.y - center_chunk.y) > 5:
			remove_child(active_chunks[coord])
			active_chunks.erase(coord)

	for x in range(center_chunk.x - 5, center_chunk.x + 5 + 1):
		for y in range(center_chunk.y - 5, center_chunk.y + 5 + 1):
			var coord = Vector2(x, y)
			if not active_chunks.has(coord):
				var new_chunk = chunk_scene.instance()
				new_chunk.chunk_seed = world_seed ^ ((x << 16) | y)
				new_chunk.chunk_positon = coord
				new_chunk.translate(Vector3(coord.x * 10, 0, coord.y * 10))
				add_child(new_chunk)
				active_chunks[coord] = new_chunk

