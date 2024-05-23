extends Control
class_name EditorSidebarUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var editorModeButtons: VBoxContainer = %EditorModeButtons
@onready var buildButton: Button = %BuildButton
@onready var editButton: Button = %EditButton
@onready var deleteButton: Button = %DeleteButton
@onready var paintButton: Button = %PaintButton
@onready var sceneryButton: Button = %SceneryButton

@onready var buildButtons: VBoxContainer = %BuildButtons
@onready var roadButton: Button = %RoadButton
@onready var pipeButton: Button = %PipeButton
@onready var startButton: Button = %StartButton
@onready var cpButton: Button = %CPButton
@onready var decoButton: Button = %DecoButton

@onready var visibilityButton: Button = %VisibilityButton

# out signals

signal buildModeChanged(mode: EditorEventListener.BuildMode)

signal editorModeChanged(mode: EditorEventListener.EditorMode)

func _ready():
	onEditorModeButtonPressed(0)
	onBuildButtonPressed(0)
	connectSignals()

func connectSignals():

	buildButton.pressed.connect(func():
		onEditorModeButtonPressed(EditorEventListener.EditorMode.BUILD)
	)
	editButton.pressed.connect(func():
		onEditorModeButtonPressed(EditorEventListener.EditorMode.EDIT)
	)
	deleteButton.pressed.connect(func():
		onEditorModeButtonPressed(EditorEventListener.EditorMode.DELETE)
	)
	paintButton.pressed.connect(func():
		onEditorModeButtonPressed(EditorEventListener.EditorMode.PAINT)
	)
	sceneryButton.pressed.connect(func():
		onEditorModeButtonPressed(EditorEventListener.EditorMode.SCENERY)
	)


	roadButton.pressed.connect(func():
		onBuildButtonPressed(EditorEventListener.BuildMode.ROAD)
	)
	pipeButton.pressed.connect(func():
		onBuildButtonPressed(EditorEventListener.BuildMode.PIPE)
	)
	startButton.pressed.connect(func():
		onBuildButtonPressed(EditorEventListener.BuildMode.START)
	)
	cpButton.pressed.connect(func():
		onBuildButtonPressed(EditorEventListener.BuildMode.CP)
	)
	decoButton.pressed.connect(func():
		onBuildButtonPressed(EditorEventListener.BuildMode.DECO)
	)

	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = ">" if visibilityButton.button_pressed else "<"
	)

func onBuildButtonPressed(index: int) -> void:
	roadButton.button_pressed = index == EditorEventListener.BuildMode.ROAD
	pipeButton.button_pressed = index == EditorEventListener.BuildMode.PIPE
	startButton.button_pressed = index == EditorEventListener.BuildMode.START
	cpButton.button_pressed = index == EditorEventListener.BuildMode.CP
	decoButton.button_pressed = index == EditorEventListener.BuildMode.DECO

	buildModeChanged.emit(index as EditorEventListener.BuildMode)	

func onEditorModeButtonPressed(index: int) -> void:
	buildButtons.visible = index == EditorEventListener.EditorMode.BUILD

	buildButton.button_pressed = index == EditorEventListener.EditorMode.BUILD
	editButton.button_pressed = index == EditorEventListener.EditorMode.EDIT
	deleteButton.button_pressed = index == EditorEventListener.EditorMode.DELETE
	paintButton.button_pressed = index == EditorEventListener.EditorMode.PAINT
	sceneryButton.button_pressed = index == EditorEventListener.EditorMode.SCENERY

	editorModeChanged.emit(index as EditorEventListener.EditorMode)


	