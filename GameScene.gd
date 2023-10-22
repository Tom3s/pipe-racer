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

	%GameEventListener.map = map

	%GameEventListener.state.ranked = ranked
	%GameEventListener.state.online = online

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
