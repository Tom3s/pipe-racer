extends Node

const SAVE_FILE := "user://network-config.json"

@export
var BACKEND_IP_ADRESS: String = "http://localhost:80":
	set(newAddress):
		BACKEND_IP_ADRESS = newAddress
		saveToFile()
	get:
		return BACKEND_IP_ADRESS

@export
var FRONTEND_IP_ADRESS: String = "http://localhost:3000":
	set(newAddress):
		FRONTEND_IP_ADRESS = newAddress
		saveToFile()
	get:
		return FRONTEND_IP_ADRESS

func _ready() -> void:
	loadFromFile()

func saveToFile() -> void:
	var jsonData = {
		"BACKEND_IP_ADRESS": BACKEND_IP_ADRESS,
		"FRONTEND_IP_ADRESS": FRONTEND_IP_ADRESS
	}

	var jsonText = JSON.stringify(jsonData, "\t")

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(jsonText)

func loadFromFile() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var jsonText = file.get_as_text()
		var jsonData = JSON.parse_string(jsonText)

		BACKEND_IP_ADRESS = jsonData["BACKEND_IP_ADRESS"]
		FRONTEND_IP_ADRESS = jsonData["FRONTEND_IP_ADRESS"]
	else:
		saveToFile()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saveToFile()

