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


# SFX

@onready var clickSFX: AudioStreamPlayer = %ClickSFX

@onready var specialMedalSFX: AudioStreamPlayer = %SpecialMedalSFX
@onready var goldMedalSFX: AudioStreamPlayer = %GoldMedalSFX
@onready var silverMedalSFX: AudioStreamPlayer = %SilverMedalSFX
@onready var bronzeMedalSFX: AudioStreamPlayer = %BronzeMedalSFX

# Buttons

@onready var closeButton: Button = %CloseButton
@onready var restartButton: Button = %RestartButton
@onready var leaderboardButton: Button = %LeaderboardButton

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
var currentTime: int = 0

@export
var currentLap: int = 0

signal closePressed()
signal restartPressed()
signal leaderboardPressed()

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

	totalBeatenMedal.material = totalBeatenMedal.material.duplicate()
	lapBeatenMedal.material = lapBeatenMedal.material.duplicate()

	closeButton.pressed.connect(func():
		hide()
		closePressed.emit()
	)
		
	restartButton.pressed.connect(func():
		hide()
		restartPressed.emit()
	)
		
	leaderboardButton.pressed.connect(func():
		hide()
		leaderboardPressed.emit()
	)

	visibility_changed.connect(func():
		if visible && is_visible_in_tree(): 
			restartButton.grab_focus()
	)

	set_physics_process(true)

func setup(initChronoTime: int, initBlitzTime: int, initTotalTimePB: int, initLapTimePB: int) -> void:
	chronoTime = initChronoTime
	blitzTime = initBlitzTime
	totalTimePB = initTotalTimePB
	lapTimePB = initLapTimePB

	totalPBContainer.visible = false
	totalBeatenContainer.visible = false
	totalNextContainer.visible = false
	totalPlacementContainer.visible = true

	totalPlacement.text = "N/A"

	lapPBContainer.visible = false
	lapBeatenContainer.visible = false
	lapNextContainer.visible = false
	lapPlacementContainer.visible = true

	setMedalsNoAnim()	

# func _physics_process(delta: float) -> void:
# 	if Input.is_action_just_pressed("replay_pause"):
# 		currentTime += 4
# 		currentTime %= times.size()
# 		setTotalTimePB(times[currentTime])

# 		currentLap += 3
# 		currentLap %= laptimes.size()
# 		setLapTimePB(laptimes[currentLap])

const LABEL_ANIMATION_TIME = 0.2

signal totalLabelAnimationFinished()
var inLabelAnimation: bool = false

func setTotalTimePB(time: int) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	if totalTimePB == 9223372036854775807 || time <= totalTimePB:
		totalPBContainer.visible = true
		totalPBContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(totalPBContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)
		inLabelAnimation = true

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
			totalBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(totalBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)

			inLabelAnimation = true
			setTotalMedalText(totalBeatenMedal, "Chrono")
			totalBeatenDiff.text = IngameHUD.getTimeStringFromTicks(chronoTime - time)
		else:
			totalBeatenContainer.visible = false
		animateInTotalMedals(4)
		

	elif time <= chronoTime * MedalMenu.GOLD_MULTIPLIER:
		if totalTimePB > chronoTime * MedalMenu.GOLD_MULTIPLIER:
			totalBeatenContainer.visible = true
			totalBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(totalBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)

			inLabelAnimation = true
			setTotalMedalText(totalBeatenMedal, "Gold")
			totalBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.GOLD_MULTIPLIER) - time)
		else:
			totalBeatenContainer.visible = false
		animateInTotalMedals(3)


	elif time <= chronoTime * MedalMenu.SILVER_MULTIPLIER:
		if totalTimePB > chronoTime * MedalMenu.SILVER_MULTIPLIER:
			totalBeatenContainer.visible = true
			totalBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(totalBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)

			inLabelAnimation = true
			setTotalMedalText(totalBeatenMedal, "Silver")
			totalBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.SILVER_MULTIPLIER) - time)
		else:
			totalBeatenContainer.visible = false
		animateInTotalMedals(2)

	elif time <= chronoTime * MedalMenu.BRONZE_MULTIPLIER:
		if totalTimePB > chronoTime * MedalMenu.BRONZE_MULTIPLIER:
			totalBeatenContainer.visible = true
			totalBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(totalBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)

			inLabelAnimation = true
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
		totalNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(totalNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)

		inLabelAnimation = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(chronoTime)
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - chronoTime)
	elif totalTimePB <= chronoTime * MedalMenu.SILVER_MULTIPLIER:
		totalNextContainer.visible = true
		totalNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(totalNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)

		inLabelAnimation = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.GOLD_MULTIPLIER))
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(chronoTime * MedalMenu.GOLD_MULTIPLIER))
	elif totalTimePB <= chronoTime * MedalMenu.BRONZE_MULTIPLIER:
		totalNextContainer.visible = true
		totalNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(totalNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)

		inLabelAnimation = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.SILVER_MULTIPLIER))
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(chronoTime * MedalMenu.SILVER_MULTIPLIER))
	else:
		totalNextContainer.visible = true
		totalNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(totalNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)

		inLabelAnimation = true
		totalNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(chronoTime * MedalMenu.BRONZE_MULTIPLIER))
		totalNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(chronoTime * MedalMenu.BRONZE_MULTIPLIER))
	
	totalPlacementContainer.modulate = Color(1, 1, 1, 0)
	inLabelAnimation = true
	tween.tween_property(totalPlacementContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
	tween.tween_callback(playClickSFX)
	tween.chain().finished.connect(func():
		inLabelAnimation = false
		totalLabelAnimationFinished.emit()
	)

	# tween.finished.connect(func():
	# 	inLabelAnimation = false
	# 	totalLabelAnimationFinished.emit()
	# )


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

const MEDAL_ANIMATION_TIME = 0.6
const MEDAL_ANIMATION_SCALE = Vector2(1.5, 1.5)

signal totalAnimationFinished()
var inAnimation: bool = false

func animateInTotalMedals(nrMedals: int) -> void:
	assert(nrMedals >= 0 && nrMedals <= 4)

	if !is_visible_in_tree():
		setMedalsNoAnim()
		return

	if nrMedals >= 1:
		var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)

		if nrMedals >= 1 && !bronzeTotal.visible:
			inAnimation = true
			tween.chain().tween_callback(bronzeMedalSFX.play)
			tween.tween_property(bronzeTotal, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(bronzeTotal, "visible", true, 0.0)
			tween.tween_property(bronzeTotal, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)
		if nrMedals >= 2 && !silverTotal.visible:
			inAnimation = true
			tween.chain().tween_callback(silverMedalSFX.play)
			tween.chain().tween_property(silverTotal, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(silverTotal, "visible", true, 0.0)
			tween.tween_property(silverTotal, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)
		if nrMedals >= 3 && !goldTotal.visible:
			inAnimation = true
			tween.chain().tween_callback(goldMedalSFX.play)
			tween.chain().tween_property(goldTotal, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(goldTotal, "visible", true, 0.0)
			tween.tween_property(goldTotal, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)
		if nrMedals >= 4 && !chrono.visible:
			inAnimation = true
			tween.chain().tween_callback(specialMedalSFX.play)
			tween.chain().tween_property(chrono, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(chrono, "visible", true, 0.0)
			tween.tween_property(chrono, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)
		tween.chain().finished.connect(func():
			inAnimation = false
			totalAnimationFinished.emit()
		)




func setLapTimePB(time: int) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	if inLabelAnimation:
		await totalLabelAnimationFinished
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


	if lapTimePB == 9223372036854775807 || time <= lapTimePB:
		lapPBContainer.visible = true
		lapPBContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(lapPBContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)

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
			lapBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(lapBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)
			setLapMedalText(lapBeatenMedal, "Blitz")
			lapBeatenDiff.text = IngameHUD.getTimeStringFromTicks(blitzTime - time)
		else:
			lapBeatenContainer.visible = false
		animateInLapMedals(4)

	elif time <= blitzTime * MedalMenu.GOLD_MULTIPLIER:
		if lapTimePB > blitzTime * MedalMenu.GOLD_MULTIPLIER:
			lapBeatenContainer.visible = true
			lapBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(lapBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)
			setLapMedalText(lapBeatenMedal, "Gold")
			lapBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.GOLD_MULTIPLIER) - time)
		else:
			lapBeatenContainer.visible = false
		animateInLapMedals(3)

	elif time <= blitzTime * MedalMenu.SILVER_MULTIPLIER:
		if lapTimePB > blitzTime * MedalMenu.SILVER_MULTIPLIER:
			lapBeatenContainer.visible = true
			lapBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(lapBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)
			setLapMedalText(lapBeatenMedal, "Silver")
			lapBeatenDiff.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.SILVER_MULTIPLIER) - time)
		else:
			lapBeatenContainer.visible = false
		animateInLapMedals(2)

	elif time <= blitzTime * MedalMenu.BRONZE_MULTIPLIER:
		if lapTimePB > blitzTime * MedalMenu.BRONZE_MULTIPLIER:
			lapBeatenContainer.visible = true
			lapBeatenContainer.modulate = Color(1, 1, 1, 0)
			tween.tween_property(lapBeatenContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
			tween.tween_callback(playClickSFX)
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
		lapNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(lapNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(blitzTime)
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - blitzTime)
	elif lapTimePB <= blitzTime * MedalMenu.SILVER_MULTIPLIER:
		lapNextContainer.visible = true
		lapNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(lapNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.GOLD_MULTIPLIER))
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(blitzTime * MedalMenu.GOLD_MULTIPLIER))
	elif lapTimePB <= blitzTime * MedalMenu.BRONZE_MULTIPLIER:
		lapNextContainer.visible = true
		lapNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(lapNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.SILVER_MULTIPLIER))
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(blitzTime * MedalMenu.SILVER_MULTIPLIER))
	else:
		lapNextContainer.visible = true
		lapNextContainer.modulate = Color(1, 1, 1, 0)
		tween.tween_property(lapNextContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
		tween.tween_callback(playClickSFX)
		lapNextMedal.text = IngameHUD.getTimeStringFromTicks(floori(blitzTime * MedalMenu.BRONZE_MULTIPLIER))
		lapNextDiff.text = IngameHUD.getTimeStringFromTicks(time - floori(blitzTime * MedalMenu.BRONZE_MULTIPLIER))
	
	lapPlacementContainer.modulate = Color(1, 1, 1, 0)
	tween.tween_property(lapPlacementContainer, "modulate", Color(1, 1, 1, 1), LABEL_ANIMATION_TIME)
	tween.tween_callback(playClickSFX)

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

	if !is_visible_in_tree():
		setMedalsNoAnim()
		return

	if nrMedals >= 1:
		if inAnimation:
			await totalAnimationFinished

		var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)

		if nrMedals >= 1 && !bronzeLap.visible:
			tween.chain().tween_callback(bronzeMedalSFX.play)
			tween.tween_property(bronzeLap, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(bronzeLap, "visible", true, 0.0)
			tween.tween_property(bronzeLap, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)
		if nrMedals >= 2 && !silverLap.visible:
			tween.chain().tween_callback(silverMedalSFX.play)
			tween.chain().tween_property(silverLap, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(silverLap, "visible", true, 0.0)
			tween.tween_property(silverLap, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)
		if nrMedals >= 3 && !goldLap.visible:
			tween.chain().tween_callback(goldMedalSFX.play)
			tween.chain().tween_property(goldLap, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(goldLap, "visible", true, 0.0)
			tween.tween_property(goldLap, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)
		if nrMedals >= 4 && !blitz.visible:
			tween.chain().tween_callback(specialMedalSFX.play)
			tween.chain().tween_property(blitz, "scale", Vector2(1.0, 1.0), MEDAL_ANIMATION_TIME).from(MEDAL_ANIMATION_SCALE).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(blitz, "visible", true, 0.0)
			tween.tween_property(blitz, "modulate", Color(1, 1, 1, 1), MEDAL_ANIMATION_TIME).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_EXPO)


func setMedalsNoAnim():
	bronzeTotal.visible = totalTimePB <= chronoTime * MedalMenu.BRONZE_MULTIPLIER
	silverTotal.visible = totalTimePB <= chronoTime * MedalMenu.SILVER_MULTIPLIER
	goldTotal.visible = totalTimePB <= chronoTime * MedalMenu.GOLD_MULTIPLIER
	chrono.visible = totalTimePB <= chronoTime

	bronzeLap.visible = lapTimePB <= blitzTime * MedalMenu.BRONZE_MULTIPLIER
	silverLap.visible = lapTimePB <= blitzTime * MedalMenu.SILVER_MULTIPLIER
	goldLap.visible = lapTimePB <= blitzTime * MedalMenu.GOLD_MULTIPLIER
	blitz.visible = lapTimePB <= blitzTime

func playClickSFX() -> void:
	if is_visible_in_tree():
		clickSFX.play()