extends Node3D

@onready var pipes: Node3D = %Pipes

var carCamera: FollowingCamera


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in pipes.get_children():
		child = child as PipeMeshGenerator
		child.convertToPhysicsObject()

	carCamera = FollowingCamera.new(%Car)
	add_child(carCamera)

	carCamera.current = true
	%Car.state.hasControl = true
	%Car.state.isReady = true