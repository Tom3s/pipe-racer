@tool
extends Node3D

@onready var mesh: MeshInstance3D = %Mesh

var width: float = 1.0
var height: float = 1.0
var depth: float = 1.0

@export
var sides: int = 3:
	set(value):
		sides = value
		refreshMesh()

var pointy: bool = false

@export
var sharp: bool = true:
	set(value):
		sharp = value
		refreshMesh()

var repeatTop: int = 1
var repeatBottom: int = 1
var repeatSides: int = 1

var flipFaces: bool = false

var useOnlineTextures: bool = false

var proceduralMesh: ProceduralMesh = ProceduralMesh.new()

func refreshMesh():
	var topVertices: PackedVector3Array = []
	if pointy:
		topVertices = [Vector3(0, height, 0)]
	else:
		topVertices = getVertices(height)

		var indices: PackedInt32Array = []
		for i in range(1, sides - 1):
			indices.append(0)
			indices.append(i)
			indices.append(i + 1)
		
		var uv: PackedVector2Array = []
		for vertex in topVertices:
			var u: float = remap(vertex.x, -width / 2, width / 2, 0, 1)
			var v: float = remap(vertex.z, -depth / 2, depth / 2, 0, 1)
			uv.append(Vector2(u, v))
		

		var normal: PackedVector3Array = []
		for vertex in topVertices:
			normal.append(Vector3(0, 1, 0))

		proceduralMesh.addMeshCustom(
			mesh,
			topVertices,
			indices,
			uv,
			normal
		)


	var bottomVertices: PackedVector3Array = getVertices(0)

	bottomVertices = getVertices(0)

	var indices: PackedInt32Array = []
	for i in range(1, sides - 1):
		indices.append(0)
		indices.append(i + 1)
		indices.append(i)
	
	var uv: PackedVector2Array = []
	for vertex in bottomVertices:
		var u: float = remap(vertex.x, -width / 2, width / 2, 0, 1)
		var v: float = remap(vertex.z, -depth / 2, depth / 2, 0, 1)
		uv.append(Vector2(u, v))
	
	var normal: PackedVector3Array = []
	for vertex in bottomVertices:
		normal.append(Vector3(0, -1, 0))

	proceduralMesh.addMeshCustom(
		mesh,
		bottomVertices,
		indices,
		uv,
		normal,
		pointy
	)




	var sideVertices: PackedVector3Array = []
	sideVertices.append_array(topVertices)	
	if !sharp:
		sideVertices.append(topVertices[0])
	sideVertices.append_array(bottomVertices)
	if !sharp:
		sideVertices.append(bottomVertices[0])


	if sharp:
		var newVertices: PackedVector3Array = []
		for vertex in sideVertices:
			newVertices.append(vertex)
			newVertices.append(vertex)
		sideVertices = newVertices

	indices = []

	if !sharp:
		for i in sides:
			indices.append(i)
			indices.append(i + (sides + 1))
			indices.append((i + 1))

			indices.append(i + (sides + 1))
			indices.append((i + 1) + (sides + 1))
			indices.append((i + 1))
	else:
		for i in range(1, sides * 2 + 1, 2):
			indices.append(i)
			indices.append(i + (sides * 2))
			indices.append((i + 1) % (sides * 2))

			indices.append((i + 1) % (sides * 2)) 
			indices.append(i + (sides * 2))
			indices.append((i + 1 + (sides * 2)) % (sides * 2) + (sides * 2))
		
		for vertex in indices:
			print("[SimpleShapeDeco.gd] Index ", var_to_str(vertex), ": ", var_to_str(sideVertices[vertex]))
		

	uv = []
	if !sharp:
		for i in sides:
			uv.append(lerp(Vector2(1, 0), Vector2(0, 0), float(i) / (sides)))
		uv.append(Vector2(0, 0))

		for i in sides:
			uv.append(lerp(Vector2(1, 1), Vector2(0, 1), float(i) / (sides)))
		uv.append(Vector2(0, 1))

		
	else:
		uv.append(Vector2(0, 0))
		for i in sides - 1:
			uv.append(lerp(Vector2(1, 0), Vector2(0, 0), float(i) / sides))
			uv.append(lerp(Vector2(1, 0), Vector2(0, 0), float(i + 1) / sides))
		uv.append(lerp(Vector2(1, 0), Vector2(0, 0), float(sides - 1) / sides))

		uv.append(Vector2(0, 1))
		for i in sides - 1:
			uv.append(lerp(Vector2(1, 1), Vector2(0, 1), float(i) / sides))
			uv.append(lerp(Vector2(1, 1), Vector2(0, 1), float(i + 1) / sides))
		uv.append(lerp(Vector2(1, 1), Vector2(0, 1), float(sides - 1) / sides))

	normal = getSideNormals(sideVertices)
	print("[SimpleShapeDeco.gd] ", sideVertices.size(), " ", normal.size())

	proceduralMesh.addMeshCustom(
		mesh,
		sideVertices,
		indices,
		uv,
		normal,
		false
	)
		


func getVertices(vertHeight: float):
	var vertices = []
	# var angle = 0.0
	# var angleStep = 2.0 * PI / sides
	var mult: float = 1.0
	for i in sides:
		var angle = i * 2.0 * PI / sides

		if sides % 2 == 0:
			angle += PI / sides
		if i == 0:
			mult = 1 / cos(PI / sides)
			# print("[SimpleShapeDeco.gd] Mult: ", mult, " Angle: ", PI / sides)

		var x = cos(angle) * (width / 2) * mult
		var z = sin(angle) * (depth / 2) * mult
		vertices.append(Vector3(x, vertHeight, z))
	return vertices

func getSideNormals(vertices: PackedVector3Array):
	var normals = []
	if !sharp:
		for vertex in vertices:
			normals.append((Vector3(vertex.x, 0, vertex.z)).normalized())
		return normals
		
	else:
		normals.append(Vector3.RIGHT)
		for i in range(1, sides * 2 - 1, 2):
			var v1: Vector3 = vertices[i]
			var v2: Vector3 = vertices[i + 1]

			var normal1: Vector3 = (Vector3(v1.x, 0, v1.z))
			var normal2: Vector3 = (Vector3(v2.x, 0, v2.z))

			var normal: Vector3 = (normal1 + normal2).normalized()
			normals.append(normal)
			normals.append(normal)
		normals.append(Vector3.RIGHT)

		var newNormals: PackedVector3Array = []
		newNormals.append_array(normals)
		newNormals.append_array(normals)
		return newNormals
