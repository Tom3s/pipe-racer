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

# @export
# var PRECISE_INPUT: bool = false:
# 	set(newPrecise):
# 		PRECISE_INPUT = newPrecise
# 		saveToFile()
# 	get:
# 		return PRECISE_INPUT
@export
var DEADZONE: float = 0.1:
	set(newDeadzone):
		DEADZONE = clamp(newDeadzone, 0.0, 0.5)
		saveToFile()
	get:
		return DEADZONE

@export
var SMOOTH_STEERING: float = 0.75:
	set(newSmoothing):
		# SMOOTH_STEERING = clamp(remap(newSmoothing, 0, 1, 0.99, 0.5), 0.5, 0.99)
		SMOOTH_STEERING = newSmoothing
		ingameSmoothSteering = clamp(remap(newSmoothing, 0, 1, 0.275, 0.04), 0.04, 0.275)
		saveToFile()
	get:
		return SMOOTH_STEERING

@export
var JOY_CONTROL_OVERWRITES = {
	"1": {},
	"2": {},
	"3": {},
	"4": {},
}

@export
var KB_CONTROL_OVERWRITES = {
	"1": {},
	"2": {},
	"3": {},
	"4": {},
}

@export
var CONTROL_DEVICE_OVERWRITES = {
	"1": [0, 1],
	"2": [0, 2],
	"3": [3],
	"4": [4]
}

var ingameSmoothSteering: float = 0.1

var SESSION_TOKEN: String = ""
var USER_ID: String = ""

const SAVE_FILE := "user://player.json"


func _ready() -> void:
	loadFromFile()
	playerSelectorNode = playerSelectorMenu.instantiate()
	add_child(playerSelectorNode)

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
		"FIX_PEDAL_INPUT": FIX_PEDAL_INPUT,
		"DEADZONE": DEADZONE,
		"SMOOTH_STEERING": SMOOTH_STEERING,
		"JOY_CONTROL_OVERWRITES": JOY_CONTROL_OVERWRITES,
		"KB_CONTROL_OVERWRITES": KB_CONTROL_OVERWRITES,
		"CONTROL_DEVICE_OVERWRITES": CONTROL_DEVICE_OVERWRITES,
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
		if jsonData.has("DEADZONE"):
			DEADZONE = float(jsonData["DEADZONE"])
		if jsonData.has("SMOOTH_STEERING"):
			SMOOTH_STEERING = float(jsonData["SMOOTH_STEERING"])
		if jsonData.has("JOY_CONTROL_OVERWRITES"):
			JOY_CONTROL_OVERWRITES = jsonData["JOY_CONTROL_OVERWRITES"]
		if jsonData.has("KB_CONTROL_OVERWRITES"):
			KB_CONTROL_OVERWRITES = jsonData["KB_CONTROL_OVERWRITES"]
		if jsonData.has("CONTROL_DEVICE_OVERWRITES"):
			CONTROL_DEVICE_OVERWRITES = jsonData["CONTROL_DEVICE_OVERWRITES"]
	else:
		saveToFile()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saveToFile()

var settingsMenuNode: Node
var settingsMenuOwner: Node
var settingsMenuClosePressed: Callable
func setOriginalSettingsMenu(parent: Node, menu: Node, closePressed: Callable):
	settingsMenuNode = menu
	settingsMenuOwner = parent
	settingsMenuClosePressed = closePressed

func borrowSettingsMenu(newOwner: Node, closePressed: Callable) -> Node:
	settingsMenuNode.reparent(newOwner)
	settingsMenuNode.closePressed.disconnect(settingsMenuClosePressed)
	settingsMenuNode.closePressed.connect(closePressed)
	return settingsMenuNode

func returnSettingsMenu(closePressed: Callable) -> void:
	settingsMenuNode.closePressed.disconnect(closePressed)
	settingsMenuNode.closePressed.connect(settingsMenuClosePressed)
	settingsMenuNode.reparent(settingsMenuOwner)


var playerSelectorMenu = preload("res://PlayerSelectorMenu.tscn")

var playerSelectorNode: Node 
# var playerSelectorOwner: Node
func borrowPlayerSelectorMenu(newOwner: Node, backPressed: Callable, nextPressed: Callable) -> Node:
	playerSelectorNode.reparent(newOwner)
	# newOwner.add_child(playerSelectorNode)
	playerSelectorNode.backPressed.connect(backPressed)
	playerSelectorNode.nextPressed.connect(nextPressed)
	return playerSelectorNode

func returnPlayerSelectorMenu(backPressed: Callable, nextPressed: Callable) -> void:
	playerSelectorNode.backPressed.disconnect(backPressed)
	playerSelectorNode.nextPressed.disconnect(nextPressed)
	# if playerSelectorNode.get_parent() != null:
	# 	playerSelectorNode.get_parent().remove_child(playerSelectorNode)
	playerSelectorNode.reparent(self)
