extends Node3D
class_name EditorInputHandler

var maxDistance: int = 2000

signal mouseMovedTo(worldPosition: Vector3)
signal moveUpGrid()
signal moveDownGrid()

func _input(event):
	if !Input.is_action_pressed("editor_look_around"):
		mouseMovedTo.emit(screenPointToRay())

	if Input.is_action_just_pressed("editor_grid_up"):
		moveUpGrid.emit()
	if Input.is_action_just_pressed("editor_grid_down"):
		moveDownGrid.emit()

func screenPointToRay() -> Vector3:
	var spaceState = get_world_3d().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * maxDistance
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	
	if rayArray.has("position"):
		return rayArray["position"]
	return Vector3.INF