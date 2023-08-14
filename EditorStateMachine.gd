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

func mouseOverUIChanged(value: bool) -> bool:
	return value

func mouseNotOverUI() -> bool:
	return not mouseOverUI

func inBuildState() -> bool:
	return editorState == EDITOR_STATE_BUILD

func canBuild() -> bool:
	return mouseNotOverUI() and inBuildState()