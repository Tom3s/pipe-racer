extends Node3D
class_name SceneryEditorInputHandler

var maxDistance: int = 2000


signal mouseMovedTo(worldPosition: Vector3, isPlacePressed: bool)
signal placePressed()

signal pausePressed(paused)


func _unhandled_input(_event):
	if !Input.is_action_pressed("editor_look_around"):
		mouseMovedTo.emit(screenPointToRay(), Input.is_action_pressed("editor_place"))

	if Input.is_action_just_pressed("editor_place"):
		placePressed.emit()

	if Input.is_action_just_pressed("p1_pause"):
		pausePressed.emit(true)

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