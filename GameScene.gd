extends Node3D
class_name GameScene

@onready var Map = preload("res://MapScene.tscn")
@onready var MapEnvironment = preload("res://TestTrackEnv.tscn")

 
var map: Map

signal exitPressed()


func setup(
	mapName: String,

) -> void:
	# load map
	map = Map.instantiate()
	add_child(map)

	# TODO: check if map exists locally, if not, download it
	map.loadFrom = mapName
	map.setIngame()

	%GameEventListener.map = map

	# load environment
	var environment: WorldEnvironment = MapEnvironment.instantiate()
	add_child(environment)

func testingHost():
	var playerdata = PlayerData.new(
		1,
		GlobalProperties.PLAYER_NAME,
		GlobalProperties.PLAYER_COLOR,
	)

	# %GameEventListener.localPlayerDatas = [playerdata] as Array[PlayerData]
	%GameEventListener.addPlayers([playerdata] as Array[PlayerData], 1)

func testingClient():
	var playerdata = PlayerData.new(
		1,
		GlobalProperties.PLAYER_NAME,
		GlobalProperties.PLAYER_COLOR,
	)

	# %GameEventListener.localPlayerDatas = [playerdata] as Array[PlayerData]



func _ready():
	setup("user://tracks/downloaded/65072958793b0c04ae9aaee6.json")
	if Network.userId == 1:
		# for data in Network.localData:
		%GameEventListener.addPlayers(Network.localData, Network.userId)

