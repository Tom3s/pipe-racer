extends Node3D
class_name Translator

@onready var xPos: Node3D = %XPos
@onready var yPos: Node3D = %YPos
@onready var zPos: Node3D = %ZPos

signal positionChanged(newPosition: Vector3)

func setPostion(newPosition: Vector3):
	global_position = newPosition

	positionChanged.emit(newPosition)

