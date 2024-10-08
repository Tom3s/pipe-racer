extends Node3D
class_name RaceIngame

@onready
var Map = preload("res://MapScene.tscn")

@onready
var MapEnvironment = preload("res://TestTrackEnv.tscn")
var Car := preload("res://CarController.tscn")
var HudScene := preload("res://HUD/HUD.tscn")

var raceSettings: RaceSettings

var map: Map

var raceEventListener: RaceEventListener
var raceInputHandler: RaceInputHandler

var environment: WorldEnvironment

var verticalSplitTop: HBoxContainer
var verticalSplitBottom: HBoxContainer


signal exitPressed()


func setup(newRaceSettings: RaceSettings):
	raceSettings = newRaceSettings

	# currentMapName = raceSettings.mapName
	map = Map.instantiate()
	add_child(map)
	map.loadFrom = raceSettings.mapName
	map.setIngame()

	if raceSettings.nrLaps == -1:
		raceSettings.nrLaps = map.lapCount

	raceEventListener = %RaceEventListener
	raceInputHandler = %RaceInputHandler

	raceInputHandler.setup(raceSettings.nrLocalPlayers)

	environment = MapEnvironment.instantiate()
	add_child(environment)

	verticalSplitTop = %VerticalSplitTop
	verticalSplitBottom = %VerticalSplitBottom

	var cars: Array[CarController] = []
	setupCars(cars)
	
	var timeTrialManagers: Array[TimeTrialManager] = []
	for i in raceSettings.nrLocalPlayers:
		timeTrialManagers.append(TimeTrialManager.new(%IngameSFX, raceSettings.nrLaps))
	var huds: Array[IngameHUD] = []
	var cameras: Array[FollowingCamera] = []

	setupViewports(timeTrialManagers, huds, cameras)

	var stats: Array[RaceStats] = []
	for i in raceSettings.nrLocalPlayers:
		stats.append(RaceStats.new(map.trackId))

	raceEventListener.setup(
		cars, 
		timeTrialManagers, 
		huds, 
		cameras, 
		stats, 
		map, 
		%IngameSFX, 
		raceSettings.localPlayers, 
		raceSettings.ranked,
		raceSettings.online
	)


func setupCars(cars: Array[CarController]):
	var playersNode = %Players
	var checkpointCount = map.getCheckpointCount()
	for i in raceSettings.nrLocalPlayers:
		var spawnPoint = map.start.getStartPosition(i, raceSettings.nrLocalPlayers)
		var car: CarController = Car.instantiate()
		playersNode.add_child(car)

		var inputDevices: Array[int] = []
		if raceSettings.nrLocalPlayers == 1:
			inputDevices.append_array([1, 2, 3, 4])
		else:
			inputDevices.append(i + 1)

		car.setup(raceSettings.localPlayers[i], i, inputDevices, spawnPoint, checkpointCount, raceSettings.nrLaps)
		cars.append(car)

func setupViewports(timeTrialManagers: Array[TimeTrialManager], huds: Array[IngameHUD], cameras: Array[FollowingCamera]):
	var index = 0
	if raceSettings.nrLocalPlayers == 1:
		%VerticalSplitBottom.visible = false
	for car in %Players.get_children():
		var camera = FollowingCamera.new(car)
		cameras.append(camera)
		var viewPortContainer = getNewViewportContainer()
		var viewPort = getNewViewport()

		var canvasLayer = CanvasLayer.new()
		canvasLayer.follow_viewport_enabled = true

		var hud: IngameHUD = HudScene.instantiate()
		hud.init(car, timeTrialManagers[index], raceSettings.nrLocalPlayers)

		huds.append(hud)

		canvasLayer.add_child(hud)

		viewPort.add_child(canvasLayer)
		viewPortContainer.add_child(viewPort)
		viewPort.add_child(camera)
		if index % 2 == 0:
			%VerticalSplitTop.add_child(viewPortContainer)
		else:
			%VerticalSplitBottom.add_child(viewPortContainer)
		
		index += 1

	# var viewPortContainer = getNewViewportContainer()

func getNewViewportContainer() -> SubViewportContainer:
	var viewPortContainer = SubViewportContainer.new()
	viewPortContainer.stretch = true
	viewPortContainer.size_flags_horizontal = SubViewportContainer.SIZE_EXPAND_FILL
	viewPortContainer.size_flags_vertical = SubViewportContainer.SIZE_EXPAND_FILL

	return viewPortContainer

func getNewViewport() -> SubViewport:
	var viewPort = SubViewport.new()
	viewPort.audio_listener_enable_3d = true
	viewPort.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	return viewPort

func _ready():
	# var player1 = PlayerData.new(0, "mogyi", Color.DARK_RED)
	# var player2 = PlayerData.new(1, "tometo", Color.TURQUOISE)
	# var player3 = PlayerData.new(2, "Player 3", Color(0, 1, 0))
	# var player4 = PlayerData.new(3, "Player 4", Color(1, 1, 1))

	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-08-28T13-12-49.json", 3)
	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-08-30T21-41-44.json", 10)
	# # TAMAS TRACKJE \|/ (nagyon szar amugy)
	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-09-01T22-01-56.json", 20)
	# # mogyi mapja jee
	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-09-01T22-50-49.json", 7)
	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-09-03T12-50-40.json", 5)
	# # cool track with proper editor
	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-09-03T16-41-15.json", 4)
	# # another cool track with proper editor
	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-09-03T23-25-13.json", 5)
	# # raceSettings = RaceSettings.new("res://builderTracks/track_2023-09-04T20-31-46.json", 3)
	# raceSettings = RaceSettings.new("matyi cool trackje.json")
	# # 20:712
	# raceSettings.addPlayer(player1)
	# raceSettings.addPlayer(player2)
	# # raceSettings.addPlayer(player3)
	# # raceSettings.addPlayer(player4)

	# init(raceSettings)
	pass


