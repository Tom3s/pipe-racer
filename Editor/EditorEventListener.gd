extends Node3D
class_name EditorEventListener

@onready var inputHandler: EditorInputHandler = %EditorInputHandler
@onready var camera: EditorCamera = %EditorCamera
@onready var previewElementParent: Node3D = %PreviewElement
@onready var map: InteractiveMap = %InteractiveMap

func _ready():
	connectSignals()

func connectSignals():
	inputHandler.mouseMovedTo.connect(func(worldPos: Vector3):
		if worldPos == Vector3.INF:
			return
		
		var currentElement = previewElementParent.get_child(0)
		if currentElement == null:
			return

		currentElement.global_position = worldPos
	)

	inputHandler.moveUpGrid.connect(func():
		camera.global_position += Vector3.UP * PrefabConstants.GRID_SIZE
	)

	inputHandler.moveDownGrid.connect(func():
		camera.global_position += Vector3.DOWN * PrefabConstants.GRID_SIZE
	)

	inputHandler.rotatePressed.connect(func(axis: Vector3, angle: float):
		var currentElement = previewElementParent.get_child(0)
		if currentElement == null:
			return

		# currentElement.rotate(axis, angle)
		if axis == Vector3.UP:
			currentElement.global_rotation.y += angle
		elif axis == Vector3.RIGHT:
			currentElement.global_rotation.x += angle
		elif axis == Vector3.FORWARD:
			currentElement.global_rotation.z += angle
		
		currentElement.global_rotation = currentElement.global_rotation.snapped(Vector3.ONE * deg_to_rad(5))
	)
	inputHandler.resetRotationPressed.connect(func():
		var currentElement = previewElementParent.get_child(0)
		if currentElement == null:
			return

		currentElement.global_rotation = Vector3.ZERO
	)

	inputHandler.placePressed.connect(func():
		var currentElement = previewElementParent.get_child(0)
		if currentElement == null:
			return

		if currentElement.has_method("getCopy"):
			var collidedObject = screenPointToRay()
			if collidedObject != null: # && map.lastRoadElement == null:
				collidedObject = collidedObject.get_parent()
				print("[EditorEventListener.gd] collidedObject: ", collidedObject)

				if collidedObject.has_method("getCopy"):
					currentElement.global_position = collidedObject.global_position
					currentElement.global_rotation = collidedObject.global_rotation


			var newElement = currentElement.getCopy()
			map.addRoadNode(newElement, currentElement.global_position, currentElement.global_rotation)
	)

	map.roadPreviewElementRequested.connect(func():
		map.onRoadPreviewElementProvided(previewElementParent.get_child(0))
	)

var maxRaycastDistance: int = 2000

func screenPointToRay() -> Node3D:
	var spaceState = get_world_3d().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * maxRaycastDistance
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	
	if rayArray.has("collider"):
		return rayArray["collider"]
	return null