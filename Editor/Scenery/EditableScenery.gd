@tool
extends Node3D
class_name EditableScenery

@onready var collider: CollisionShape3D = %Collider
@onready var groundMesh: MeshInstance3D = %Mesh

class VertexHeight:
	var vertices: PackedVector3Array = []
	var size: int = 2

	func reset(size: int):
		self.size = size
		vertices.resize(size * size)
		for i in size:
			for j in size:
				var x = i * PrefabConstants.TRACK_WIDTH - size * PrefabConstants.TRACK_WIDTH / 2
				var z = j * PrefabConstants.TRACK_WIDTH - size * PrefabConstants.TRACK_WIDTH / 2

				# TODO: remove in production
				# var y = randi_range(0, 30) * PrefabConstants.GRID_SIZE
				var y = 0

				vertices[i * size + j] = Vector3(x, y, z)
	
	func getHeightArray():
		var heights: PackedFloat32Array = []
		for i in size:
			for j in size:
				heights.push_back(vertices[j * size + i].y / PrefabConstants.TRACK_WIDTH)
		
		return heights
	
	func moveHeight(x: int, z: int, y: int):
		vertices[z * size + x].y += y

var vertexHeights: VertexHeight = VertexHeight.new()

@export_range(2, 150, 1)
var groundSize: int = 21:
	set(newValue):
		groundSize = newValue
		vertexHeights.reset(groundSize)
		if collider != null:
			setCollider()
		if groundMesh != null:
			setMesh()

func _ready():
	vertexHeights.reset(groundSize)

	setCollider()
	setMesh()


func _process(_delta):
	pass

func setCollider():
	var trackWidth = PrefabConstants.TRACK_WIDTH
	collider.scale = Vector3(trackWidth, trackWidth, trackWidth)
	collider.shape.map_width = groundSize
	collider.shape.map_depth = groundSize
	collider.shape.map_data = vertexHeights.getHeightArray()

func setMesh() -> void:
	var meshData = []
	meshData.resize(ArrayMesh.ARRAY_MAX)

	meshData[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(vertexHeights.vertices)
	meshData[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(getVertexIndexArray())
	meshData[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array(getUVArray())


	groundMesh.mesh = ArrayMesh.new()
	groundMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)
	groundMesh.position = Vector3(PrefabConstants.TRACK_WIDTH / 2, 0, PrefabConstants.TRACK_WIDTH / 2)



func getVertexIndexArray() -> PackedInt32Array:
	var indexList: PackedInt32Array = []
	for i in groundSize - 1:
		for j in groundSize - 1:
			var index = i * groundSize + j
			indexList.push_back(index)
			indexList.push_back(index + groundSize)
			indexList.push_back(index + 1)

			indexList.push_back(index + 1)
			indexList.push_back(index + groundSize) 
			indexList.push_back(index + groundSize + 1)
	
	return indexList

func getUVArray() -> PackedVector2Array:
	var uvList: PackedVector2Array = []
	for i in groundSize:
		for j in groundSize:
			uvList.push_back(Vector2(float(i) / (groundSize - 1), float(j) / (groundSize - 1)))
	
	return uvList

func getClosestVertex(worldPos: Vector3) -> Vector2i:
	var x := roundi((worldPos.x + (groundSize / 2) * (PrefabConstants.TRACK_WIDTH)) \
		/ PrefabConstants.TRACK_WIDTH) 
	var z := roundi((worldPos.z + (groundSize / 2) * (PrefabConstants.TRACK_WIDTH)) \
		/ PrefabConstants.TRACK_WIDTH)


	return Vector2i(x, z)

func moveVertex(indices: Vector2i, direction: int) -> void:
	if direction == 0:
		return
	direction /= abs(direction)

	vertexHeights.moveHeight(indices.y, indices.x, direction * PrefabConstants.GRID_SIZE)
	setCollider()
	setMesh()