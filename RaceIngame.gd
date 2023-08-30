extends Node3D
class_name RaceIngame

@onready
var Map = preload("res://MapScene.tscn")

@onready
var MapEnvironment = preload("res://TestTrackEnv.tscn")
var Car := preload("res://CarController.tscn")

var raceSettings: RaceSettings

var map: Map

var raceEventListener: RaceEventListener
var raceInputHandler: RaceInputHandler

var environment: WorldEnvironment

var verticalSplitTop: HBoxContainer
var verticalSplitBottom: HBoxContainer

func init(newRaceSettings: RaceSettings):
	raceSettings = newRaceSettings

	# currentMapName = raceSettings.mapName
	map = Map.instantiate()
	add_child(map)
	map.loadFrom = raceSettings.mapName

	raceEventListener = %RaceEventListener
	raceInputHandler = %RaceInputHandler

	environment = MapEnvironment.instantiate()
	add_child(environment)

	verticalSplitTop = %VerticalSplitTop
	verticalSplitBottom = %VerticalSplitBottom

	setupCars()
	setupViewports()


func setupCars():
	var playersNode = %Players
	for i in raceSettings.nrPlayers:
		var spawnPoint = map.start.getStartPosition(i, raceSettings.nrPlayers)
		var car: CarController = Car.instantiate()
		playersNode.add_child(car)

		car.setup(raceSettings.players[i], i + 1, spawnPoint["position"], spawnPoint["rotation"])

func setupViewports():
	var index = 0
	for car in %Players.get_children():
		var camera = FollowingCamera.new(car)
		var viewPortContainer = getNewViewportContainer()
		var viewPort = getNewViewport()

		var canvasLayer = CanvasLayer.new()
		canvasLayer.follow_viewport_enabled = true
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
	var player1 = PlayerData.new(0, "Player 1", Color(1, 0, 0))
	var player2 = PlayerData.new(1, "Player 2", Color(0, 0, 1))
	var player3 = PlayerData.new(2, "Player 3", Color(0, 1, 0))
	var player4 = PlayerData.new(3, "Player 4", Color(1, 1, 1))

	# raceSettings = RaceSettings.new("res://builderTracks/track_2023-08-28T13-12-49.json", 3)
	raceSettings = RaceSettings.new("res://builderTracks/track_2023-08-30T21-41-44.json", 3)
	raceSettings.addPlayer(player1)
	raceSettings.addPlayer(player2)
	raceSettings.addPlayer(player3)
	raceSettings.addPlayer(player4)

	init(raceSettings)


