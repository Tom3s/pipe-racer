extends Node3D
class_name Translator

@onready var xPos: StaticBody3D = %XPos
@onready var yPos: StaticBody3D = %YPos
@onready var zPos: StaticBody3D = %ZPos

signal positionChanged(newPosition: Vector3)

func setPostion(newPosition: Vector3):
	global_position = newPosition

	positionChanged.emit(newPosition)

func disable():
	xPos.get_child(1).disabled = true
	yPos.get_child(1).disabled = true
	zPos.get_child(1).disabled = true
	visible = false

func enable():
	xPos.get_child(1).disabled = false
	yPos.get_child(1).disabled = false
	zPos.get_child(1).disabled = false
	visible = true
