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

