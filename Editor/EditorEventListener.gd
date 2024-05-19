extends Node
class_name EditorEventListener

@onready var inputHandler: EditorInputHandler = %EditorInputHandler
@onready var camera: EditorCamera = %EditorCamera
@onready var previewElementParent: Node3D = %PreviewElement

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
