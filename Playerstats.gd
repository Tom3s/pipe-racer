extends Node

# var PlayerData = preload("res://PlayerData.gd")

@export
var PLAYER_NAME: String = "Player" + str(randi() % 1000):
	set(newName):
		PLAYER_NAME = onPlayerNameChanged(newName)
	get:
		return PLAYER_NAME

@export
var PLAYER_COLOR: Color = Color(randf(), randf(), randf(), 1.0):
	set(newColor):
		PLAYER_COLOR = onPlayerColorChanged(newColor)
	get:
		return PLAYER_COLOR

const SAVE_FILE := "user://player.json"

func _ready() -> void:
	loadFromFile()

func onPlayerNameChanged(newName: String) -> String:
	saveToFile()
	return newName

func onPlayerColorChanged(newColor: Color) -> Color:
	saveToFile()
	return newColor

func saveToFile() -> void:
	var jsonData = {
		"PLAYER_NAME": PLAYER_NAME,
		"PLAYER_COLOR": PLAYER_COLOR.to_html(),
	}

	var jsonText = JSON.stringify(jsonData)

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(jsonText)

func loadFromFile() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var jsonText = file.get_as_text()
		var jsonData = JSON.parse_string(jsonText)

		PLAYER_NAME = jsonData["PLAYER_NAME"]
		PLAYER_COLOR = Color.from_string(jsonData["PLAYER_COLOR"], Color.TURQUOISE)
