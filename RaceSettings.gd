extends Node
class_name RaceSettings

var mapName: String

var ranked: bool

var nrPlayers: int

var players: Array[PlayerData]

var nrLaps: int

func _init(initialMapName, initialRanked = false, initialNrLaps = -1):
	mapName = initialMapName
	nrLaps = initialNrLaps
	ranked = initialRanked
	players = []

func addPlayer(playerData):
	players.append(playerData)
	nrPlayers = players.size()

