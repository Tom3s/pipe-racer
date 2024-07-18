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
		vertices,
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

func addMeshCustom(
	node: MeshInstance3D, 
	vertices: PackedVector3Array,
	indices: PackedInt32Array,
	uv: PackedVector2Array,
	normal: PackedVector3Array,
	clear: bool = true
) -> void:
	var meshData = []
	meshData.resize(ArrayMesh.ARRAY_MAX)
	meshData[ArrayMesh.ARRAY_VERTEX] = vertices
	meshData[ArrayMesh.ARRAY_INDEX] = indices
	meshData[ArrayMesh.ARRAY_TEX_UV] = uv
	# meshData[ArrayMesh.ARRAY_NORMAL] = getNormalArray(indices, vertices)
	meshData[ArrayMesh.ARRAY_NORMAL] = normal

	if clear:
		node.mesh = ArrayMesh.new()
	node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)


func getVertexIndexArray(
	vertices: PackedVector3Array,
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

				var v1: Vector3 = vertices[index]
				var v2: Vector3 = vertices[index + 1]
				var v3: Vector3 = vertices[index + (widthSegments)]
				var v4: Vector3 = vertices[index + (widthSegments) + 1]

				if v1 == v2 or v1 == v3 or v2 == v3 or v2 == v4 or v3 == v4:
					continue

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

				var v1: Vector3 = vertices[index]
				var v2: Vector3 = vertices[index + 1]
				var v3: Vector3 = vertices[index + (widthSegments)]
				var v4: Vector3 = vertices[index + (widthSegments) + 1]

				if v1 == v2 or v1 == v3 or v2 == v3 or v2 == v4 or v3 == v4:
					continue

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

static func getPipeVertices(
	a: Vector3,
	b: Vector3,
	radius: float,
) -> PackedVector3Array:
	var segments: int = 8
	var vertices: PackedVector3Array = PackedVector3Array()

	var profile: PackedVector3Array = PackedVector3Array()

	for i in segments + 1:
		var angle: float = i * 2 * PI / segments
		profile.push_back(Vector3(cos(angle) * radius, sin(angle) * radius, 0))

	var forward: Vector3 = (b - a).normalized()
	var tangent: Vector3 = Vector3(-forward.z, 0, forward.x).normalized() 
	if tangent.length() == 0:
		tangent = Vector3(0, 0, 1)


	var rotationBasis: Basis = Basis(
		tangent,
		tangent.cross(forward),
		forward
	)

	for i in segments + 1:
		var vertex: Vector3 = profile[i]

		vertex = rotationBasis * vertex + a

		vertices.push_back(vertex)

	for i in segments + 1:
		var vertex: Vector3 = profile[i]

		vertex = rotationBasis * vertex + b

		vertices.push_back(vertex) 

	return vertices

static func getPipeCapVertices(
	pipeVertices: PackedVector3Array,
) -> PackedVector3Array:
	var capVertices: PackedVector3Array = pipeVertices.slice(0, pipeVertices.size() / 2)
	var extraVertices: PackedVector3Array = capVertices.slice(capVertices.size() / 2, capVertices.size() - 1)
	extraVertices.reverse()
	capVertices = capVertices.slice(0, capVertices.size() / 2)
	capVertices.append_array(extraVertices)

	return capVertices
