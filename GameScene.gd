extends Node3D
class_name GameScene

@onready var Map = preload("res://MapScene.tscn")
@onready var MapEnvironment = preload("res://TestTrackEnv.tscn")

@onready var mapScene: PackedScene = preload("res://Editor/InteractiveMap.tscn")

 
var map = null

signal exitPressed()
signal finishedLoading()

func setup(
	mapName: String,
	ranked: bool = false,
	online: bool = false,
	validation: bool = false,
	localReplays: Array[String] = [],
	downloadedReplays: Array[String] = [],
	timeMultiplier: float = 1.0,
	totalTimePB: int = 9223372036854775807,
	lapTimePB: int = 9223372036854775807,

) -> bool:
	# load map

	# try loading new format
	map = mapScene.instantiate() as InteractiveMap
	add_child(map)

	var success = map.importTrack(mapName)
	if !success:
		print("[GameScene.gd] Failed to load map: " + mapName)
		print("[GameScene.gd] Trying legacy format")
		map.queue_free()

		map = Map.instantiate()
		add_child(map)

		# TODO: check if map exists locally, if not, download it
		success = map.loadMap(mapName)
		if !success:
			print("[GameScene.gd] Failed to load legacy format, exiting.")
			exitPressed.emit()
			return false


	map.setIngame()

	%GameEventListener.state.ranked = ranked
	%GameEventListener.state.online = online
	%GameEventListener.state.validation = validation

	if validation && map.bestTotalReplay != "":
		localReplays = [
			map.bestTotalReplay.split("/")[-1],
		]

	%GameEventListener.map = map

	# %GameEventListener.ingameMedalMenu.chronoTime = map.bestTotalTime
	# %GameEventListener.ingameMedalMenu.blitzTime = map.bestLapTime
	# %GameEventListener.ingameMedalMenu.totalTimePB = totalTimePB
	# %GameEventListener.ingameMedalMenu.lapTimePB = lapTimePB
	%GameEventListener.ingameMedalMenu.setup(
		map.bestTotalTime,
		map.bestLapTime,
		totalTimePB,
		lapTimePB,
		map.trackId
	)

	%GameEventListener.replayGhost.setTimeMultiplier(timeMultiplier)

	print("Time Multiplier: ", timeMultiplier)
	if timeMultiplier != 1.0:
		%GameEventListener.state.timeMultiplier = timeMultiplier
		%GameEventListener.addGhosts([] as Array[String], [map.bestTotalReplay + '.replay'] as Array[String])
		%GameEventListener.replayGhost.setTimeMultiplier(timeMultiplier)
	else:
		%GameEventListener.addGhosts(localReplays, downloadedReplays)

	# load environment
	if ClassFunctions.getClassName(map) == "Map":
		var environment: WorldEnvironment = MapEnvironment.instantiate()
		add_child(environment)
		

	if !online:
		initializeLocalPlayers()
	
	finishedLoading.emit()

	return true

func initializePlayers():
	%GameEventListener.clearPlayers()
	if Network.userId == 1:
		for key in Network.playerDatas:
			%GameEventListener.addPlayers(Network.playerDatas[key], key.to_int())

func initializeLocalPlayers():
	%GameEventListener.addPlayers(Network.localData, 1)
