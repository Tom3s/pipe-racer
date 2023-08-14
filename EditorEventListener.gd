extends Node3D

var editorInputHandler: EditorInputHandler
var prefabMesher: PrefabMesher
var editorStateMachine: EditorStateMachine
var camera: EditorCamera

func _ready():
	# assign nodes
	editorInputHandler = %EditorInputHandler
	prefabMesher = %PrefabGenerator/PrefabMesher
	editorStateMachine = %EditorStateMachine 
	camera = %EditorCamera

	# connect signals
	editorInputHandler.mouseMovedTo.connect(onEditorInputHandler_mouseMovedTo)
	editorInputHandler.moveUpGrid.connect(onEditorInputHandler_moveUpGrid)
	editorInputHandler.moveDownGrid.connect(onEditorInputHandler_moveDownGrid)


func onEditorInputHandler_mouseMovedTo(worldMousePos: Vector3):
	if worldMousePos != Vector3.INF:
		prefabMesher.updatePosition(worldMousePos, camera.global_position, editorStateMachine.gridCurrentHeight)

func onEditorInputHandler_moveUpGrid():
	editorStateMachine.gridCurrentHeight += 1
	camera.position.y += prefabMesher.GRID_SIZE

func onEditorInputHandler_moveDownGrid():
	editorStateMachine.gridCurrentHeight -= 1	
	camera.position.y -= prefabMesher.GRID_SIZE
