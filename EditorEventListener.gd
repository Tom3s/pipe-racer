extends Node3D

var editorInputHandler: EditorInputHandler
var prefabMesher: PrefabMesher
var editorStateMachine: EditorStateMachine
var camera: EditorCamera
var map: Map
var prefabPropertiesUI: PrefabPropertiesUI

func _ready():
	# assign nodes
	editorInputHandler = %EditorInputHandler
	prefabMesher = %PrefabGenerator/PrefabMesher
	editorStateMachine = %EditorStateMachine 
	camera = %EditorCamera
	map = %Map
	prefabPropertiesUI = %PrefabPropertiesUI

	# connect signals
	editorInputHandler.mouseMovedTo.connect(onEditorInputHandler_mouseMovedTo)
	editorInputHandler.moveUpGrid.connect(onEditorInputHandler_moveUpGrid)
	editorInputHandler.moveDownGrid.connect(onEditorInputHandler_moveDownGrid)
	editorInputHandler.placePressed.connect(onEditorInputHandler_placePressed)
	editorInputHandler.rotatePressed.connect(onEditorInputHandler_rotatePressed)
	editorInputHandler.selectPressed.connect(onEditorInputHandler_selectPressed)

	# connect prefab UI to value changes
	# PrefabPropertiesUI:
	#	signal leftEndChanged(value: float)
	#	signal rightEndChanged(value: float)
	#	signal leftStartChanged(value: float)
	#	signal rightStartChanged(value: float)
	#	signal leftSmoothingChanged(value: int)
	#	signal rightSmoothingChanged(value: int)
	#	signal curvedChanged(value: bool)
	#	signal straightLengthChanged(value: float)
	#	signal straightOffsetChanged(value: float)
	#	signal straightSmoothingChanged(value: int)
	#	signal curveForwardChanged(value: float)
	#	signal curveSidewaysChanged(value: float)
	prefabPropertiesUI.leftEndChanged.connect(onPrefabPropertiesUI_leftEndChanged)
	prefabPropertiesUI.rightEndChanged.connect(onPrefabPropertiesUI_rightEndChanged)
	prefabPropertiesUI.leftStartChanged.connect(onPrefabPropertiesUI_leftStartChanged)
	prefabPropertiesUI.rightStartChanged.connect(onPrefabPropertiesUI_rightStartChanged)
	prefabPropertiesUI.leftSmoothingChanged.connect(onPrefabPropertiesUI_leftSmoothingChanged)
	prefabPropertiesUI.rightSmoothingChanged.connect(onPrefabPropertiesUI_rightSmoothingChanged)
	prefabPropertiesUI.curvedChanged.connect(onPrefabPropertiesUI_curvedChanged)
	prefabPropertiesUI.straightLengthChanged.connect(onPrefabPropertiesUI_straightLengthChanged)
	prefabPropertiesUI.straightOffsetChanged.connect(onPrefabPropertiesUI_straightOffsetChanged)
	prefabPropertiesUI.straightSmoothingChanged.connect(onPrefabPropertiesUI_straightSmoothingChanged)
	prefabPropertiesUI.curveForwardChanged.connect(onPrefabPropertiesUI_curveForwardChanged)
	prefabPropertiesUI.curveSidewaysChanged.connect(onPrefabPropertiesUI_curveSidewaysChanged)

	editorInputHandler.mouseEnteredUI.connect(onEditorInputHandler_mouseEnteredUI)
	editorInputHandler.mouseExitedUI.connect(onEditorInputHandler_mouseExitedUI)

	editorInputHandler.undoPressed.connect(onEditorInputHandler_undoPressed)
	editorInputHandler.redoPressed.connect(onEditorInputHandler_redoPressed)

	editorInputHandler.editorModeBuildPressed.connect(onEditorInputHandler_editorModeBuildPressed)
	editorInputHandler.editorModeEditPressed.connect(onEditorInputHandler_editorModeEditPressed)
	editorInputHandler.editorModeDeletePressed.connect(onEditorInputHandler_editorModeDeletePressed)

	map.undidLastOperation.connect(onMap_undidLastOperation)
	map.redidLastOperation.connect(onMap_redidLastOperation)
	map.noOperationToBeUndone.connect(onMap_noOperationToBeUndone)
	map.noOperationToBeRedone.connect(onMap_noOperationToBeRedone)


func onEditorInputHandler_mouseMovedTo(worldMousePos: Vector3):
	if worldMousePos != Vector3.INF && editorStateMachine.mouseNotOverUI() && editorStateMachine.inBuildState():
		prefabMesher.updatePosition(worldMousePos, camera.global_position, editorStateMachine.gridCurrentHeight)
	elif editorStateMachine.mouseOverUI:
		# prefabMesher.global_position = camera.getPositionInFrontOfCamera(50)
		prefabMesher.updatePositionExact(camera.getPositionInFrontOfCamera(60))

func onEditorInputHandler_moveUpGrid():
	if editorStateMachine.mouseNotOverUI():
		editorStateMachine.gridCurrentHeight += 1
		camera.position.y += prefabMesher.GRID_SIZE

func onEditorInputHandler_moveDownGrid():
	if editorStateMachine.mouseNotOverUI():
		editorStateMachine.gridCurrentHeight -= 1	
		camera.position.y -= prefabMesher.GRID_SIZE

func onEditorInputHandler_placePressed():
	if editorStateMachine.canBuild():
		var prefab = PrefabProperties.new(prefabMesher.encodeData())
		prefab.mesh = prefabMesher.mesh
		
		map.addPrefab(prefab, prefabMesher.global_position, prefabMesher.global_rotation)

func onEditorInputHandler_rotatePressed():
	prefabMesher.rotate90()

func onEditorInputHandler_selectPressed(object: Object):
	print(object, "was ray hit with selection", object.get_class())
	if editorStateMachine.mouseNotOverUI() && editorStateMachine.inEditState():
		var oldSelection = editorStateMachine.setCurrentSelection(object)
		if object.has_method("select"):
			object.select()
			prefabPropertiesUI.setFromData(object.prefabData)
		
		if oldSelection != null:
			oldSelection.deselect()


func onPrefabPropertiesUI_leftEndChanged(value: float):
	prefabMesher.leftEndHeight = value

func onPrefabPropertiesUI_rightEndChanged(value: float):
	prefabMesher.rightEndHeight = value

func onPrefabPropertiesUI_leftStartChanged(value: float):
	prefabMesher.leftStartHeight = value

func onPrefabPropertiesUI_rightStartChanged(value: float):
	prefabMesher.rightStartHeight = value

func onPrefabPropertiesUI_leftSmoothingChanged(value: int):
	prefabMesher.leftSmoothTilt = value

func onPrefabPropertiesUI_rightSmoothingChanged(value: int):
	prefabMesher.rightSmoothTilt = value

func onPrefabPropertiesUI_curvedChanged(value: bool):
	prefabMesher.curve = value

func onPrefabPropertiesUI_straightLengthChanged(value: float):
	prefabMesher.length = value

func onPrefabPropertiesUI_straightOffsetChanged(value: float):
	prefabMesher.endOffset = value

func onPrefabPropertiesUI_straightSmoothingChanged(value: int):
	prefabMesher.smoothOffset = value

func onPrefabPropertiesUI_curveForwardChanged(value: float):
	prefabMesher.curveForward = value

func onPrefabPropertiesUI_curveSidewaysChanged(value: float):
	prefabMesher.curveSideways = value

func onEditorInputHandler_mouseEnteredUI():
	editorStateMachine.mouseOverUI = true
	# prefabMesher.global_position = camera.getPositionInFrontOfCamera(50)
	prefabMesher.updatePositionExact(camera.getPositionInFrontOfCamera(60))
	print("Mouse entered prefab properties")

func onEditorInputHandler_mouseExitedUI():
	editorStateMachine.mouseOverUI = false
	print("Mouse exited prefab properties")

func onEditorInputHandler_undoPressed():
	map.undo()

func onEditorInputHandler_redoPressed():
	map.redo()

func onMap_undidLastOperation():
	print("Undid last operation")

func onMap_redidLastOperation():
	print("Redid last operation")

func onMap_noOperationToBeUndone():
	print("No operation to be undone")

func onMap_noOperationToBeRedone():
	print("No operation to be redone")

func onEditorInputHandler_editorModeBuildPressed():
	editorStateMachine.setEditorStateBuild()
	prefabMesher.visible = true
	print("Build mode")

func onEditorInputHandler_editorModeEditPressed():
	editorStateMachine.setEditorStateEdit()
	prefabMesher.visible = false
	print("Edit mode")

func onEditorInputHandler_editorModeDeletePressed():
	editorStateMachine.setEditorStateDelete()
	prefabMesher.visible = false
	print("Delete mode")
	
