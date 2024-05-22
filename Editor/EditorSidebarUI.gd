extends Control
class_name EditorSidebarUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var roadButton: Button = %RoadButton
@onready var pipeButton: Button = %PipeButton
@onready var startButton: Button = %StartButton
@onready var cpButton: Button = %CPButton
@onready var decoButton: Button = %DecoButton

@onready var visibilityButton: Button = %VisibilityButton

# out signals

signal buildModeChanged(mode: EditorEventListener.BuildMode)

func _ready():
	onButtonPressed(0)
	connectSignals()

func connectSignals():
	roadButton.pressed.connect(func():
		onButtonPressed(0)
	)
	pipeButton.pressed.connect(func():
		onButtonPressed(1)
	)
	startButton.pressed.connect(func():
		onButtonPressed(2)
	)
	cpButton.pressed.connect(func():
		onButtonPressed(3)
	)
	decoButton.pressed.connect(func():
		onButtonPressed(4)
	)

	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = ">" if visibilityButton.button_pressed else "<"
	)

func onButtonPressed(index: int) -> void:
	roadButton.button_pressed = index == 0
	pipeButton.button_pressed = index == 1
	startButton.button_pressed = index == 2
	cpButton.button_pressed = index == 3
	decoButton.button_pressed = index == 4

	buildModeChanged.emit(index as EditorEventListener.BuildMode)	