class_name ProceduralMesh
	
func addMeshTo(
	node: MeshInstance3D, 
	vertices: PackedVector3Array,
	widthSegments: int,
	lengthSegments: int,
	lengthMultiplier: float = 1,
	clockwise: bool = true,
	clear: bool = true
) -> void:
	var meshData = []
	meshData.resize(ArrayMesh.ARRAY_MAX)
	meshData[ArrayMesh.ARRAY_VERTEX] = vertices
	var indices := getVertexIndexArray(
		widthSegments,
		lengthSegments,
		lengthMultiplier,
		clockwise
	)
	meshData[ArrayMesh.ARRAY_INDEX] = indices
	meshData[ArrayMesh.ARRAY_TEX_UV] = getUVArray(
		widthSegments,
		lengthSegments,
		lengthMultiplier
	)
	meshData[ArrayMesh.ARRAY_NORMAL] = getNormalArray(indices, vertices)

	if clear:
		node.mesh = ArrayMesh.new()
	node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)


func getVertexIndexArray(
	widthSegments: int,
	lengthSegments: int,
	lengthMultiplier: float = 1,
	clockwise: bool = true
) -> PackedInt32Array:
	var indexList: PackedInt32Array = []
	if clockwise:
		for i in (lengthSegments * lengthMultiplier) - 1:
			for j in widthSegments - 1:
				var index = i * widthSegments + j
				indexList.push_back(index)
				indexList.push_back(index + (widthSegments))
				indexList.push_back(index + 1)

				indexList.push_back(index + 1)
				indexList.push_back(index + (widthSegments)) 
				indexList.push_back(index + (widthSegments) + 1)
	else:
		for i in (lengthSegments * lengthMultiplier) - 1:
			for j in widthSegments - 1:
				var index = i * widthSegments + j
				indexList.push_back(index)
				indexList.push_back(index + 1)
				indexList.push_back(index + (widthSegments))

				indexList.push_back(index + 1)
				indexList.push_back(index + (widthSegments) + 1)
				indexList.push_back(index + (widthSegments)) 
	
	return indexList

func getUVArray(
	widthSegments: int,
	lengthSegments: int,
	lengthMultiplier: float = 1
) -> PackedVector2Array:
	var uvList: PackedVector2Array = []
	for j in lengthSegments * lengthMultiplier:
		for i in widthSegments:
			var v = float(i) / (widthSegments - 1)
			var u = float(j) / ((lengthSegments * lengthMultiplier) - 1) * lengthMultiplier

			uvList.push_back(Vector2(v, u))

	return uvList

func getNormalArray(indices: PackedInt32Array, vertices: PackedVector3Array) -> PackedVector3Array:
	var normalArray: PackedVector3Array = []
	normalArray.resize(vertices.size())

	for index in range(0, indices.size(), 3):
		var a: Vector3 = vertices[indices[index]]
		var b: Vector3 = vertices[indices[index + 2]]
		var c: Vector3 = vertices[indices[index + 1]]
		
		var normal = ((b - a).cross(c - a)).normalized()
		normalArray[indices[index]] = normal
		normalArray[indices[index + 1]] = normal
		normalArray[indices[index + 2]] = normal

	return normalArray