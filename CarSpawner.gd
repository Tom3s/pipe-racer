extends Node3D

# @export_range(0, 4)
# var nrOfCars = 4

class_name CarSpawner

var FollowingCamera := preload("FollowingCamera.gd")
var CarObjectScene := preload("Car.tscn")

@export
var nrLaps: int = 3

@export
var nrCarsSpawned: int = 0

func _ready():
	pass

func spawnForLocalGame(nrOfCars: int):
	nrCarsSpawned = nrOfCars
	if nrOfCars == 1:
		%VerticalSplitBottom.visible = false
	
	for i in nrOfCars:
		var color = Color(randf(), randf(), randf())
		if i == 0:
			color = Playerstats.PLAYER_COLOR
		var car: CarRigidBody = CarObjectScene.instantiate()
		car.frameColor = color
		car.playerIndex = i + 1

		car.respawnPosition = global_position

		var cpSystem = %CheckPointSystem
		for cp in cpSystem.get_children():
			cp.bodyEnteredCheckpoint.connect(car.onCheckpoint_bodyEntered)
		
		car.nrCheckpoints = cpSystem.get_child_count()
		car.nrLaps = nrLaps
		
		%UniversalCanvas/Countdown.countdownFinished.connect(car.onCountdown_finished)

		car.finishedRacing.connect(onCarFinishedRacing)

		car.respawn()
		add_child(car)
		var camera = FollowingCamera.new(car)

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
		debugLabel.nrLaps = nrLaps
		canvasLayer.add_child(debugLabel)

		car.debugLabel = debugLabel

		viewPortContainer.add_child(viewPort)
		viewPort.add_child(camera)

		if i % 2 == 0:
			%VerticalSplitTop.add_child(viewPortContainer)
		else:
			%VerticalSplitBottom.add_child(viewPortContainer)

func spawnCar(peer_id: int):
	var color = Playerstats.PLAYER_COLOR
	if peer_id == -1:
		peer_id = get_tree().get_multiplayer().get_unique_id()
	# else:
	# 	color = Color(randf(), randf(), randf())
	
	if has_node(str(peer_id)):
		return

	var car: CarRigidBody = CarObjectScene.instantiate()
	car.name = str(peer_id)
	car.frameColor = color

	car.finishedRacing.connect(onCarFinishedRacing)

	car.playerIndex = 1
	var nrPeers = get_tree().get_multiplayer().get_peers().size()
	print("Friends of peer ", peer_id, ": ", nrPeers)
	# car.global_transform.origin = Vector3(0, 0, 10 * nrPeers)
	car.respawnPosition = global_position + Vector3(0, 0, nrPeers * 10)
	# print("respawnPosition of ", peer_id, ": ", car.respawnPosition)
	car.respawnRotation = car.global_rotation

	var cpSystem = %CheckPointSystem
	for cp in cpSystem.get_children():
		cp.bodyEnteredCheckpoint.connect(car.onCheckpoint_bodyEntered)
	
	car.nrCheckpoints = cpSystem.get_child_count()
	car.nrLaps = nrLaps

	add_child(car)
	
	# car.respawn()
	
	nrCarsSpawned += 1
	

var finishedCars: int = 0

func onCarFinishedRacing():
	finishedCars += 1
	if finishedCars == nrCarsSpawned:
		get_parent().get_node("%LeaderboardUI/%List").refreshLists()
		get_parent().get_node("%LeaderboardUI/%List").show()

# func _process(delta):
# 	print("nr cars: ", nrCarsSpawned)
