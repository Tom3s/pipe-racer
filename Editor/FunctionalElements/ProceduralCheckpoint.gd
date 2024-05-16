@tool
extends Node3D
class_name ProceduralCheckpoint

@onready var mesh: MeshInstance3D = %Mesh
@onready var collider: CSGTorus3D = %Collider

var collectedMaterial := preload("res://Editor/FunctionalElements/ProceduralCheckpointGreen.tres")
var uncollectedMaterial := preload("res://Editor/FunctionalElements/ProceduralCheckpointRed.tres")

@export_range(PrefabConstants.GRID_SIZE, 16.0, PrefabConstants.GRID_SIZE / 2)
var ringWidth: float = 4.0:
	set(newValue):
		ringWidth = newValue
		if collider != null:
			collider.outer_radius = ringRadius + 2*ringWidth
		refreshRingMesh()

@export_range(16.0, 128.0, PrefabConstants.GRID_SIZE)
var ringRadius: float = 32.0:
	set(newValue):
		ringRadius = newValue
		if collider != null:
			collider.inner_radius = ringRadius
			collider.outer_radius = ringRadius + 2*ringWidth
		refreshRingMesh()

var proceduralMesh: ProceduralMesh = ProceduralMesh.new()

func _ready() -> void:
	refreshRingMesh()
	setUncollected()

func refreshRingMesh() -> void:
	if mesh == null:
		return

	var vertices: PackedVector3Array = PackedVector3Array()

	var smallCircleVertices: PackedVector3Array = PackedVector3Array()
	# var smallSegments: int = 8
	var smallSegments: int = 9

	for i in smallSegments:
		var angle: float = i * 2.0 * PI / (smallSegments - 1)
		
		var vertex: Vector3 = Vector3(0.0, cos(angle) * ringWidth - ringRadius - ringWidth, sin(angle) * ringWidth)

		smallCircleVertices.push_back(vertex)
	
	var largeSegments: int = 25
	# var largeSegments: int = 4
	var angleDifference: float = 2.0 * PI / (largeSegments - 1)

	var mainRingVertices: PackedVector3Array = PackedVector3Array()



	for i in largeSegments:
		var angle: float = i * angleDifference

		for vertex in smallCircleVertices:
			var rotatedVertex: Vector3 = Vector3(vertex.x, vertex.y, vertex.z)
			rotatedVertex = rotatedVertex.rotated(Vector3.BACK, angle)
			mainRingVertices.push_back(rotatedVertex)
	
	mesh.mesh = ArrayMesh.new()

	proceduralMesh.addMeshTo(
		mesh,
		mainRingVertices,
		smallSegments,
		largeSegments,
	)

func setCollected():
	mesh.set_surface_override_material(0, collectedMaterial)

func setUncollected():
	mesh.set_surface_override_material(0, uncollectedMaterial)