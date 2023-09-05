extends Control
class_name EditorShortcutsUI

var editorModeSelector: ItemList
var buildModeSelector: ItemList

signal editorModeChanged(mode: int)
signal buildModeChanged(mode: int)

func _ready():
	editorModeSelector = %EditorModeSelector
	buildModeSelector = %BuildModeSelector

	editorModeSelector.select(0)
	buildModeSelector.select(0)

	editorModeChanged.emit(0)
	buildModeChanged.emit(0)

	editorModeSelector.item_selected.connect(onEditorModeSelector_itemSelected)
	buildModeSelector.item_selected.connect(onBuildModeSelector_itemSelected)

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