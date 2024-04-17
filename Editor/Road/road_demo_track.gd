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

	for area in %Fluids.get_children():
		area = area as Area3D
		area.body_entered.connect(func(body: Node3D):
			# if body is CarController:
			body.inFluid = area
		)
		area.body_exited.connect(func(body: Node3D):
			# if body is CarController:
			body.inFluid = null
		)
