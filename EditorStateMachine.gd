extends Node
class_name EditorStateMachine

const EDITOR_STATE_BUILD = 0
const EDITOR_STATE_EDIT = 1
const EDITOR_STATE_DELETE = 2

var editorState: int = 0

@export 
var GRID_MAX_HEIGHT: int = 256
@export
var GRID_MIN_HEIGHT: int = -16

var gridCurrentHeight: int = 0:
	set(value):
		gridCurrentHeight = clamp(value, GRID_MIN_HEIGHT, GRID_MAX_HEIGHT)
	get:
		return gridCurrentHeight

var mouseOverUI: bool = false:
	set(value):
		mouseOverUI = mouseOverUIChanged(value)
	get:
		return mouseOverUI

var currentSelection: PrefabProperties = null

func mouseOverUIChanged(value: bool) -> bool:
	return value

func mouseNotOverUI() -> bool:
	return not mouseOverUI

func inBuildState() -> bool:
	return editorState == EDITOR_STATE_BUILD

func inEditState() -> bool:
	return editorState == EDITOR_STATE_EDIT

func inDeleteState() -> bool:
	return editorState == EDITOR_STATE_DELETE

func canBuild() -> bool:
	return mouseNotOverUI() and inBuildState()

func setEditorStateBuild() -> void:
	if currentSelection != null:
		currentSelection.deselect()
	currentSelection = null
	editorState = EDITOR_STATE_BUILD

func setEditorStateEdit() -> void:
	editorState = EDITOR_STATE_EDIT

func setEditorStateDelete() -> void:
	editorState = EDITOR_STATE_DELETE

func setCurrentSelection(selection: Object) -> PrefabProperties:

	if selection == currentSelection:
		return null

	if !(selection.has_method("select")):
		var oldSelection = currentSelection
		currentSelection = null

		return oldSelection

	var oldSelection = currentSelection
	currentSelection = selection

	return oldSelection

func clearSelection() -> void:
	if currentSelection != null:
		currentSelection.deselect()
	currentSelection = null
