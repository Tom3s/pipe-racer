extends Node3D
class_name RotatorInputHandler

var maxDistance: int = 2000

@onready var rotator: Rotator = %Rotator

signal clickStarted(node: Node3D)
signal clickEnded()

signal mouseMovedOnScreen(newPos: Vector2)

func _unhandled_input(_event):
	if !Input.is_action_pressed("editor_look_around") && Input.is_action_pressed("editor_place"):
		# mouseMovedTo.emit(screenPointToRay(), Input.is_action_pressed("editor_place"))
		mouseMovedOnScreen.emit(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("editor_place"):
		clickStarted.emit(screenPointToRay())
	elif Input.is_action_just_released("editor_place"):
		clickEnded.emit()

	if Input.is_action_just_pressed("p1_pause"):
		rotator.setRotation(Vector3.ZERO)



func screenPointToRay() -> Node3D:
	var spaceState = get_world_3d().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * maxDistance
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	
	if rayArray.has("collider"):
		return rayArray["collider"]
	return null