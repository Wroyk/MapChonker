tool
extends Spatial

export var x_tiles:int = 10
export var y_tiles:int = 10

var chunk_positon:Vector2 = Vector2(0,0)
var height
var simplexnoise

func gen_heightmap(offset:Vector2):
	var pos = chunk_positon * 10 + offset
	return height * simplexnoise.get_noise_2dv(pos)


func init_mash():
	var vertices:PoolVector3Array = PoolVector3Array()
	var normals:PoolVector3Array = PoolVector3Array()
	var indixe:PoolIntArray = PoolIntArray()

	#var current_index = 0
	for x in range(x_tiles):
		for y in range(y_tiles):
			var v_00 = Vector3(x,gen_heightmap(Vector2(x,y)),y)
			var v_01 = Vector3(x,gen_heightmap(Vector2(x,y+1)),y+1)
			var v_10 = Vector3(x+1,gen_heightmap(Vector2(x+1,y)),y)
			var v_11 = Vector3(x+1,gen_heightmap(Vector2(x+1,y+1)),y+1)

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
	#arrays[ArrayMesh.ARRAY_INDEX] = indixe
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	$MeshInstance.mesh = arr_mesh

func _ready():
	init_mash()
