extends Control

class_name IngameHUD

@onready
var speedometer: Label = %Speedometer

@onready
var positionLabel: Label = %Position

@onready
var lap: Label = %Lap

@onready
var lapTimer: Label = %LapTimer

@onready
var stats: Label = %Stats

@onready
var readyIndicator: Label = %ReadyIndicator

@onready
var resetIndicator: Label = %ResetIndicator

@onready
var nickname: Label = %Nickname

var car: CarController = null
var timeTrialManager: TimeTrialManager = null
# var globalPlacement: int = -1

var TOTAL_CARS: int = 0

func init(initialCar: CarController, initialTimeTrialManager: TimeTrialManager, totalCars: int) -> void:
	car = initialCar
	timeTrialManager = initialTimeTrialManager
	TOTAL_CARS = totalCars
	%HUDContainer.hide()

func _ready() -> void:
	print("HUD loaded")
	setNickname(car.playerName)
	setReadyIndicator(false)
	setResetIndicator(false)

	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	setSpeedText(car.getSpeed())
	setPositionText(car.state.placement, TOTAL_CARS)
	setLapText(car.state.currentLap + 1, car.state.nrLaps)
	setLapTimerText(timeTrialManager.getCurrentLapTime())
	setStatsText(timeTrialManager.getTotalTime(), timeTrialManager.getLastLap(), timeTrialManager.getBestLap())
	# setReadyIndicator(car.incorrectCheckPoint) 
	setReadyIndicator(!car.state.isReady)
	setResetIndicator(car.state.isResetting)


func setSpeedText(speed: float) -> void:
	# convert speed from m/s to km/h
	# speedometer.text = str(int(speed)) + " M/s | " + str(int(speed * 1.25)) + " Ku/H" 
	speedometer.text = str(int(speed * 1.25)) + " KM/H"

func setPositionText(currentPosition: int, total: int) -> void:
	positionLabel.text = "Pos: " + str(currentPosition) + "/" + str(total)

func setLapText(currentLap: int, total: int) -> void:
	lap.text = "Lap: " + str(min(currentLap, total)) + "/" + str(total)

func setLapTimerText(ticks: int) -> void:
	lapTimer.text = IngameHUD.getTimeStringFromTicks(ticks)

func setStatsText(totalTick: int, lastLapTicks: int, bestLapTicks: int) -> void:
	stats.text = "Total:\t" + IngameHUD.getTimeStringFromTicks(totalTick) + "\n"
	stats.text += "-------\t==========\n"
	stats.text += "Last:\t" + IngameHUD.getTimeStringFromTicks(lastLapTicks) + "\n"
	stats.text += "Best:\t" + IngameHUD.getTimeStringFromTicks(bestLapTicks)

# func setReadyIndicator(needsRespawn: bool) -> void:
# 	readyIndicator.visible = needsRespawn

func setReadyIndicator(isReady: bool) -> void:
	readyIndicator.visible = isReady

func setResetIndicator(isResetting: bool) -> void:
	resetIndicator.visible = isResetting

static func getTimeStringFromTicks(ticks: int) -> String:
	if ticks == -1:
		return "N/A"
	var seconds: int = ticks / 1000
	var minutes: int = seconds / 60

	return "%02d:%02d:" % [minutes % 60, seconds % 60] + ("%.3f" % ((ticks % 1000) / float(1000))).split(".")[1]

func setNickname(newName: String) -> void:
	nickname.text = newName

func startTimer():
	%HUDContainer.show()

func reset():
	%HUDContainer.hide()
