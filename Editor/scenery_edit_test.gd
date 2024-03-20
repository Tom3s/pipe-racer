extends Node3D

@onready var editorInputHandler: EditorInputHandler = %EditorInputHandler
@onready var scenery: EditableScenery = %EditableScenery

var lastVertexIndex: Vector2i = Vector2i(-1, -1)

func _ready():
	editorInputHandler.mouseMovedTo.connect(func(pos: Vector3):
		if pos != Vector3.INF:
			print("Mouse moved to: ", pos)
			print("Closest vertex: ", scenery.getClosestVertex(pos))
			lastVertexIndex = scenery.getClosestVertex(pos)
		else:
			lastVertexIndex = Vector2i(-1, -1)
	)

	editorInputHandler.moveUpGrid.connect(func():
		if lastVertexIndex != Vector2i(-1, -1):
			scenery.moveVertex(lastVertexIndex, 1)
	)

	editorInputHandler.moveDownGrid.connect(func():
		if lastVertexIndex != Vector2i(-1, -1):
			scenery.moveVertex(lastVertexIndex, -1)
	)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
