extends Node

@export_range(1, 4)
var nrOfCars = 4

var FollowingCamera := preload("FollowingCamera.gd")
var CarObjectScene := preload("Car.tscn")

func _ready():
	if nrOfCars == 1:
		%VerticalSplitBottom.visible = false
	
	for i in nrOfCars:
		var color = Color(randf(), randf(), randf())
		var car: CarRigidBody = CarObjectScene.instantiate()
		car.frameColor = color
		car.playerIndex = i + 1
		car.global_transform.origin = Vector3(0, 0, i * 10)
		car.rotation_degrees.y = 90
		car.initialPosition = car.global_position
		car.initialRotation = car.global_rotation
		car.respawn()
		add_child(car)
		var camera = FollowingCamera.new(car, i)

		var viewPortContainer = SubViewportContainer.new()
		viewPortContainer.stretch = true
		viewPortContainer.size_flags_horizontal = SubViewportContainer.SIZE_EXPAND_FILL
		viewPortContainer.size_flags_vertical = SubViewportContainer.SIZE_EXPAND_FILL
		var viewPort = SubViewport.new()
		viewPort.audio_listener_enable_3d = true
		viewPort.render_target_update_mode = SubViewport.UPDATE_ALWAYS

		viewPortContainer.add_child(viewPort)
		viewPort.add_child(camera)

		if i % 2 == 0:
			%VerticalSplitTop.add_child(viewPortContainer)
		else:
			%VerticalSplitBottom.add_child(viewPortContainer)
