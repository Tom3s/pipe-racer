@tool
extends Node3D

@onready var mesh: MeshInstance3D = %Mesh


@export_range(0.1, 256, 0.1)
var width: float = 1.0:
	set(value):
		width = value
		refreshMesh()
@export_range(0.1, 256, 0.1)
var height: float = 1.0:
	set(value):
		height = value
		refreshMesh()
@export_range(0.1, 256, 0.1)
var depth: float = 1.0:
	set(value):
		depth = value
		refreshMesh()

@export
var sides: int = 3:
	set(value):
		sides = value
		if sides <= 12:
			sharp = true
		refreshMesh()

@export
var pointy: bool = false:
	set(value):
		pointy = value
		refreshMesh()

@export
var sharp: bool = true:
	set(value):
		sharp = value || sides <= 12
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
		# topVertices = [Vector3(0, height, 0)]
		for i in sides:
			topVertices.append(Vector3(0, height, 0))
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
			if !pointy:
				indices.append(i)
				indices.append(i + (sides + 1))
				indices.append((i + 1))

			indices.append(i + (sides + 1))
			indices.append((i + 1) + (sides + 1))
			indices.append((i + 1))
	else:
		for i in range(1, sides * 2 + 1, 2):
			if !pointy:
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

		if sides == 3:
			# mult *= .75
			pass

		var x = cos(angle) * (width / 2) * mult
		var z = sin(angle) * (depth / 2) * mult
		vertices.append(Vector3(x, vertHeight, z))
	return vertices

func getSideNormals(vertices: PackedVector3Array):
	var normals = []
	if !sharp:
		if !pointy:
			for i in sides:
				var vertex: Vector3 = vertices[i]
				normals.append((Vector3(vertex.x, 0, vertex.z)).normalized())
			normals.append(normals[0])

			var newNormals: PackedVector3Array = []
			newNormals.append_array(normals)
			newNormals.append_array(normals)
			return newNormals

		else:
			for i in sides:
				# var v1: Vector3 = vertices[i]
				# var v2: Vector3 = vertices[i + sides]
				# var v3: Vector3 = vertices[i + sides + 1]
				# var v4: Vector3 = lerp(v2, v3, 0.5)

				# var normal: Vector3 = ((v1 - v4).rotated((v1.cross(v4).normalized()), PI / 2)).normalized()
				# normals.append(normal)
				normals.append(Vector3(0, 1, 0))
			normals.append(normals[0])

			var extra: Vector3
			for i in sides:
				var v1: Vector3 = vertices[i]
				var v2: Vector3 = vertices[i + sides + 1]

				var normal: Vector3 = ((v1 - v2).rotated((v1.cross(v2).normalized()), PI / 2)).normalized()
				normals.append(normal)

				if !i:
					extra = normal
			
			normals.append(extra)

			for normal in normals:
				print("[SimpleShapeDeco.gd] Normal: ", var_to_str(normal), " ", var_to_str(normal.is_normalized()))

			return normals

			

	else:
		if !pointy:
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


		else:
			for i in range(0, sides * 2, 2):
				var v1: Vector3 = vertices[i]
				var v2: Vector3 = vertices[i + sides * 2]
				var v3: Vector3 = vertices[i + sides * 2 + 1]
				var v4: Vector3 = lerp(v2, v3, 0.5)

				var normal: Vector3 = ((v1 - v4).rotated((v1.cross(v4).normalized()), PI / 2)).normalized()
				normals.append(normal)
				normals.append(normal)
			
			# normals.append(normals[0])
			# normals.remove_at(0)
			normals.insert(0, normals.back())
			normals.pop_back()
		
		var newNormals: PackedVector3Array = []
		newNormals.append_array(normals)
		newNormals.append_array(normals)
		return newNormals

				
