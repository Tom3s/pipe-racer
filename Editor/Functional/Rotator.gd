extends Node3D
class_name Rotator

@onready var direction: Node3D = %Direction
@onready var elevation: Node3D = %Elevation
@onready var tilt: Node3D = %Tilt

signal rotationChanged(newRotation: Vector3)

func setRotation(newRotation: Vector3):
	direction.rotation.y = newRotation.y
	elevation.rotation.x = newRotation.x
	tilt.rotation.z = newRotation.z

	rotationChanged.emit(newRotation)

func moveToNode(node: Node3D):
	global_position = node.global_position
	setRotation(node.global_rotation)	

func _ready():
	direction.get_child(1).rotationChanged.connect(func():
		rotationChanged.emit(getRotation())
	)
	elevation.get_child(1).rotationChanged.connect(func():
		rotationChanged.emit(getRotation())
	)
	tilt.get_child(1).rotationChanged.connect(func():
		rotationChanged.emit(getRotation())
	)

func getRotation():
	return Vector3(elevation.rotation.x, direction.rotation.y, tilt.rotation.z)

func disable():
	direction.get_child(1).use_collision = false
	elevation.get_child(1).use_collision = false
	tilt.get_child(1).use_collision = false
	visible = false

func enable():
	direction.get_child(1).use_collision = true
	elevation.get_child(1).use_collision = true
	tilt.get_child(1).use_collision = true
	visible = true