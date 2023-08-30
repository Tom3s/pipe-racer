extends Resource
class_name PlayerData

@export
var PLAYER_ID: String

@export
var PLAYER_NAME: String

@export
var PLAYER_COLOR: Color

func _init(playerId, playerName, playerColor):
	PLAYER_ID = str(playerId)
	PLAYER_NAME = playerName
	PLAYER_COLOR = playerColor
