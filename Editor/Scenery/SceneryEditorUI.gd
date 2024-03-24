extends Control
class_name SceneryEditorUI

@onready var normalModeButton: Button = %NormalModeButton
@onready var flattenModeButton: Button = %FlattenModeButton

@onready var raiseButton: Button = %RaiseButton
@onready var lowerButton: Button = %LowerButton

@onready var brushSizeSpinbox: SpinBox = %BrushSizeSpinbox
@onready var brushSizeSlider: HSlider = %BrushSizeSlider

@onready var timeSpinbox: SpinBox = %TimeSpinbox
@onready var timeSlider: HSlider = %TimeSlider


const NORMAL_MODE: int = 0
const FLATTEN_MODE: int = 1

signal modeChanged(mode: int)

signal directionChanged(direction: int)

signal brushSizeChanged(size: int)

signal timeChanged(time: float)

func _ready():
	normalModeButton.pressed.connect(func():
		modeChanged.emit(NORMAL_MODE)
		flattenModeButton.button_pressed = false
		normalModeButton.button_pressed = true
	)

	flattenModeButton.pressed.connect(func():
		modeChanged.emit(FLATTEN_MODE)
		normalModeButton.button_pressed = false
		flattenModeButton.button_pressed = true
	)

	raiseButton.pressed.connect(func():
		directionChanged.emit(1)
		raiseButton.button_pressed = true
		lowerButton.button_pressed = false
	)

	lowerButton.pressed.connect(func():
		directionChanged.emit(-1)
		raiseButton.button_pressed = false
		lowerButton.button_pressed = true
	)

	brushSizeSpinbox.value_changed.connect(func(value: float):
		brushSizeChanged.emit(int(value))
		brushSizeSlider.set_value_no_signal(value)
	)

	brushSizeSlider.value_changed.connect(func(value: float):
		brushSizeChanged.emit(int(value))
		brushSizeSpinbox.set_value_no_signal(value)
	)

	timeSlider.value_changed.connect(func(value: float):
		timeChanged.emit(value)
		timeSpinbox.set_value_no_signal(value)
	)

	timeSpinbox.value_changed.connect(func(value: float):
		timeChanged.emit(value)
		timeSlider.set_value_no_signal(value)
	)


