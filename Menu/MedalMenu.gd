extends VBoxContainer
class_name MedalMenu

@onready var builderTotalTime: Label = %BuilderTotalTime
@onready var goldTotalTime: Label = %GoldTotalTime
@onready var silverTotalTime: Label = %SilverTotalTime
@onready var bronzeTotalTime: Label = %BronzeTotalTime

@onready var builderLapTime: Label = %BuilderLapTime
@onready var goldLapTime: Label = %GoldLapTime
@onready var silverLapTime: Label = %SilverLapTime
@onready var bronzeLapTime: Label = %BronzeLapTime

@onready var totalTimeMedals: VBoxContainer = %TotalTimeMedals
@onready var lapTimeMedals: VBoxContainer = %LapTimeMedals

@onready var totalTimePBLabel: Label = %TotalTimePBLabel
@onready var lapTimePBLabel: Label = %LapTimePBLabel

@onready var showGhostButton: Button = %ShowGhostButton

const GOLD_MULTIPLIER = 1.1
const SILVER_MULTIPLIER = 1.25
const BRONZE_MULTIPLIER = 1.5

var totalTimeRecord: int = 0
var lapTimeRecord: int = 0

signal showGhostToggled(checked: bool)

func _ready():
	showGhostButton.toggled.connect(func(checked: bool):
		showGhostToggled.emit(checked)
	)

func setTimes(totalTime: int, lapTime: int):
	totalTimeRecord = totalTime
	lapTimeRecord = lapTime

	builderTotalTime.text = IngameHUD.getTimeStringFromTicks(totalTime)
	goldTotalTime.text = IngameHUD.getTimeStringFromTicks(int(totalTime * GOLD_MULTIPLIER))
	silverTotalTime.text = IngameHUD.getTimeStringFromTicks(int(totalTime * SILVER_MULTIPLIER))
	bronzeTotalTime.text = IngameHUD.getTimeStringFromTicks(int(totalTime * BRONZE_MULTIPLIER))

	builderLapTime.text = IngameHUD.getTimeStringFromTicks(lapTime)
	goldLapTime.text = IngameHUD.getTimeStringFromTicks(int(lapTime * GOLD_MULTIPLIER))
	silverLapTime.text = IngameHUD.getTimeStringFromTicks(int(lapTime * SILVER_MULTIPLIER))
	bronzeLapTime.text = IngameHUD.getTimeStringFromTicks(int(lapTime * BRONZE_MULTIPLIER))

const SPECIAL_MEDAL_INDEX = 0
const GOLD_MEDAL_INDEX = 2
const SILVER_MEDAL_INDEX = 4
const BRONZE_MEDAL_INDEX = 6


func setVisibleMedalsTotal(time: int):
	totalTimePBLabel.text = IngameHUD.getTimeStringFromTicks(time) if time != 9223372036854775807 else "N/A"
	for child in totalTimeMedals.get_children():
		child.visible = false
	
		totalTimeMedals.get_child(SPECIAL_MEDAL_INDEX).visible = time <= totalTimeRecord
		totalTimeMedals.get_child(GOLD_MEDAL_INDEX).visible = time <= int(totalTimeRecord * GOLD_MULTIPLIER)
		totalTimeMedals.get_child(SILVER_MEDAL_INDEX).visible = time <= int(totalTimeRecord * SILVER_MULTIPLIER)
		totalTimeMedals.get_child(BRONZE_MEDAL_INDEX).visible = time <= int(totalTimeRecord * BRONZE_MULTIPLIER)

		totalTimeMedals.get_child(SPECIAL_MEDAL_INDEX + 1).visible = time > totalTimeRecord
		totalTimeMedals.get_child(GOLD_MEDAL_INDEX + 1).visible = time > int(totalTimeRecord * GOLD_MULTIPLIER)
		totalTimeMedals.get_child(SILVER_MEDAL_INDEX + 1).visible = time > int(totalTimeRecord * SILVER_MULTIPLIER)
		totalTimeMedals.get_child(BRONZE_MEDAL_INDEX + 1).visible = time > int(totalTimeRecord * BRONZE_MULTIPLIER)

func setVisibleMedalsLap(time: int):
	lapTimePBLabel.text = IngameHUD.getTimeStringFromTicks(time) if time != 9223372036854775807 else "N/A"
	for child in lapTimeMedals.get_children():
		child.visible = false
	
		lapTimeMedals.get_child(SPECIAL_MEDAL_INDEX).visible = time <= lapTimeRecord
		lapTimeMedals.get_child(GOLD_MEDAL_INDEX).visible = time <= int(lapTimeRecord * GOLD_MULTIPLIER)
		lapTimeMedals.get_child(SILVER_MEDAL_INDEX).visible = time <= int(lapTimeRecord * SILVER_MULTIPLIER)
		lapTimeMedals.get_child(BRONZE_MEDAL_INDEX).visible = time <= int(lapTimeRecord * BRONZE_MULTIPLIER)

		lapTimeMedals.get_child(SPECIAL_MEDAL_INDEX + 1).visible = time > lapTimeRecord
		lapTimeMedals.get_child(GOLD_MEDAL_INDEX + 1).visible = time > int(lapTimeRecord * GOLD_MULTIPLIER)
		lapTimeMedals.get_child(SILVER_MEDAL_INDEX + 1).visible = time > int(lapTimeRecord * SILVER_MULTIPLIER)
		lapTimeMedals.get_child(BRONZE_MEDAL_INDEX + 1).visible = time > int(lapTimeRecord * BRONZE_MULTIPLIER)

func getCurrentMultiplier(time: int) -> float:
	if time > totalTimeRecord * BRONZE_MULTIPLIER:
		return BRONZE_MULTIPLIER
	elif time > totalTimeRecord * SILVER_MULTIPLIER:
		return SILVER_MULTIPLIER
	elif time > totalTimeRecord * GOLD_MULTIPLIER:
		return GOLD_MULTIPLIER
	else:
		return 1.0

func resetGhostToggle():
	showGhostButton.set_pressed_no_signal(false)