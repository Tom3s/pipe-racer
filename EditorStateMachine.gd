extends Node
class_name EditorStateMachine

const EDITOR_STATE_BUILD = 0
const EDITOR_STATE_EDIT = 1
const EDITOR_STATE_DELETE = 2
const EDITOR_STATE_PLAYTEST = 3

const EDITOR_BUILD_MODE_PREFAB = 0
const EDITOR_BUILD_MODE_START = 1
const EDITOR_BUILD_MODE_CHECKPOINT = 2
const EDITOR_BUILD_MODE_PROP = 3

signal buildModeChanged(buildMode: int)

var editorState: int = 0
var buildMode: int = 0:
	set(value):
		buildMode = value
		buildModeChanged.emit(buildMode)
	get:
		return buildMode

var currentPlacerNode: Node3D = null
var testing: bool = false

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

var currentSelection: Object = null

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

func inPlaytestState() -> bool:
	return editorState == EDITOR_STATE_PLAYTEST

func canBuild() -> bool:
	return mouseNotOverUI() and inBuildState()

func setEditorStateBuild() -> void:
	editorState = EDITOR_STATE_BUILD
	buildModeChanged.emit(buildMode)
	# buildMode = EDITOR_BUILD_MODE_PREFAB

func setEditorStateEdit() -> void:
	editorState = EDITOR_STATE_EDIT

func setEditorStateDelete() -> void:
	editorState = EDITOR_STATE_DELETE
	# clearSelection()

func setEditorState(state: int) -> void:
	if state == EDITOR_STATE_BUILD:
		setEditorStateBuild()
	elif state == EDITOR_STATE_EDIT:
		setEditorStateEdit()
	elif state == EDITOR_STATE_DELETE:
		setEditorStateDelete()

func setCurrentSelection(selection: Object) -> Object:

	# if selection == currentSelection:
	# 	return null

	if selection != null && !(
		selection.has_method("select") || 
		selection.has_method("isStart") || 
		selection.has_method("isCheckPoint") || 
		selection.has_method("isProp")
	):
		var oldSelection = currentSelection
		currentSelection = null

		return oldSelection

	var oldSelection = currentSelection
	currentSelection = selection

	return oldSelection

func clearSelection() -> void:
	if currentSelection != null:
		if currentSelection.has_method("deselect"):
			currentSelection.deselect()
	currentSelection = null

func prevBuildMode() -> void:
	if inBuildState():
		buildMode = (buildMode + 3) % 4

func nextBuildMode() -> void:
	if inBuildState():
		buildMode = (buildMode + 1) % 4

func inPropEditState():
	return inEditState() && currentSelection != null && currentSelection.has_method("isProp")

func canMovePreview():
	return mouseNotOverUI() && inBuildState()
