extends Node3D
class_name EditorInputHandler

var maxDistance: int = 2000

const prefabSafeZone: Vector2i = Vector2i(235, 400)

signal mouseMovedTo(worldPosition: Vector3)
signal moveUpGrid()
signal moveDownGrid()
signal placePressed()
signal rotatePressed()

signal undoPressed()
signal redoPressed()

signal mouseEnteredUI()
signal mouseExitedUI()

var mousePos: Vector2 = Vector2()
var windowSize: Vector2 = Vector2()

var mouseOverUI: bool = false:
	set(value):
		mouseOverUI = mouseOverUIChanged(value)

func mouseOverUIChanged(value: bool) -> bool:
	if value != mouseOverUI:
		if value:
			mouseEnteredUI.emit()
		else:
			mouseExitedUI.emit()
	return value

func _input(event):
	if !Input.is_action_pressed("editor_look_around"):
		mouseMovedTo.emit(screenPointToRay())

	if Input.is_action_just_pressed("editor_grid_up"):
		moveUpGrid.emit()
	if Input.is_action_just_pressed("editor_grid_down"):
		moveDownGrid.emit()
	if Input.is_action_just_pressed("editor_place"):
		placePressed.emit()
	if Input.is_action_just_pressed("editor_rotate_prefab"):
		rotatePressed.emit()
	if Input.is_action_just_pressed("editor_undo"):
		undoPressed.emit()
	if Input.is_action_just_pressed("editor_redo"):
		redoPressed.emit()


	windowSize = DisplayServer.window_get_size()
	mousePos = get_viewport().get_mouse_position()

	if mousePos.x > windowSize.x - prefabSafeZone.x && mousePos.y < prefabSafeZone.y:
		mouseOverUI = true
	else:
		mouseOverUI = false


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

