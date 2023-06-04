extends Node

@export_range(1, 4)
var nrOfCars = 4

var FollowingCamera := preload("FollowingCamera.gd")
var CarObjectScene := preload("Car.tscn")

@export
var nrLaps: int = 5

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
		car.respawnPosition = car.global_position
		car.respawnRotation = car.global_rotation

		var cpSystem = %CheckPointSystem
		for cp in cpSystem.get_children():
			cp.bodyEnteredCheckpoint.connect(car.onCheckpoint_bodyEntered)
		
		car.nrCheckpoints = cpSystem.get_child_count()
		car.nrLaps = nrLaps
		
		%Countdown.countdownFinished.connect(car.onCountdown_finished)

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

		var canvasLayer = CanvasLayer.new()
		canvasLayer.follow_viewport_enabled = true
		viewPort.add_child(canvasLayer)

		var debugLabel = DebugLabel.new()
		canvasLayer.add_child(debugLabel)

		car.debugLabel = debugLabel

		viewPortContainer.add_child(viewPort)
		viewPort.add_child(camera)

		if i % 2 == 0:
			%VerticalSplitTop.add_child(viewPortContainer)
		else:
			%VerticalSplitBottom.add_child(viewPortContainer)
