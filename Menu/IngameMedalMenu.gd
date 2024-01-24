@tool
extends Control
class_name IngameMedalMenu

# Total

@onready var chrono: TextureRect = %Chrono
@onready var goldTotal: TextureRect = %GoldTotal
@onready var silverTotal: TextureRect = %SilverTotal
@onready var bronzeTotal: TextureRect = %BronzeTotal

@onready var totalPBContainer: HBoxContainer = %TotalPBContainer
@onready var totalPBLabel: Label = %TotalPBLabel
@onready var totalPBDiff: Label = %TotalPBDiff

@onready var totalBeatenContainer: HBoxContainer = %TotalBeatenContainer
@onready var totalBeatenMedal: Label = %TotalBeatenMedal
@onready var totalBeatenDiff: Label = %TotalBeatenDiff

@onready var totalNextContainer: HBoxContainer = %TotalNextContainer
@onready var totalNextMedal: Label = %TotalNextMedal
@onready var totalNextDiff: Label = %TotalNextDiff

@onready var totalPlacementContainer: HBoxContainer = %TotalPlacementContainer
@onready var totalPlacement: Label = %TotalPlacement

# Best Lap

@onready var blitz: TextureRect = %Blitz
@onready var goldLap: TextureRect = %GoldLap
@onready var silverLap: TextureRect = %SilverLap
@onready var bronzeLap: TextureRect = %BronzeLap

@onready var lapPBContainer: HBoxContainer = %LapPBContainer
@onready var lapPBLabel: Label = %LapPBLabel
@onready var lapPBDiff: Label = %LapPBDiff

@onready var lapBeatenContainer: HBoxContainer = %LapBeatenContainer
@onready var lapBeatenMedal: Label = %LapBeatenMedal
@onready var lapBeatenDiff: Label = %LapBeatenDiff

@onready var lapNextContainer: HBoxContainer = %LapNextContainer
@onready var lapNextMedal: Label = %LapNextMedal
@onready var lapNextDiff: Label = %LapNextDiff

@onready var lapPlacementContainer: HBoxContainer = %LapPlacementContainer
@onready var lapPlacement: Label = %LapPlacement


var chronoTime: int = 0
var blitzTime: int = 0

var totalTimePB: int = 9223372036854775807
var lapTimePB: int = 9223372036854775807

var times: Array = [
	2000,
	1800,
	1450,
	1260,
	1220,
	1105,
	1050,
	1000,
	950,
	900,
]

var laptimes: Array = [
	2000,
	1800,
	1450,
	1260,
	1220,
	1105,
	1050,
	1000,
	950,
	900,
]

@export
var currentTime: int = 0:
	set(value):
		currentTime = value % times.size()
		setTotalTimePB(times[currentTime])

@export
var currentLap: int = 0:
	set(value):
		currentLap = value % laptimes.size()
		setLapTimePB(laptimes[currentLap])

func _ready():
	chrono.visible = false
	goldTotal.visible = false
	silverTotal.visible = false
	bronzeTotal.visible = false

	totalPBContainer.visible = false
	totalBeatenContainer.visible = false
	totalNextContainer.visible = false
	totalPlacementContainer.visible = true

	totalPlacement.text = "N/A"

	blitz.visible = false
	goldLap.visible = false
	silverLap.visible = false
	bronzeLap.visible = false

	lapPBContainer.visible = false
	lapBeatenContainer.visible = false
	lapNextContainer.visible = false
	lapPlacementContainer.visible = true

	chronoTime = 1000
	blitzTime = 1000

func setTotalTimePB(time: int) -> void:
	if totalTimePB == 9223372036854775807 || time <= totalTimePB:
		totalPBContainer.visible = true
		totalPBLabel.text = IngameHUD.getTimeStringFromTicks(time)
		if totalTimePB == 9223372036854775807:
			totalPBDiff.text = IngameHUD.getTimeStringFromTicks(0)
		else:
			totalPBDiff.text = IngameHUD.getTimeStringFromTicks(totalTimePB - time)
	else:
		totalPBContainer.visible = false
	
	# totalTimePB = time


	if time <= chronoTime:
		if totalTimePB > chronoTime:
			totalBeatenContainer.visible = true
			setTotalMedalText(totalBeatenMedal, "Chrono")
			totalBeatenDiff.text = IngameHUD.getTimeStringFromTicks(chronoTime - time)
		else:
			totalBeatenContainer.visible = false
		animateInTotalMedals(4)
		

	elif time <= chronoTime * MedalMenu.GOLD_MULTIPLIER:
		if totalTimePB > chronoTime * MedalMenu.GOLD_MULTIPLIER:
			totalBeatenContainer.visible = true
			setTotalMedalText(totalBeatenMedal, "Gold")
			totalBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.GOLD_MULTIPLIER) - time)
		else:
			totalBeatenContainer.visible = false
		animateInTotalMedals(3)


	elif time <= chronoTime * MedalMenu.SILVER_MULTIPLIER:
		if totalTimePB > chronoTime * MedalMenu.SILVER_MULTIPLIER:
			totalBeatenContainer.visible = true
			setTotalMedalText(totalBeatenMedal, "Silver")
			totalBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.SILVER_MULTIPLIER) - time)
		else:
			totalBeatenContainer.visible = false
		animateInTotalMedals(2)

	elif time <= chronoTime * MedalMenu.BRONZE_MULTIPLIER:
		if totalTimePB > chronoTime * MedalMenu.BRONZE_MULTIPLIER:
			totalBeatenContainer.visible = true
			setTotalMedalText(totalBeatenMedal, "Bronze")
			totalBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.BRONZE_MULTIPLIER) - time)
		else:
			totalBeatenContainer.visible = false
		animateInTotalMedals(1)

	else:
		totalBeatenContainer.visible = false

	if time <= totalTimePB:
		totalTimePB = time

	if totalTimePB <= chronoTime:
		totalNextContainer.visible = false
	elif totalTimePB <= chronoTime * MedalMenu.GOLD_MULTIPLIER:
		totalNextContainer.visible = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(chronoTime)
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - chronoTime)
	elif totalTimePB <= chronoTime * MedalMenu.SILVER_MULTIPLIER:
		totalNextContainer.visible = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.GOLD_MULTIPLIER))
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(chronoTime * MedalMenu.GOLD_MULTIPLIER))
	elif totalTimePB <= chronoTime * MedalMenu.BRONZE_MULTIPLIER:
		totalNextContainer.visible = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.SILVER_MULTIPLIER))
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(chronoTime * MedalMenu.SILVER_MULTIPLIER))
	else:
		totalNextContainer.visible = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.BRONZE_MULTIPLIER))
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(chronoTime * MedalMenu.BRONZE_MULTIPLIER))

func setTotalMedalText(label: Label, text: String):
	label.text = text
	if text == "Chrono":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", false)
	elif text == "Gold":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", true)
		(label.material as ShaderMaterial).set_shader_parameter("TextColor", Color(1, 0.8, 0.2))
	elif text == "Silver":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", true)
		(label.material as ShaderMaterial).set_shader_parameter("TextColor", Color(0.8, 0.8, 0.8))
	elif text == "Bronze":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", true)
		(label.material as ShaderMaterial).set_shader_parameter("TextColor", Color(0.8, 0.5, 0.2))

func animateInTotalMedals(nrMedals: int) -> void:
	assert(nrMedals >= 0 && nrMedals <= 4)

	bronzeTotal.visible = nrMedals >= 1 || bronzeTotal.visible
	silverTotal.visible = nrMedals >= 2 || silverTotal.visible
	goldTotal.visible = nrMedals >= 3 || goldTotal.visible
	chrono.visible = nrMedals >= 4 || chrono.visible

	# var tween = create_tween() #.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

func setLapTimePB(time: int) -> void:
	if lapTimePB == 9223372036854775807 || time <= lapTimePB:
		lapPBContainer.visible = true
		lapPBLabel.text = IngameHUD.getTimeStringFromTicks(time)
		if lapTimePB == 9223372036854775807:
			lapPBDiff.text = IngameHUD.getTimeStringFromTicks(0)
		else:
			lapPBDiff.text = IngameHUD.getTimeStringFromTicks(lapTimePB - time)
	else:
		lapPBContainer.visible = false
	
	# lapTimePB = time

	if time <= blitzTime:
		if lapTimePB > blitzTime:
			lapBeatenContainer.visible = true
			setLapMedalText(lapBeatenMedal, "Blitz")
			lapBeatenDiff.text = IngameHUD.getTimeStringFromTicks(blitzTime - time)
		else:
			lapBeatenContainer.visible = false
		animateInLapMedals(4)

	elif time <= blitzTime * MedalMenu.GOLD_MULTIPLIER:
		if lapTimePB > blitzTime * MedalMenu.GOLD_MULTIPLIER:
			lapBeatenContainer.visible = true
			setLapMedalText(lapBeatenMedal, "Gold")
			lapBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.GOLD_MULTIPLIER) - time)
		else:
			lapBeatenContainer.visible = false
		animateInLapMedals(3)

	elif time <= blitzTime * MedalMenu.SILVER_MULTIPLIER:
		if lapTimePB > blitzTime * MedalMenu.SILVER_MULTIPLIER:
			lapBeatenContainer.visible = true
			setLapMedalText(lapBeatenMedal, "Silver")
			lapBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.SILVER_MULTIPLIER) - time)
		else:
			lapBeatenContainer.visible = false
		animateInLapMedals(2)

	elif time <= blitzTime * MedalMenu.BRONZE_MULTIPLIER:
		if lapTimePB > blitzTime * MedalMenu.BRONZE_MULTIPLIER:
			lapBeatenContainer.visible = true
			setLapMedalText(lapBeatenMedal, "Bronze")
			lapBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.BRONZE_MULTIPLIER) - time)
		else:
			lapBeatenContainer.visible = false
		animateInLapMedals(1)

	else:
		lapBeatenContainer.visible = false

	if time <= lapTimePB:
		lapTimePB = time

	if lapTimePB <= blitzTime:
		lapNextContainer.visible = false
	elif lapTimePB <= blitzTime * MedalMenu.GOLD_MULTIPLIER:
		lapNextContainer.visible = true
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(blitzTime)
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - blitzTime)
	elif lapTimePB <= blitzTime * MedalMenu.SILVER_MULTIPLIER:
		lapNextContainer.visible = true
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.GOLD_MULTIPLIER))
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(blitzTime * MedalMenu.GOLD_MULTIPLIER))
	elif lapTimePB <= blitzTime * MedalMenu.BRONZE_MULTIPLIER:
		lapNextContainer.visible = true
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.SILVER_MULTIPLIER))
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(blitzTime * MedalMenu.SILVER_MULTIPLIER))
	else:
		lapNextContainer.visible = true
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.BRONZE_MULTIPLIER))
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(blitzTime * MedalMenu.BRONZE_MULTIPLIER))

func setLapMedalText(label: Label, text: String):
	label.text = text
	if text == "Blitz":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", false)
	elif text == "Gold":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", true)
		(label.material as ShaderMaterial).set_shader_parameter("TextColor", Color(1, 0.8, 0.2))
	elif text == "Silver":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", true)
		(label.material as ShaderMaterial).set_shader_parameter("TextColor", Color(0.8, 0.8, 0.8))
	elif text == "Bronze":
		(label.material as ShaderMaterial).set_shader_parameter("UseColor", true)
		(label.material as ShaderMaterial).set_shader_parameter("TextColor", Color(0.8, 0.5, 0.2))

func animateInLapMedals(nrMedals: int) -> void:
	assert(nrMedals >= 0 && nrMedals <= 4)

	bronzeLap.visible = nrMedals >= 1 || bronzeLap.visible
	silverLap.visible = nrMedals >= 2 || silverLap.visible
	goldLap.visible = nrMedals >= 3 || goldLap.visible
	blitz.visible = nrMedals >= 4 || blitz.visible