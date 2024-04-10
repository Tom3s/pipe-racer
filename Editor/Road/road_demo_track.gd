extends Node3D

@onready var roadPieces: Node3D = %RoadPieces

var carCamera: FollowingCamera


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in roadPieces.get_children():
		child = child as RoadMeshGenerator
		child.convertToPhysicsObject()

	carCamera = FollowingCamera.new(%Car)
	add_child(carCamera)

	carCamera.current = true
	%Car.state.hasControl = true
	%Car.state.isReady = true