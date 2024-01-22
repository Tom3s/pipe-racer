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


const GOLD_MULTIPLIER = 1.1
const SILVER_MULTIPLIER = 1.25
const BRONZE_MULTIPLIER = 1.5

func setTimes(totalTime: int, lapTime: int):
	builderTotalTime.text = IngameHUD.getTimeStringFromTicks(totalTime)
	goldTotalTime.text = IngameHUD.getTimeStringFromTicks(int(totalTime * GOLD_MULTIPLIER))
	silverTotalTime.text = IngameHUD.getTimeStringFromTicks(int(totalTime * SILVER_MULTIPLIER))
	bronzeTotalTime.text = IngameHUD.getTimeStringFromTicks(int(totalTime * BRONZE_MULTIPLIER))

	builderLapTime.text = IngameHUD.getTimeStringFromTicks(lapTime)
	goldLapTime.text = IngameHUD.getTimeStringFromTicks(int(lapTime * GOLD_MULTIPLIER))
	silverLapTime.text = IngameHUD.getTimeStringFromTicks(int(lapTime * SILVER_MULTIPLIER))
	bronzeLapTime.text = IngameHUD.getTimeStringFromTicks(int(lapTime * BRONZE_MULTIPLIER))
	

