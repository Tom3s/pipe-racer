class_name PlayerData
extends Resource

@export
var PLAYER_NAME: String

@export
var PLAYER_COLOR: Color

func _init(playerName, playerColor):
	PLAYER_NAME = playerName
	PLAYER_COLOR = playerColor