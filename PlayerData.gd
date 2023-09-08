extends Resource
class_name PlayerData

@export
var PLAYER_ID: String

@export
var SESSION_TOKEN: String

@export
var PLAYER_NAME: String

@export
var PLAYER_COLOR: Color

func _init(playerId, playerName, playerColor, sessionToken = ""):
	PLAYER_ID = str(playerId)
	PLAYER_NAME = playerName
	PLAYER_COLOR = playerColor
	SESSION_TOKEN = sessionToken
