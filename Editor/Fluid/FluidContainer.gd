@tool
extends Area3D
class_name FluidContainer

@export
var density: float = 1.0

@export_range(0.1, 5.0, 0.1)
var viscosity: float = 1.0

@export_range(PrefabConstants.GRID_SIZE, 100 * PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE)
var width: float = 32:
	set(newValue):
		width = newValue
		updateSize()

@export_range(PrefabConstants.GRID_SIZE, 100 * PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE)
var height: float = 16:
	set(newValue):
		height = newValue
		updateSize()

@export_range(PrefabConstants.GRID_SIZE, 100 * PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE)
var length: float = 32:
	set(newValue):
		length = newValue
		updateSize()


@onready var mesh: MeshInstance3D = %Mesh
@onready var collider: CollisionShape3D = %Collider

func updateSize() -> void:
	var size := Vector3(width, height, length)
	
	if mesh == null:
		return
	
	mesh.mesh.size = size
	mesh.position = size / 2

	if collider == null:
		return

	collider.shape.size = size
	collider.position = size / 2


func _ready():
	updateSize()



