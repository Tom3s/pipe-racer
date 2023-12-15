extends Node

const SAVE_FILE := "user://network-config.json"

@export
var BACKEND_IP_ADRESS: String = "https://pipe-racer.pro":
	set(newAddress):
		BACKEND_IP_ADRESS = newAddress
		saveToFile()
	get:
		return BACKEND_IP_ADRESS

@export
var FRONTEND_IP_ADRESS: String = "https://pipe-racer.pro/":
	set(newAddress):
		FRONTEND_IP_ADRESS = newAddress
		saveToFile()
	get:
		return FRONTEND_IP_ADRESS

var OVERWRITE: bool = false

func _ready() -> void:
	loadFromFile()

func saveToFile() -> void:
	var jsonData = {
		"BACKEND_IP_ADRESS": BACKEND_IP_ADRESS,
		"FRONTEND_IP_ADRESS": FRONTEND_IP_ADRESS,
		"OVERWRITE": OVERWRITE
	}

	var jsonText = JSON.stringify(jsonData, "\t")

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(jsonText)

func loadFromFile() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var jsonText = file.get_as_text()
		var jsonData = JSON.parse_string(jsonText)

		if !jsonData.has("OVERWRITE"):
			saveToFile()
			return
		var overWrite = jsonData["OVERWRITE"]

		if !overWrite:
			return

		BACKEND_IP_ADRESS = jsonData["BACKEND_IP_ADRESS"]
		FRONTEND_IP_ADRESS = jsonData["FRONTEND_IP_ADRESS"]
		OVERWRITE = jsonData["OVERWRITE"]
		saveToFile()
	else:
		saveToFile()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saveToFile()

