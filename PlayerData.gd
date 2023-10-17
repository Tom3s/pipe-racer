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

# var NETWORK_ID: int

func _init(playerId, playerName, playerColor, sessionToken = ""):
	PLAYER_ID = str(playerId)
	PLAYER_NAME = playerName
	PLAYER_COLOR = playerColor
	# NETWORK_ID = networkId
	SESSION_TOKEN = sessionToken

func toJson(safe: bool = false) -> String:
	var data = {
		"playerId": PLAYER_ID,
		"playerName": PLAYER_NAME,
		"playerColor": PLAYER_COLOR.to_html(),
		"sessionToken": "" if safe else SESSION_TOKEN
	}
	return JSON.stringify(data)

static func fromJson(json: String):
	var data = JSON.parse_string(json)
	return PlayerData.new(
		data["playerId"],
		data["playerName"],
		Color.from_string(data["playerColor"], Color.WHITE),
		data["sessionToken"]
	)
	