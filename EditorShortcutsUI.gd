extends Control
class_name EditorShortcutsUI

var editorModeSelector: ItemList
var buildModeSelector: ItemList

var propertiesButton: Button
var saveButton: Button
var undoButton: Button
var redoButton: Button
var testButton: Button

signal editorModeChanged(mode: int)
signal buildModeChanged(mode: int)
signal propertiesPressed()
signal savePressed()
signal undoPressed()
signal redoPressed()
signal testPressed()

func _ready():
	editorModeSelector = %EditorModeSelector
	buildModeSelector = %BuildModeSelector
	propertiesButton = %PropertiesButton
	saveButton = %SaveButton
	undoButton = %UndoButton
	redoButton = %RedoButton
	testButton = %TestButton

	editorModeSelector.select(0)
	buildModeSelector.select(0)

	editorModeChanged.emit(0)
	buildModeChanged.emit(0)

	editorModeSelector.item_selected.connect(onEditorModeSelector_itemSelected)
	buildModeSelector.item_selected.connect(onBuildModeSelector_itemSelected)
	propertiesButton.pressed.connect(onPropertiesButton_pressed)
	saveButton.pressed.connect(onSaveButton_pressed)
	undoButton.pressed.connect(onUndoButton_pressed)
	redoButton.pressed.connect(onRedoButton_pressed)
	testButton.pressed.connect(onTestButton_pressed)

func onEditorModeSelector_itemSelected(index: int):
	editorModeChanged.emit(index)
	buildModeSelector.visible = false
	if index == 0:
		buildModeSelector.select(0)
		buildModeChanged.emit(0)
		buildModeSelector.visible = true
	

func onBuildModeSelector_itemSelected(index: int):
	buildModeChanged.emit(index)

func changeBuildMode(mode: int):
	buildModeSelector.select(mode)

func changeEditorMode(mode: int):
	editorModeSelector.select(mode)

func onPropertiesButton_pressed():
	propertiesPressed.emit()

func onSaveButton_pressed():
	savePressed.emit()

func onUndoButton_pressed():
	undoPressed.emit()

func onRedoButton_pressed():
	redoPressed.emit()

func setUndoEnabled(enabled: bool):
	undoButton.disabled = !enabled

func setRedoEnabled(enabled: bool):
	redoButton.disabled = !enabled

func onTestButton_pressed():
	testPressed.emit()
