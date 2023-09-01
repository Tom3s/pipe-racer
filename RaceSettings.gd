extends Node
class_name RaceSettings

var mapName: String

var nrPlayers: int

var players: Array[PlayerData]

var nrLaps: int

func _init(initialMapName, initialNrLaps):
	mapName = initialMapName
	nrLaps = initialNrLaps
	players = []

func addPlayer(playerData):
	players.append(playerData)
	nrPlayers = players.size()

