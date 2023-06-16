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
var respawnIndicator: Label = %RespawnIndicator

@onready
var nickname: Label = %Nickname


var car: CarRigidBody = null
var timeTrialManager: TimeTrialManager = null

var TOTAL_CARS: int = 0

# func _init(initialCar: CarRigidBody, initialTimeTrialManager: TimeTrialManager, totalCars: int) -> void:
# 	car = initialCar
# 	timeTrialManager = initialTimeTrialManager
# 	TOTAL_CARS = totalCars

func init(initialCar: CarRigidBody, initialTimeTrialManager: TimeTrialManager, totalCars: int) -> void:
	car = initialCar
	timeTrialManager = initialTimeTrialManager
	TOTAL_CARS = totalCars
	setNickname(car.playerName)
	%HUDContainer.hide()

func _ready() -> void:
	print("HUD loaded")
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	setSpeedText(car.getSpeed())
	setPositionText(car.placement, TOTAL_CARS)
	setLapText(car.currentLap + 1, car.nrLaps)
	setLapTimerText(timeTrialManager.getCurrentLapTime())
	setStatsText(timeTrialManager.getTotalTime() + timeTrialManager.getCurrentLapTime(), timeTrialManager.getLastLap(), timeTrialManager.getBestLap())
	setRespawnIndicator(car.incorrectCheckPoint) 


func setSpeedText(speed: float) -> void:
	speedometer.text = str(int(speed)) + " KM/H"

func setPositionText(currentPosition: int, total: int) -> void:
	positionLabel.text = "Pos: " + str(currentPosition) + "/" + str(total)

func setLapText(currentLap: int, total: int) -> void:
	lap.text = "Lap: " + str(max(currentLap, total)) + "/" + str(total)

func setLapTimerText(ticks: int) -> void:
	lapTimer.text = getTimeStringFromTicks(ticks)

func setStatsText(totalTick: int, lastLapTicks: int, bestLapTicks: int) -> void:
	stats.text = "Total:\t" + getTimeStringFromTicks(totalTick) + "\n"
	stats.text += "-------\t==========\n"
	stats.text += "Last:\t" + getTimeStringFromTicks(lastLapTicks) + "\n"
	stats.text += "Best:\t" + getTimeStringFromTicks(bestLapTicks)

func setRespawnIndicator(needsRespawn: bool) -> void:
	respawnIndicator.visible = needsRespawn

func getTimeStringFromTicks(ticks: int) -> String:
	if ticks == -1:
		return "N/A"
	var seconds: int = ticks / 1000
	var minutes: int = seconds / 60

	return "%02d:%02d:" % [minutes % 60, seconds % 60] + ("%.3f" % ((ticks % 1000) / float(1000))).split(".")[1]

func setNickname(name: String) -> void:
	nickname.text = name

func onCountdown_finished(_timestamp):
	%HUDContainer.show()

func onReset():
	%HUDContainer.hide()
