extends Node

# var PlayerData = preload("res://PlayerData.gd")

@export
var PLAYER_NAME: String = "Player" + str(randi() % 1000):
	set(newName):
		PLAYER_NAME = onPlayerNameChanged(newName)
		saveToFile()
	get:
		return PLAYER_NAME

@export
var PLAYER_PASSWORD: String = "":
	set(newPassword):
		PLAYER_PASSWORD = newPassword
		saveToFile()
	get:
		return PLAYER_PASSWORD



@export
var PLAYER_COLOR: Color = Color(randf(), randf(), randf(), 1.0):
	set(newColor):
		PLAYER_COLOR = onPlayerColorChanged(newColor)
		saveToFile()
	get:
		return PLAYER_COLOR


@export
var MASTER_VOLUME: float = 100.0:
	set(newVolume):
		MASTER_VOLUME = newVolume
		saveToFile()
	get:
		return MASTER_VOLUME

@export
var MUSIC_VOLUME: float = 100.0:
	set(newVolume):
		MUSIC_VOLUME = newVolume
		saveToFile()
	get:
		return MUSIC_VOLUME

@export
var SFX_VOLUME: float = 100.0:
	set(newVolume):
		SFX_VOLUME = newVolume
		saveToFile()
	get:
		return SFX_VOLUME

@export
var FULLSCREEN: bool = false:
	set(newFullscreen):
		FULLSCREEN = newFullscreen
		if FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		saveToFile()
	get:
		return FULLSCREEN

@export
var RENDER_QUALITY: float = 1.0:
	set(newQuality):
		RENDER_QUALITY = newQuality
		if is_equal_approx(newQuality, 1.0):
			ProjectSettings.set_setting("rendering/scaling_3d/mode", Viewport.SCALING_3D_MODE_BILINEAR)
		else:
			ProjectSettings.set_setting("rendering/scaling_3d/mode", Viewport.SCALING_3D_MODE_FSR)
		ProjectSettings.set_setting("rendering/scaling_3d/scale", newQuality)
		saveToFile()		
	get:
		return RENDER_QUALITY

@export
var FIX_PEDAL_INPUT: bool = false:
	set(newFix):
		FIX_PEDAL_INPUT = newFix
		saveToFile()
	get:
		return FIX_PEDAL_INPUT

var SESSION_TOKEN: String = ""
var USER_ID: String = ""

const SAVE_FILE := "user://player.json"


func _ready() -> void:
	loadFromFile()

func onPlayerNameChanged(newName: String) -> String:
	# saveToFile()
	return newName

func onPlayerColorChanged(newColor: Color) -> Color:
	# saveToFile()
	return newColor

func saveToFile() -> void:
	var jsonData = {
		"PLAYER_NAME": PLAYER_NAME,
		"PLAYER_PASSWORD": PLAYER_PASSWORD,
		"PLAYER_COLOR": PLAYER_COLOR.to_html(),
		"MASTER_VOLUME": MASTER_VOLUME,
		"MUSIC_VOLUME": MUSIC_VOLUME,
		"SFX_VOLUME": SFX_VOLUME,
		"FULLSCREEN": FULLSCREEN,
		"RENDER_QUALITY": RENDER_QUALITY,
		"FIX_PEDAL_INPUT": FIX_PEDAL_INPUT
	}

	var jsonText = JSON.stringify(jsonData)

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(jsonText)

func loadFromFile() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var jsonText = file.get_as_text()
		var jsonData = JSON.parse_string(jsonText)

		if jsonData.has("PLAYER_NAME"):
			PLAYER_NAME = jsonData["PLAYER_NAME"]
		if jsonData.has("PLAYER_PASSWORD"):
			PLAYER_PASSWORD = jsonData["PLAYER_PASSWORD"]
		if jsonData.has("PLAYER_COLOR"):
			PLAYER_COLOR = Color.html(jsonData["PLAYER_COLOR"])
		if jsonData.has("MASTER_VOLUME"):
			MASTER_VOLUME = float(jsonData["MASTER_VOLUME"])
		if jsonData.has("MUSIC_VOLUME"):
			MUSIC_VOLUME = float(jsonData["MUSIC_VOLUME"])
		if jsonData.has("SFX_VOLUME"):
			SFX_VOLUME = float(jsonData["SFX_VOLUME"])
		if jsonData.has("FULLSCREEN"):
			FULLSCREEN = bool(jsonData["FULLSCREEN"])
		if jsonData.has("RENDER_QUALITY"):
			RENDER_QUALITY = float(jsonData["RENDER_QUALITY"])
		if jsonData.has("FIX_PEDAL_INPUT"):
			FIX_PEDAL_INPUT = bool(jsonData["FIX_PEDAL_INPUT"])
	else:
		saveToFile()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saveToFile()
