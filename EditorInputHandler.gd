extends Node3D
class_name EditorInputHandler

var maxDistance: int = 2000

const prefabSafeZone: Vector2i = Vector2i(235, 470)
const shortcutSafeZone: Vector2i = Vector2i(220, 205)
const undoRedoSafeZone: Vector2i = Vector2i(350, 50)
const prefabSelectorSafeZone: Vector2i = Vector2i(176, 0)

signal mouseMovedTo(worldPosition: Vector3)
signal moveUpGrid()
signal moveDownGrid()
signal placePressed()
signal rotatePressed()
signal fineRotatePressed(direction: int)
signal selectPressed(object: Object)
signal deleteSelectedPressed()
signal prevBuildModePressed()
signal nextBuildModePressed()

signal undoPressed()
signal redoPressed()

signal mouseEnteredUI()
signal mouseExitedUI()

signal editorModeBuildPressed()
signal editorModeEditPressed()
signal editorModeDeletePressed()

signal moveSelectionPressed(direction: Vector3)

signal savePressed()

signal pausePressed(paused)

var mousePos2D: Vector2 = Vector2()
var windowSize: Vector2 = Vector2()

var mouseOverUI: bool = false:
	set(value):
		mouseOverUI = mouseOverUIChanged(value)

var propertiesOpen: bool = false
var paused: bool = false

func _ready():
	set_physics_process(true)

func mouseOverUIChanged(value: bool) -> bool:
	if value != mouseOverUI:
		if value:
			mouseEnteredUI.emit()
		else:
			mouseExitedUI.emit()
	return value

const MOVE_REPEAT_DEFAULT_DELAY: int = 60
const MOVE_REPEAT_DEFAULT_COOLDOWN: int = 5
var moveRepeatCooldown: int = 0
var moveRepeatDelay: int = MOVE_REPEAT_DEFAULT_DELAY
# func _input(_event: InputEvent):
func _physics_process(_delta):

	if Input.is_action_just_pressed("editor_save"):
		savePressed.emit()

	# if Input.is_action_just_pressed("fullscreen"):
	# 	fullScreenPressed.emit()

	if Input.is_action_just_pressed("p1_pause"):
		# paused = !paused
		pausePressed.emit(!paused)

	if propertiesOpen || paused:
		return
	
	if !Input.is_action_pressed("editor_look_around"):
		mouseMovedTo.emit(screenPointToRay())


	if Input.is_action_just_pressed("editor_fine_rotate_left"):
		fineRotatePressed.emit(-1)
	elif Input.is_action_just_pressed("editor_grid_down"):
		moveDownGrid.emit()
	
	if Input.is_action_just_pressed("editor_fine_rotate_right"):
		fineRotatePressed.emit(+1)
	elif Input.is_action_just_pressed("editor_grid_up"):
		moveUpGrid.emit()

	if Input.is_action_just_pressed("editor_place"):
		placePressed.emit()
	if Input.is_action_just_pressed("editor_rotate_prefab"):
		rotatePressed.emit()
	# if Input.is_action_just_pressed("editor_fine_rotate_left"):
	# 	fineRotatePressed.emit(1)
	# if Input.is_action_just_pressed("editor_fine_rotate_right"):
	# 	fineRotatePressed.emit(-1)
	if Input.is_action_just_pressed("editor_select"):
		selectPressed.emit(screenPointToRaySelect())
	if Input.is_action_just_pressed("editor_delete_selected"):
		deleteSelectedPressed.emit()
	if Input.is_action_just_pressed("editor_undo"):
		undoPressed.emit()
	if Input.is_action_just_pressed("editor_redo"):
		redoPressed.emit()
	if Input.is_action_just_pressed("editor_mode_build"):
		editorModeBuildPressed.emit()
	if Input.is_action_just_pressed("editor_mode_edit"):
		editorModeEditPressed.emit()
	if Input.is_action_just_pressed("editor_mode_delete"):
		editorModeDeletePressed.emit()
	if Input.is_action_just_pressed("editor_prev_build_mode"):
		prevBuildModePressed.emit()
	if Input.is_action_just_pressed("editor_next_build_mode"):
		nextBuildModePressed.emit()
	
	# if Input.is_action_just_pressed("editor_move_selection_left"):
	# 	moveSelectionPressed.emit(Vector3.LEFT)
	# if Input.is_action_just_pressed("editor_move_selection_right"):
	# 	moveSelectionPressed.emit(Vector3.RIGHT)
	# if Input.is_action_just_pressed("editor_move_selection_forward"):
	# 	moveSelectionPressed.emit(Vector3.FORWARD)
	# if Input.is_action_just_pressed("editor_move_selection_backward"):
	# 	moveSelectionPressed.emit(Vector3.BACK)

	handleMoveSelectionInput("editor_move_selection_left", Vector3.LEFT)
	handleMoveSelectionInput("editor_move_selection_right", Vector3.RIGHT)
	handleMoveSelectionInput("editor_move_selection_forward", Vector3.FORWARD)
	handleMoveSelectionInput("editor_move_selection_backward", Vector3.BACK)
	

	windowSize = DisplayServer.window_get_size()
	mousePos2D = get_viewport().get_mouse_position()

	mouseOverUI = isMouseOverUI()

func handleMoveSelectionInput(actionName: String, direction: Vector3):
	if Input.is_action_just_pressed(actionName):
		moveSelectionPressed.emit(direction)
	elif Input.is_action_pressed(actionName):
		moveRepeatDelay -= 1
		if moveRepeatDelay <= 0:
			moveRepeatCooldown -= 1
			if moveRepeatCooldown <= 0:
				moveSelectionPressed.emit(direction)
				moveRepeatCooldown = MOVE_REPEAT_DEFAULT_COOLDOWN
	elif Input.is_action_just_released(actionName):
		moveRepeatDelay = MOVE_REPEAT_DEFAULT_DELAY

func isMouseOverUI() -> bool:
	return isMouseOverPrefabUI() || \
		isMouseOverShortcutUI() || \
		isMouseOverUndoRedoUI() || \
		isMouseOverPrefabSelectorUI()

func isMouseOverPrefabUI() -> bool:
	return mousePos2D.x > windowSize.x - prefabSafeZone.x && mousePos2D.y < prefabSafeZone.y

func isMouseOverShortcutUI() -> bool:
	return mousePos2D.x < shortcutSafeZone.x && mousePos2D.y < shortcutSafeZone.y

func isMouseOverUndoRedoUI() -> bool:
	return mousePos2D.y < undoRedoSafeZone.y && (mousePos2D.x > (windowSize.x / 2.0) - (undoRedoSafeZone.x / 2.0) && mousePos2D.x < (windowSize.x / 2.0) + (undoRedoSafeZone.x / 2.0))

func isMouseOverPrefabSelectorUI() -> bool:
	return mousePos2D.x < prefabSelectorSafeZone.x

func screenPointToRay() -> Vector3:
	var spaceState = get_world_3d().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * maxDistance
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 8))
	
	if rayArray.has("position"):
		return rayArray["position"]
	return Vector3.INF

func screenPointToRaySelect() -> Object:
	var spaceState = get_world_3d().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * maxDistance
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	
	if rayArray.has("collider"):
		return rayArray["collider"].get_parent()
	return null
