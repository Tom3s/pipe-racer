extends Node3D

@onready var editorInputHandler: EditorInputHandler = %EditorInputHandler
@onready var scenery: EditableScenery = %EditableScenery

var lastVertexIndex: Vector2i = Vector2i(-1, -1)

@export_range(1, 15, 1)
var selectionSize: int = 1

var carCamera: FollowingCamera

var state: bool = false

func _ready():
	editorInputHandler.mouseMovedTo.connect(func(pos: Vector3):
		if pos != Vector3.INF:
			lastVertexIndex = scenery.getClosestVertex(pos)
			scenery.setSelection(true, lastVertexIndex, selectionSize)
		else:
			lastVertexIndex = Vector2i(-1, -1)
			scenery.setSelection(false, lastVertexIndex, selectionSize)
	)

	editorInputHandler.moveUpGrid.connect(func():
		if lastVertexIndex != Vector2i(-1, -1):
			scenery.moveVertex(lastVertexIndex, 1, selectionSize)
	)

	editorInputHandler.moveDownGrid.connect(func():
		if lastVertexIndex != Vector2i(-1, -1):
			scenery.moveVertex(lastVertexIndex, -1, selectionSize)
	)

	# %CarCamera.setup(%Car)
	carCamera = FollowingCamera.new(%Car)
	add_child(carCamera)
	
	editorInputHandler.pausePressed.connect(func(_paused):
		state = !state
		if state:
			carCamera.current = true
			%Car.state.hasControl = true
			%Car.state.isReady = true
		else:
			%Camera3D.current = true
			%Car.state.hasControl = false
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
