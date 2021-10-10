extends Spatial

export var x_tiles:int = 10
export var y_tiles:int = 10
export var size:Vector2 = Vector2(10,10)

var chunk_positon:Vector2 = Vector2(0,0)
var height
var simplexnoise

func gen_heightmap(offset:Vector2):
	var pos = chunk_positon * size + offset
	return height * simplexnoise.get_noise_2dv(pos)


func create_mash():
	var vertices:PoolVector3Array = PoolVector3Array()
	var normals:PoolVector3Array = PoolVector3Array()

	var steps:Vector2 = Vector2(size.x/x_tiles, size.y/y_tiles)

	for x in range(0, x_tiles):
		for y in range(0, y_tiles):
			#print("p_00")
			var p_00 = Vector2(x, y) * steps
			var p_01 = Vector2(x, y + 1) * steps
			var p_10 = Vector2(x + 1, y) * steps
			var p_11 = Vector2(x + 1, y + 1) * steps

			var v_00 = Vector3(p_00.x, gen_heightmap(p_00), p_00.y)
			var v_01 = Vector3(p_01.x, gen_heightmap(p_01), p_01.y)
			var v_10 = Vector3(p_10.x, gen_heightmap(p_10), p_10.y)
			var v_11 = Vector3(p_11.x, gen_heightmap(p_11), p_11.y)

			vertices.push_back(v_00)
			vertices.push_back(v_10)
			vertices.push_back(v_01)
			vertices.push_back(v_01)
			vertices.push_back(v_10)
			vertices.push_back(v_11)

			var n1 = (v_01-v_00).cross(v_10-v_00)
			var n2 = (v_11-v_01).cross(v_10-v_01)
			normals.push_back(n1)
			normals.push_back(n1)
			normals.push_back(n1)
			normals.push_back(n2)
			normals.push_back(n2)
			normals.push_back(n2)


	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	$MeshInstance.mesh = arr_mesh

func _ready():
	pass
