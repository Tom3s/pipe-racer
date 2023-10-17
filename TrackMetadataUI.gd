extends Control
class_name TrackMetadataUI

var trackName: LineEdit
var saveTrackNameButton: Button

var lapCount: SpinBox
var saveLapCountButton: Button

var applyButton: Button
var closeButton: Button

signal trackNameChanged(name: String)
signal lapCountChanged(count: int)
signal closePressed()
signal applyPressed(name: String, count: int)

func _ready():
	trackName = %TrackName
	saveTrackNameButton = %SaveTrackNameButton

	lapCount = %LapCount
	saveLapCountButton = %SaveLapCountButton

	applyButton = %ApplyButton
	closeButton = %CloseButton

	connectSignals()

func connectSignals():
	saveTrackNameButton.pressed.connect(onSaveTrackNameButton_pressed)
	saveLapCountButton.pressed.connect(onSaveLapCountButton_pressed)
	applyButton.pressed.connect(onApplyButton_pressed)
	closeButton.pressed.connect(onCloseButton_pressed)


func onSaveTrackNameButton_pressed():
	trackNameChanged.emit(trackName.text)
	saveTrackNameButton.disabled = true
	await get_tree().create_timer(1.0).timeout
	saveTrackNameButton.disabled = false

func onSaveLapCountButton_pressed():
	lapCountChanged.emit(lapCount.value)
	saveLapCountButton.disabled = true
	await get_tree().create_timer(1.0).timeout
	saveLapCountButton.disabled = false

func onApplyButton_pressed():
	# onSaveTrackNameButton_pressed()
	# onSaveLapCountButton_pressed()
	visible = false
	applyPressed.emit(trackName.text, lapCount.value)

func onCloseButton_pressed():
	visible = false
	closePressed.emit()

func setFromData(data: Dictionary):
	trackName.text = data["trackName"]
	lapCount.value = data["lapCount"]