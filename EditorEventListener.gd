extends Node3D

var editorInputHandler: EditorInputHandler
var prefabMesher: PrefabMesher
var editorStateMachine: EditorStateMachine
var camera: EditorCamera
var map: Map

func _ready():
	# assign nodes
	editorInputHandler = %EditorInputHandler
	prefabMesher = %PrefabGenerator/PrefabMesher
	editorStateMachine = %EditorStateMachine 
	camera = %EditorCamera
	map = %Map

	# connect signals
	editorInputHandler.mouseMovedTo.connect(onEditorInputHandler_mouseMovedTo)
	editorInputHandler.moveUpGrid.connect(onEditorInputHandler_moveUpGrid)
	editorInputHandler.moveDownGrid.connect(onEditorInputHandler_moveDownGrid)
	editorInputHandler.placePressed.connect(onEditorInputHandler_placePressed)
	editorInputHandler.rotatePressed.connect(onEditorInputHandler_rotatePressed)


func onEditorInputHandler_mouseMovedTo(worldMousePos: Vector3):
	if worldMousePos != Vector3.INF:
		prefabMesher.updatePosition(worldMousePos, camera.global_position, editorStateMachine.gridCurrentHeight)

func onEditorInputHandler_moveUpGrid():
	editorStateMachine.gridCurrentHeight += 1
	camera.position.y += prefabMesher.GRID_SIZE

func onEditorInputHandler_moveDownGrid():
	editorStateMachine.gridCurrentHeight -= 1	
	camera.position.y -= prefabMesher.GRID_SIZE

func onEditorInputHandler_placePressed():
	var prefab = PrefabProperties.new(prefabMesher.encodeData())
	prefab.mesh = prefabMesher.mesh
	
	map.addPrefab(prefab, prefabMesher.global_position, prefabMesher.global_rotation)

func onEditorInputHandler_rotatePressed():
	prefabMesher.rotate90()
