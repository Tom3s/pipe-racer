extends Control

@onready var totalTimeLabel: Label = %TotalTime
@onready var totalTimePBLabel: Label = %TotalTimePB
@onready var lapTimeLabel: Label = %LapTime
@onready var lapTimePBLabel: Label = %LapTimePB

@onready var closeButton: Button = %CloseButton
@onready var improveButton: Button = %ImproveButton

var totalTimePB: int = -1
var lapTimePB: int = -1

signal closePressed()
signal improvePressed()

func _ready():
	closeButton.pressed.connect(func():
		hide()
		closePressed.emit()
	)
	improveButton.pressed.connect(func():
		hide()
		improvePressed.emit()
	)

	visibility_changed.connect(func():
		if is_visible_in_tree():
			improveButton.grab_focus()
	)

func setNewTimes(total: int, lap: int):
	totalTimePBLabel.visible = false
	lapTimePBLabel.visible = false

	if totalTimePB == -1 || totalTimePB > total:
		totalTimePB = total
		totalTimeLabel.text = IngameHUD.getTimeStringFromTicks(total)
		totalTimePBLabel.visible = true
	if lapTimePB == -1 || lapTimePB > lap:
		lapTimePB = lap
		lapTimeLabel.text = IngameHUD.getTimeStringFromTicks(lap)
		lapTimePBLabel.visible = true
