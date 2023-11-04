extends Control

class_name IngameHUD

@onready
var spedometerText: Label = %SpedometerText

@onready
var spedometerBar: TextureProgressBar = %SpedometerBar

@onready
var positionLabel: Label = %Position

@onready
var lap: Label = %Lap

@onready
var lapTimer: Label = %LapTimer

# @onready
# var stats: Label = %Stats
@onready var statsTotal: Label = %StatsTotal
@onready var statsLast: Label = %StatsLast
@onready var statsBest: Label = %StatsBest

@onready
var readyIndicator: VBoxContainer = %ReadyIndicator

@onready
var resetIndicator: Label = %ResetIndicator

@onready
var nickname: Label = %Nickname

@onready
var promptIcon: TextureRect = %PromptIcon


@onready
var currentSplit: Label = %CurrentSplit

@onready
var lastSplit: Label = %LastSplit

var car: CarController = null
var timeTrialManager: TimeTrialManager = null
# var globalPlacement: int = -1

# TODO: make this a static after updating to Godot 4.2
var TOTAL_CARS: int = 0

func init(initialCar: CarController, initialTimeTrialManager: TimeTrialManager, totalCars: int) -> void:
	car = initialCar
	timeTrialManager = initialTimeTrialManager
	timeTrialManager.checkPointCollected.connect(displaySplit)
	TOTAL_CARS = totalCars
	%HUDContainer.hide()

func _ready() -> void:
	print("HUD loaded")
	setNickname(car.playerName)
	setReadyIndicator(false)
	setResetIndicator(false)

	loadReadyIcon()

	car.playerIndexChanged.connect(loadReadyIcon)
	
	splits.modulate = Color(1, 1, 1, 0)

	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	setSpedometer(car.getSpeed())
	setPositionText(car.state.placement, TOTAL_CARS)
	setLapText(car.state.currentLap + 1, car.state.nrLaps)
	setLapTimerText(timeTrialManager.getCurrentLapTime())
	setStatsText(timeTrialManager.getTotalTime(), timeTrialManager.getLastLap(), timeTrialManager.getBestLap())
	# setReadyIndicator(car.incorrectCheckPoint) 
	setReadyIndicator(!car.state.isReady)
	setResetIndicator(car.state.isResetting)
	setNickname(car.playerName)
	splitsVisibleFrames -= 1
	if splitsVisibleFrames <= 0:
		splits.modulate = Color(1, 1, 1, lerp(splits.modulate.a, 0.0, 0.2))

var newTexture: Texture = null
func _input(event):
	if event is InputEventMouse:
		return

	if event is InputEventJoypadButton || (event is InputEventJoypadMotion && abs(event.get_axis_value()) > 0.5):
		for possibleEvent in InputMap.action_get_events("p" + str(car.playerIndex + 1) + "_ready"):
			if possibleEvent is InputEventJoypadButton:
				newTexture = load(RebindMenu.CONTROLLER_BUTTON_ICONS[possibleEvent.button_index])
				break
			elif possibleEvent is InputEventJoypadMotion:
				newTexture = load(RebindMenu.CONTROLLER_AXIS_ICONS[possibleEvent.axis])
				break
	elif event is InputEventKey:
		for possibleEvent in InputMap.action_get_events("p" + str(car.playerIndex + 1) + "_ready"):
			if possibleEvent is InputEventKey:
				newTexture = load("res://Sprites/KBPrompts/" + str(possibleEvent.physical_keycode) + ".png")
				break
	if newTexture == null:
		newTexture = load(RebindMenu.INVALID_KEY_ICON)
	promptIcon.texture = newTexture

func setSpedometer(speed: float) -> void:
	# convert speed from m/s to km/h
	# speedometer.text = str(int(speed)) + " M/s | " + str(int(speed * 1.25)) + " Ku/H" 
	spedometerText.text = str(int(speed * 1.25))
	spedometerBar.value = speed * 1.25

func setPositionText(currentPosition: int, total: int) -> void:
	positionLabel.text = "Pos: " + str(currentPosition) + "/" + str(total)

func setLapText(currentLap: int, total: int) -> void:
	lap.text = "Lap: " + str(min(currentLap, total)) + "/" + str(total)

func setLapTimerText(ticks: int) -> void:
	lapTimer.text = IngameHUD.getTimeStringFromTicks(ticks)

func setStatsText(totalTick: int, lastLapTicks: int, bestLapTicks: int) -> void:
	# stats.text = "Total:\t" + IngameHUD.getTimeStringFromTicks(totalTick) + "\n"
	# stats.text += "-------\t==========\n"
	# stats.text += "Last:\t" + IngameHUD.getTimeStringFromTicks(lastLapTicks) + "\n"
	# stats.text += "Best:\t" + IngameHUD.getTimeStringFromTicks(bestLapTicks)
	statsTotal.text = IngameHUD.getTimeStringFromTicks(totalTick)
	statsLast.text = IngameHUD.getTimeStringFromTicks(lastLapTicks)
	statsBest.text = IngameHUD.getTimeStringFromTicks(bestLapTicks)

# func setReadyIndicator(needsRespawn: bool) -> void:
# 	readyIndicator.visible = needsRespawn

func setReadyIndicator(isReady: bool) -> void:
	readyIndicator.visible = isReady

func setResetIndicator(isResetting: bool) -> void:
	resetIndicator.visible = isResetting

static func getTimeStringFromTicks(ticks: int) -> String:
	if ticks == -1:
		return "N/A"
	var seconds: int = floori(float(ticks) / 1000)
	var minutes: int = floori(float(seconds) / 60)

	return "%02d:%02d:" % [minutes % 60, seconds % 60] + ("%.3f" % ((ticks % 1000) / float(1000))).split(".")[1]

func setNickname(newName: String) -> void:
	nickname.text = newName

func startTimer():
	%HUDContainer.show()

func reset(newNrPlayers: int):
	%HUDContainer.hide()
	TOTAL_CARS = newNrPlayers

func loadReadyIcon(_sink = null):
	var inputEvent = InputMap.action_get_events("p" + str(car.playerIndex + 1) + "_ready").front()
	var texture = null
	if inputEvent is InputEventJoypadButton:
		texture = load(RebindMenu.CONTROLLER_BUTTON_ICONS[inputEvent.button_index])
	elif inputEvent is InputEventJoypadMotion:
		texture = load(RebindMenu.CONTROLLER_AXIS_ICONS[inputEvent.axis])
	elif inputEvent is InputEventKey:
		texture = load("res://Sprites/KBPrompts/" + str(inputEvent.physical_keycode) + ".png")
	if texture == null:
		texture = load(RebindMenu.INVALID_KEY_ICON)
	promptIcon.texture = texture
	newTexture = texture

@onready var splits: VBoxContainer = %Splits

const SPLIT_ALPHA = 117/256.0
var splitsVisibleFrames: int = 0

func displaySplit(timestamp: int, lastTimestamp: int, currentLapTime: int):
	var difference = timestamp - lastTimestamp
	currentSplit.text = IngameHUD.getTimeStringFromTicks(currentLapTime)
	var prefix = ''
	var color = Color(0, 0, 0, SPLIT_ALPHA)

	if difference > 0:
		prefix = '+'
		color = Color(0.9, 0.2, 0.2, SPLIT_ALPHA)
	elif difference < 0:
		prefix = '-'
		color = Color(0.2, 0.9, 0.2, SPLIT_ALPHA)

	lastSplit.text = prefix + IngameHUD.getTimeStringFromTicks(abs(difference))

	# lastSplit.get_theme_stylebox("panel").bg_color = color
	var panel: PanelContainer = lastSplit.get_parent()
	panel.get_theme_stylebox("panel").bg_color = color

	splits.modulate = Color(1, 1, 1, 1)
	splitsVisibleFrames = floori(1.5 * 120)

	# var tween = create_tween()

	# tween.tween_interval(1.2)
	# tween.tween_property(splits, "modulate", Color(1, 1, 1, 0), 0.0)