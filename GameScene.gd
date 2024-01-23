extends Node3D
class_name GameScene

@onready var Map = preload("res://MapScene.tscn")
@onready var MapEnvironment = preload("res://TestTrackEnv.tscn")

 
var map: Map

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

) -> bool:
	# load map
	map = Map.instantiate()
	add_child(map)

	# TODO: check if map exists locally, if not, download it
	var success = map.loadMap(mapName)
	if !success:
		print("Failed to load map: " + mapName)
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

	%GameEventListener.replayGhost.setTimeMultiplier(timeMultiplier)

	if timeMultiplier != 1.0:
		%GameEventListener.state.timeMultiplier = timeMultiplier
		%GameEventListener.addGhosts([] as Array[String], downloadedReplays)
		%GameEventListener.replayGhost.setTimeMultiplier(timeMultiplier)
	else:
		%GameEventListener.addGhosts(localReplays, downloadedReplays)

	# load environment
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
