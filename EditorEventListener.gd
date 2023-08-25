extends Node3D

var editorInputHandler: EditorInputHandler
var prefabMesher: PrefabMesher
var editorStateMachine: EditorStateMachine
var camera: EditorCamera
var map: Map
var prefabPropertiesUI: PrefabPropertiesUI
var propPlacer: PropPlacer

func _ready():
	# assign nodes
	editorInputHandler = %EditorInputHandler
	prefabMesher = %PrefabGenerator/PrefabMesher
	editorStateMachine = %EditorStateMachine 
	camera = %EditorCamera
	map = %Map
	prefabPropertiesUI = %PrefabPropertiesUI
	propPlacer = %PropPlacer

	propPlacer.startLinePreview.visible = false

	editorStateMachine.buildMode = editorStateMachine.EDITOR_BUILD_MODE_PREFAB
	editorStateMachine.currentPlacerNode = prefabMesher


	# connect signals
	editorInputHandler.mouseMovedTo.connect(onEditorInputHandler_mouseMovedTo)
	editorInputHandler.moveUpGrid.connect(onEditorInputHandler_moveUpGrid)
	editorInputHandler.moveDownGrid.connect(onEditorInputHandler_moveDownGrid)
	editorInputHandler.placePressed.connect(onEditorInputHandler_placePressed)
	editorInputHandler.rotatePressed.connect(onEditorInputHandler_rotatePressed)
	editorInputHandler.fineRotatePressed.connect(onEditorInputHandler_fineRotatePressed)
	editorInputHandler.selectPressed.connect(onEditorInputHandler_selectPressed)
	editorInputHandler.deleteSelectedPressed.connect(onEditorInputHandler_deleteSelectedPressed)

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
	prefabPropertiesUI.roadTypeChanged.connect(onPrefabPropertiesUI_roadTypeChanged)

	editorInputHandler.mouseEnteredUI.connect(onEditorInputHandler_mouseEnteredUI)
	editorInputHandler.mouseExitedUI.connect(onEditorInputHandler_mouseExitedUI)

	editorInputHandler.undoPressed.connect(onEditorInputHandler_undoPressed)
	editorInputHandler.redoPressed.connect(onEditorInputHandler_redoPressed)

	editorInputHandler.editorModeBuildPressed.connect(onEditorInputHandler_editorModeBuildPressed)
	editorInputHandler.editorModeEditPressed.connect(onEditorInputHandler_editorModeEditPressed)
	editorInputHandler.editorModeDeletePressed.connect(onEditorInputHandler_editorModeDeletePressed)

	editorInputHandler.prevBuildModePressed.connect(onEditorInputHandler_prevBuildModePressed)
	editorInputHandler.nextBuildModePressed.connect(onEditorInputHandler_nextBuildModePressed)

	editorInputHandler.savePressed.connect(onEditorInputHandler_savePressed)

	editorStateMachine.buildModeChanged.connect(onEditorStateMachine_buildModeChanged)

	map.undidLastOperation.connect(onMap_undidLastOperation)
	map.redidLastOperation.connect(onMap_redidLastOperation)
	map.noOperationToBeUndone.connect(onMap_noOperationToBeUndone)
	map.noOperationToBeRedone.connect(onMap_noOperationToBeRedone)


func onEditorInputHandler_mouseMovedTo(worldMousePos: Vector3):
	var currentPlacerNode = editorStateMachine.currentPlacerNode
	if worldMousePos != Vector3.INF && editorStateMachine.canMovePreview():
		currentPlacerNode.updatePosition(worldMousePos, camera.global_position, editorStateMachine.gridCurrentHeight)
	elif editorStateMachine.mouseOverUI && editorStateMachine.inBuildState():
		currentPlacerNode.updatePositionExactCentered(camera.getPositionInFrontOfCamera(60))

func onEditorInputHandler_moveUpGrid():
	if editorStateMachine.canMovePreview():
		editorStateMachine.gridCurrentHeight += 1
		camera.position.y += prefabMesher.GRID_SIZE
	elif editorStateMachine.mouseNotOverUI() && editorStateMachine.inEditState():
		var currentPlacerNode = editorStateMachine.currentPlacerNode
		camera.position.y += prefabMesher.GRID_SIZE
		currentPlacerNode.global_position.y += prefabMesher.GRID_SIZE

func onEditorInputHandler_moveDownGrid():
	if editorStateMachine.canMovePreview():
		editorStateMachine.gridCurrentHeight -= 1	
		camera.position.y -= prefabMesher.GRID_SIZE
	elif editorStateMachine.mouseNotOverUI() && editorStateMachine.inEditState():
		var currentPlacerNode = editorStateMachine.currentPlacerNode
		camera.position.y -= prefabMesher.GRID_SIZE
		currentPlacerNode.global_position.y -= prefabMesher.GRID_SIZE

func onEditorInputHandler_placePressed():
	if editorStateMachine.canBuild():
		if editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_PREFAB:
			map.add(prefabMesher)
		elif editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_START:
			map.addStart(propPlacer)
		elif editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_CHECKPOINT:
			map.addCheckPoint(propPlacer)

func onEditorInputHandler_rotatePressed():
	var currentPlacerNode = editorStateMachine.currentPlacerNode
	# prefabMesher.rotate90()
	currentPlacerNode.rotate90()

func onEditorInputHandler_fineRotatePressed(direction: int):
	if editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_PREFAB:
		prefabMesher.rotate90(direction)
	else:
		propPlacer.rotateFine(direction)

func onEditorInputHandler_selectPressed(object: Object):
	if object != null:
		print(object, "was ray hit with selection", object.get_class())
	if editorStateMachine.mouseNotOverUI() && editorStateMachine.inEditState():
		var oldSelection = editorStateMachine.setCurrentSelection(object)
		if oldSelection != null || oldSelection == object:
			if oldSelection.has_method("deselect"):
				oldSelection.deselect()
				map.update(oldSelection, prefabMesher)
				prefabMesher.visible = false
			elif oldSelection.has_method("isStart"):
				map.addStart(propPlacer)
				oldSelection.visible = true
				propPlacer.visible = false
			elif oldSelection.has_method("isCheckPoint"):
				map.updateCheckPoint(oldSelection, propPlacer)
				oldSelection.visible = true
				propPlacer.visible = false
			editorStateMachine.clearSelection()
			return

		if object.has_method("select"):
			object.select()
			prefabPropertiesUI.setFromData(object.prefabData)

			editorStateMachine.currentPlacerNode = prefabMesher

			prefabMesher.visible = true
			prefabMesher.updatePositionExact(object.global_position, object.global_rotation)
		elif object.has_method("isStart"):
			object.visible = false
			propPlacer.visible = true

			editorStateMachine.currentPlacerNode = propPlacer

			editorStateMachine.gridCurrentHeight = (object.global_position - map.START_OFFSET).y / prefabMesher.GRID_SIZE
			propPlacer.updatePositionExact(object.global_position, object.global_rotation)
			propPlacer.mode = propPlacer.MODE_START_LINE
		elif object.has_method("isCheckPoint"):
			object.visible = false
			propPlacer.visible = true

			editorStateMachine.currentPlacerNode = propPlacer

			editorStateMachine.gridCurrentHeight = object.global_position.y / prefabMesher.GRID_SIZE
			propPlacer.updatePositionExact(object.global_position, object.global_rotation)
			propPlacer.mode = propPlacer.MODE_CHECKPOINT

	if editorStateMachine.mouseNotOverUI() && editorStateMachine.inDeleteState():
		if object.has_method("select"):
			map.remove(object)
		elif object.has_method("isStart"):
			map.removeStart()
		elif object.has_method("isCheckPoint"):
			map.removeCheckPoint(object)

func onEditorInputHandler_deleteSelectedPressed():
	if editorStateMachine.inEditState() || editorStateMachine.inDeleteState():
		var oldSelection = editorStateMachine.currentSelection
		if oldSelection != null:
			map.remove(oldSelection)
			editorStateMachine.clearSelection()
			prefabMesher.visible = false
		


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

func onPrefabPropertiesUI_roadTypeChanged(value: int):
	prefabMesher.roadType = value

func onEditorInputHandler_mouseEnteredUI():
	editorStateMachine.mouseOverUI = true
	if editorStateMachine.inBuildState():
		prefabMesher.updatePositionExactCentered(camera.getPositionInFrontOfCamera(60))
	print("Mouse entered prefab properties")

func onEditorInputHandler_mouseExitedUI():
	editorStateMachine.mouseOverUI = false
	print("Mouse exited prefab properties")

func onEditorInputHandler_undoPressed():
	map.undo()

func onEditorInputHandler_redoPressed():
	map.redo()

func onEditorInputHandler_savePressed():
	map.save()

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
	var oldSelection = editorStateMachine.currentSelection
	if oldSelection != null:
		map.update(oldSelection, prefabMesher)
		editorStateMachine.clearSelection()
	# onEditorStateMachine_buildModeChanged(editorStateMachine.buildMode)
	print("Build mode")

func onEditorInputHandler_editorModeEditPressed():
	editorStateMachine.setEditorStateEdit()
	prefabMesher.visible = false
	propPlacer.visible = false
	print("Edit mode")

func onEditorInputHandler_editorModeDeletePressed():
	editorStateMachine.setEditorStateDelete()
	var oldSelection = editorStateMachine.currentSelection
	if oldSelection != null:
		map.update(oldSelection, prefabMesher)
		editorStateMachine.clearSelection()
	prefabMesher.visible = false
	propPlacer.visible = false
	print("Delete mode")

func onEditorInputHandler_prevBuildModePressed():
	editorStateMachine.prevBuildMode()
	print("Previous build mode: ", editorStateMachine.buildMode)

func onEditorInputHandler_nextBuildModePressed():
	editorStateMachine.nextBuildMode()
	print("Next build mode: ", editorStateMachine.buildMode)

func onEditorStateMachine_buildModeChanged(newMode: int):
	if newMode != editorStateMachine.EDITOR_BUILD_MODE_PREFAB:
		propPlacer.mode = newMode - 1
		prefabMesher.visible = false
		propPlacer.visible = true
		editorStateMachine.currentPlacerNode = propPlacer
	else:
		prefabMesher.visible = true
		propPlacer.visible = false
		editorStateMachine.currentPlacerNode = prefabMesher

