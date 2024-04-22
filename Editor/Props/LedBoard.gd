@tool
extends Node3D
class_name LedBoard

var boardMaterial: Material = preload("res://Track Props/SignMaterial.tres")
var metalMaterial: Material = preload("res://Track Props/SimpleBlackMetal.tres")

@onready var boardMesh: MeshInstance3D = %BoardMesh
@onready var supportMesh: MeshInstance3D = %SupportMesh

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE * 512, PrefabConstants.GRID_SIZE)
var width: float = 80:
	set(newValue):
		width = newValue
		refreshAll()

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE * 512, PrefabConstants.GRID_SIZE)
var height: float = 48:
	set(newValue):
		height = newValue 
		refreshAll()

func _ready():
	refreshAll()

func refreshAll() -> void:
	refreshBoardMesh()
	refreshBackMesh()

var proceduralMesh: ProceduralMesh = ProceduralMesh.new()

func refreshBoardMesh() -> void:
	var centeringOffset: Vector3 = Vector3(-width / 2, -height / 2, 0)
	var vertices: PackedVector3Array = PackedVector3Array()

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)

	proceduralMesh.addMeshTo(
		boardMesh,
		vertices,
		2,
		2, 
		1,
		false
	)

	setBoardMaterial()

func refreshBackMesh() -> void:
	var centeringOffset: Vector3 = Vector3(-width / 2, -height / 2, 0)
	var vertices: PackedVector3Array = PackedVector3Array()

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, height, -PrefabConstants.GRID_SIZE) + centeringOffset)
	
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, -PrefabConstants.GRID_SIZE) + centeringOffset)
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, -PrefabConstants.GRID_SIZE) + centeringOffset)

	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)
	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)

	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)
	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, height, -PrefabConstants.GRID_SIZE) + centeringOffset)

	proceduralMesh.addMeshTo(
		boardMesh,
		vertices,
		2,
		8, 
		1,
		false,
		false
	)

	centeringOffset = Vector3(-width / 2, -height / 2, -PrefabConstants.GRID_SIZE)
	vertices = PackedVector3Array()

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)

	proceduralMesh.addMeshTo(
		boardMesh,
		vertices,
		2,
		2, 
		1,
		true,
		false
	)

	setBackMaterial()

func setBoardMaterial() -> void:
	var newMaterial: ShaderMaterial = boardMaterial.duplicate()
	newMaterial.set_shader_parameter("width", width)
	newMaterial.set_shader_parameter("height", height)
	newMaterial.set_shader_parameter("Pixel_Amount", 14)
	boardMesh.set_surface_override_material(0, newMaterial)


func setBackMaterial() -> void:
	boardMesh.set_surface_override_material(1, metalMaterial)
	boardMesh.set_surface_override_material(2, metalMaterial)



