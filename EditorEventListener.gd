extends Node3D

var editorInputHandler: EditorInputHandler
var prefabMesher: PrefabMesher
var editorStateMachine: EditorStateMachine
var camera: EditorCamera
var map: Map
var propPlacer: PropPlacer

var prefabPropertiesUI: PrefabPropertiesUI
var propPropertiesUI: PropPropertiesUI
var editorShortcutsUI: EditorShortcutsUI
var trackMetadataUI: TrackMetadataUI
@onready var prefabSelectorUI: PrefabSelectorUI = %PrefabSelectorUI
@onready var loading: Control = %Loading

var pauseMenu: PauseMenu

var car: CarController
var carCamera: FollowingCamera




func _ready():
	# assign nodes
	editorInputHandler = %EditorInputHandler
	prefabMesher = %PrefabGenerator/PrefabMesher
	editorStateMachine = %EditorStateMachine 
	camera = %EditorCamera
	map = %Map
	prefabPropertiesUI = %PrefabPropertiesUI
	propPropertiesUI = %PropPropertiesUI
	editorShortcutsUI = %EditorShortcutsUI
	trackMetadataUI = %TrackMetadataUI
	pauseMenu = %PauseMenu
	trackMetadataUI.visible = false

	propPlacer = %PropPlacer

	car = %CarController

	var playerNode = %Player
	carCamera = FollowingCamera.new(car)
	carCamera.current = false
	playerNode.add_child(carCamera)

	editorStateMachine.editorState = editorStateMachine.EDITOR_STATE_PLAYTEST
	onCar_pausePressed()

	prefabPropertiesUI.visible = true
	propPropertiesUI.visible = false

	propPlacer.startLinePreview.visible = false
	prefabMesher.debug = true

	loading.visible = true

	editorStateMachine.buildMode = editorStateMachine.EDITOR_BUILD_MODE_PREFAB
	editorStateMachine.currentPlacerNode = prefabMesher

	connectSignals()

func connectSignals():
	prefabMesher.propertiesUpdated.connect(onPrefabMesher_propertiesUpdated)
	# connect signals
	editorInputHandler.mouseMovedTo.connect(onEditorInputHandler_mouseMovedTo)
	editorInputHandler.moveUpGrid.connect(onEditorInputHandler_moveUpGrid)
	editorInputHandler.moveDownGrid.connect(onEditorInputHandler_moveDownGrid)
	editorInputHandler.placePressed.connect(onEditorInputHandler_placePressed)
	editorInputHandler.rotatePressed.connect(onEditorInputHandler_rotatePressed)
	editorInputHandler.fineRotatePressed.connect(onEditorInputHandler_fineRotatePressed)
	editorInputHandler.selectPressed.connect(onEditorInputHandler_selectPressed)
	editorInputHandler.deleteSelectedPressed.connect(onEditorInputHandler_deleteSelectedPressed)
	editorInputHandler.pausePressed.connect(onEditorInputHandler_pausePressed)

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
	prefabPropertiesUI.leftWallStartChanged.connect(onPrefabPropertiesUI_leftWallStartChanged)
	prefabPropertiesUI.rightWallStartChanged.connect(onPrefabPropertiesUI_rightWallStartChanged)
	prefabPropertiesUI.leftWallEndChanged.connect(onPrefabPropertiesUI_leftWallEndChanged)
	prefabPropertiesUI.rightWallEndChanged.connect(onPrefabPropertiesUI_rightWallEndChanged)
	prefabPropertiesUI.curvedChanged.connect(onPrefabPropertiesUI_curvedChanged)
	prefabPropertiesUI.snapChanged.connect(onPrefabPropertiesUI_snapChanged)
	prefabPropertiesUI.straightLengthChanged.connect(onPrefabPropertiesUI_straightLengthChanged)
	prefabPropertiesUI.straightOffsetChanged.connect(onPrefabPropertiesUI_straightOffsetChanged)
	prefabPropertiesUI.straightSmoothingChanged.connect(onPrefabPropertiesUI_straightSmoothingChanged)
	prefabPropertiesUI.curveForwardChanged.connect(onPrefabPropertiesUI_curveForwardChanged)
	prefabPropertiesUI.curveSidewaysChanged.connect(onPrefabPropertiesUI_curveSidewaysChanged)
	prefabPropertiesUI.roadTypeChanged.connect(onPrefabPropertiesUI_roadTypeChanged)

	propPropertiesUI.textureIndexChanged.connect(onPropPropertiesUI_textureIndexChanged)

	editorShortcutsUI.editorModeChanged.connect(onEditorShortcutsUI_editorModeChanged)
	editorShortcutsUI.buildModeChanged.connect(onEditorShortcutsUI_buildModeChanged)
	editorShortcutsUI.propertiesPressed.connect(onEditorShortcutsUI_propertiesPressed)
	editorShortcutsUI.savePressed.connect(onEditorInputHandler_savePressed)
	editorShortcutsUI.undoPressed.connect(onEditorInputHandler_undoPressed)
	editorShortcutsUI.redoPressed.connect(onEditorInputHandler_redoPressed)
	editorShortcutsUI.testPressed.connect(onEditorInputHandler_testPressed)

	trackMetadataUI.trackNameChanged.connect(onTrackMetadataUI_trackNameChanged)
	trackMetadataUI.lapCountChanged.connect(onTrackMetadataUI_lapCountChanged)
	trackMetadataUI.closePressed.connect(onTrackMetadataUI_closePressed)
	trackMetadataUI.applyPressed.connect(onTrackMetadataUI_closePressed)

	pauseMenu.resumePressed.connect(onEditorInputHandler_pausePressed)
	pauseMenu.exitPressed.connect(onEditorExited)

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

	editorInputHandler.fullScreenPressed.connect(onEditorInputHandler_fullScreenPressed)

	editorStateMachine.buildModeChanged.connect(onEditorStateMachine_buildModeChanged)

	map.undidLastOperation.connect(onMap_undidLastOperation)
	map.redidLastOperation.connect(onMap_redidLastOperation)
	map.noOperationToBeUndone.connect(onMap_noOperationToBeUndone)
	map.noOperationToBeRedone.connect(onMap_noOperationToBeRedone)
	# HOORIBLE DONT DO THIS
	map.canUndo.connect(editorShortcutsUI.setUndoEnabled)
	map.canRedo.connect(editorShortcutsUI.setRedoEnabled)
	
	map.mapLoaded.connect(onMap_mapLoaded)

	car.isResetting.connect(onCar_pausePressed)

	camera.mouseCaptureExited.connect(onCamera_mouseCaptureExited)

	prefabSelectorUI.done.connect(onPrefabSelectorUI_done)
	prefabSelectorUI.prefabSelected.connect(onPrefabSelectorUI_prefabSelected)



func onPrefabMesher_propertiesUpdated():
	prefabPropertiesUI.setFromData(prefabMesher.encodeData())

func onEditorInputHandler_mouseMovedTo(worldMousePos: Vector3):
	# print("Mouse moved to: ", worldMousePos)
	var currentPlacerNode = editorStateMachine.currentPlacerNode
	if worldMousePos != Vector3.INF && editorStateMachine.canMovePreview():
		currentPlacerNode.updatePosition(worldMousePos, camera.global_position, editorStateMachine.gridCurrentHeight, map.getConnectionPoints())
	elif editorStateMachine.mouseOverUI && editorStateMachine.inBuildState():
		currentPlacerNode.updatePositionExactCentered(camera.getPositionInFrontOfCamera(100))

func onEditorInputHandler_moveUpGrid():
	if editorStateMachine.canMovePreview():
		editorStateMachine.gridCurrentHeight += 1
		camera.position.y += PrefabConstants.GRID_SIZE
	elif editorStateMachine.mouseNotOverUI() && editorStateMachine.inEditState():
		var currentPlacerNode = editorStateMachine.currentPlacerNode
		camera.position.y += PrefabConstants.GRID_SIZE
		currentPlacerNode.global_position.y += PrefabConstants.GRID_SIZE

func onEditorInputHandler_moveDownGrid():
	if editorStateMachine.canMovePreview():
		editorStateMachine.gridCurrentHeight -= 1	
		camera.position.y -= PrefabConstants.GRID_SIZE
	elif editorStateMachine.mouseNotOverUI() && editorStateMachine.inEditState():
		var currentPlacerNode = editorStateMachine.currentPlacerNode
		camera.position.y -= PrefabConstants.GRID_SIZE
		currentPlacerNode.global_position.y -= PrefabConstants.GRID_SIZE

func onEditorInputHandler_placePressed():
	if editorStateMachine.canBuild():
		if editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_PREFAB:
			map.add(prefabMesher)
		elif editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_START:
			map.addStart(propPlacer)
		elif editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_CHECKPOINT:
			map.addCheckPoint(propPlacer)
		elif editorStateMachine.buildMode == editorStateMachine.EDITOR_BUILD_MODE_PROP:
			map.addProp(propPlacer)

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
	if object == null:
		return
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
			elif oldSelection.has_method("isProp"):
				map.updateProp(oldSelection, propPlacer)
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
			setVisibleUI(EDITOR_UI_PREFAB_PROPERTIES)
		elif object.has_method("isStart"):
			object.visible = false
			propPlacer.visible = true

			editorStateMachine.currentPlacerNode = propPlacer

			editorStateMachine.gridCurrentHeight = (object.global_position - map.START_OFFSET).y / PrefabConstants.GRID_SIZE
			propPlacer.updatePositionExact(object.global_position, object.global_rotation)
			propPlacer.mode = propPlacer.MODE_START_LINE
			setVisibleUI(EDITOR_UI_START_PROPERTIES)
		elif object.has_method("isCheckPoint"):
			object.visible = false
			propPlacer.visible = true

			editorStateMachine.currentPlacerNode = propPlacer

			editorStateMachine.gridCurrentHeight = object.global_position.y / PrefabConstants.GRID_SIZE
			propPlacer.updatePositionExact(object.global_position, object.global_rotation)
			propPlacer.mode = propPlacer.MODE_CHECKPOINT
			setVisibleUI(EDITOR_UI_CHECKPOINT_PROPERTIES)
		elif object.has_method("isProp"):
			object.visible = false
			propPlacer.visible = true

			editorStateMachine.currentPlacerNode = propPlacer

			editorStateMachine.gridCurrentHeight = object.global_position.y / PrefabConstants.GRID_SIZE
			propPlacer.updatePositionExact(object.global_position, object.global_rotation)
			propPlacer.mode = propPlacer.MODE_PROP
			setVisibleUI(EDITOR_UI_PROP_PROPERTIES)


	if editorStateMachine.mouseNotOverUI() && editorStateMachine.inDeleteState():
		if object.has_method("select"):
			map.remove(object)
		elif object.has_method("isStart"):
			map.removeStart()
		elif object.has_method("isCheckPoint"):
			map.removeCheckPoint(object)
		elif object.has_method("isProp"):
			map.removeProp(object)

func onEditorInputHandler_deleteSelectedPressed():
	if editorStateMachine.inEditState() || editorStateMachine.inDeleteState():
		var oldSelection = editorStateMachine.currentSelection
		if oldSelection != null:
			if oldSelection.has_method("select"):
				map.remove(oldSelection)
			elif oldSelection.has_method("isStart"):
				map.removeStart()
			elif oldSelection.has_method("isCheckPoint"):
				map.removeCheckPoint(oldSelection)
			elif oldSelection.has_method("isProp"):
				map.removeProp(oldSelection)

			editorStateMachine.clearSelection()
			prefabMesher.visible = false

func onEditorInputHandler_pausePressed(paused: bool = false):
	pauseMenu.visible = paused
	editorInputHandler.paused = paused

func onPrefabPropertiesUI_leftEndChanged(value: int):
	prefabMesher.leftEndHeight = value

func onPrefabPropertiesUI_rightEndChanged(value: int):
	prefabMesher.rightEndHeight = value

func onPrefabPropertiesUI_leftStartChanged(value: int):
	prefabMesher.leftStartHeight = value

func onPrefabPropertiesUI_rightStartChanged(value: int):
	prefabMesher.rightStartHeight = value

func onPrefabPropertiesUI_leftSmoothingChanged(value: int):
	prefabMesher.leftSmoothTilt = value

func onPrefabPropertiesUI_rightSmoothingChanged(value: int):
	prefabMesher.rightSmoothTilt = value

func onPrefabPropertiesUI_leftWallStartChanged(value: bool):
	prefabMesher.leftWallStart = value

func onPrefabPropertiesUI_rightWallStartChanged(value: bool):
	prefabMesher.rightWallStart = value

func onPrefabPropertiesUI_leftWallEndChanged(value: bool):
	prefabMesher.leftWallEnd = value

func onPrefabPropertiesUI_rightWallEndChanged(value: bool):
	prefabMesher.rightWallEnd = value

func onPrefabPropertiesUI_curvedChanged(value: bool):
	prefabMesher.curve = value

func onPrefabPropertiesUI_snapChanged(value: bool):
	prefabMesher.snapping = value

func onPrefabPropertiesUI_straightLengthChanged(value: int):
	prefabMesher.length = value

func onPrefabPropertiesUI_straightOffsetChanged(value: int):
	prefabMesher.endOffset = value

func onPrefabPropertiesUI_straightSmoothingChanged(value: int):
	prefabMesher.smoothOffset = value

func onPrefabPropertiesUI_curveForwardChanged(value: int):
	prefabMesher.curveForward = value

func onPrefabPropertiesUI_curveSidewaysChanged(value: int):
	prefabMesher.curveSideways = value

func onPrefabPropertiesUI_roadTypeChanged(value: int):
	prefabMesher.roadType = value

func onPropPropertiesUI_textureIndexChanged(value: int, imageUrl: String):
	propPlacer.currentBillboardTexture = value
	propPlacer.currentImageUrl = imageUrl

func onEditorShortcutsUI_editorModeChanged(newMode: int):
	if newMode == editorStateMachine.EDITOR_STATE_BUILD:
		onEditorInputHandler_editorModeBuildPressed()
	elif newMode == editorStateMachine.EDITOR_STATE_EDIT:
		onEditorInputHandler_editorModeEditPressed()
	elif newMode == editorStateMachine.EDITOR_STATE_DELETE:
		onEditorInputHandler_editorModeDeletePressed()

func onEditorShortcutsUI_buildModeChanged(newMode: int):
	editorStateMachine.buildMode = newMode

func onEditorShortcutsUI_propertiesPressed():
	trackMetadataUI.visible = true
	editorInputHandler.propertiesOpen = true

func onTrackMetadataUI_closePressed():
	# trackMetadataUI.visible = false
	editorInputHandler.propertiesOpen = false

func onTrackMetadataUI_trackNameChanged(newName: String):
	map.trackName = newName

func onTrackMetadataUI_lapCountChanged(newCount: int):
	map.lapCount = newCount

func onEditorInputHandler_mouseEnteredUI():
	editorStateMachine.mouseOverUI = true
	if editorStateMachine.inBuildState():
		prefabMesher.updatePositionExactCentered(camera.getPositionInFrontOfCamera(100))
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
	editorShortcutsUI.changeEditorMode(editorStateMachine.EDITOR_STATE_BUILD)
	print("Build mode")

func onEditorInputHandler_editorModeEditPressed():
	editorStateMachine.setEditorStateEdit()
	prefabMesher.visible = false
	propPlacer.visible = false
	editorShortcutsUI.changeEditorMode(editorStateMachine.EDITOR_STATE_EDIT)
	print("Edit mode")

func onEditorInputHandler_editorModeDeletePressed():
	editorStateMachine.setEditorStateDelete()
	var oldSelection = editorStateMachine.currentSelection
	if oldSelection != null:
		map.update(oldSelection, prefabMesher)
		editorStateMachine.clearSelection()
	prefabMesher.visible = false
	propPlacer.visible = false
	editorShortcutsUI.changeEditorMode(editorStateMachine.EDITOR_STATE_DELETE)
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

	setVisibleUI(newMode)
	
	editorShortcutsUI.changeBuildMode(newMode)

func onEditorInputHandler_fullScreenPressed():
	Playerstats.FULLSCREEN = !Playerstats.FULLSCREEN

var oldSoundVolume: float = 0
func onEditorInputHandler_testPressed():
	car.resumeMovement()
	car.setRespawnPositionFromDictionary(map.start.getStartPosition(0, 1))
	car.respawn()
	car.visible = true
	carCamera.current = true
	camera.current = false
	hideUI()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), oldSoundVolume)
	editorStateMachine.editorState = editorStateMachine.EDITOR_STATE_PLAYTEST

func onCar_pausePressed(_sink = null, _sink2 = null):
	if !editorStateMachine.inPlaytestState():
		return
	editorStateMachine.editorState = editorStateMachine.EDITOR_STATE_BUILD
	setVisibleUI(editorStateMachine.editorState)
	editorShortcutsUI.visible = true
	car.setRespawnPosition(Vector3(0, -1000, 0), Vector3(0, 0, 0))
	car.respawn()
	car.pauseMovement()
	car.visible = false
	carCamera.current = false
	camera.current = true
	oldSoundVolume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -80)

func onCamera_mouseCaptureExited():
	# if editorStateMachine.canMovePreview():
	# 	editorStateMachine.gridCurrentHeight += 1
	# 	camera.position.y += PrefabConstants.GRID_SIZE
	editorStateMachine.gridCurrentHeight = max(0, floor(camera.position.y / PrefabConstants.GRID_SIZE - 32))

func onPrefabSelectorUI_done():
	loading.visible = false

func onPrefabSelectorUI_prefabSelected(data: Dictionary):
	# prefabMesher.decodeData(data)
	prefabPropertiesUI.setFromData(data)
	# prefabSelectorUI.visible = false

func onMap_mapLoaded(trackName: String, lapCount: int):
	trackMetadataUI.setFromData({
		"trackName": trackName,
		"lapCount": lapCount
	})

func onEditorExited():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), oldSoundVolume)
	get_parent().editorExited.emit()

const EDITOR_UI_PREFAB_PROPERTIES: int = 0
const EDITOR_UI_START_PROPERTIES: int = 1
const EDITOR_UI_CHECKPOINT_PROPERTIES: int = 2
const EDITOR_UI_PROP_PROPERTIES: int = 3

func setVisibleUI(visibleUI: int):
	prefabPropertiesUI.visible = visibleUI == EDITOR_UI_PREFAB_PROPERTIES
	prefabSelectorUI.visible = visibleUI == EDITOR_UI_PREFAB_PROPERTIES
	propPropertiesUI.visible = visibleUI == EDITOR_UI_PROP_PROPERTIES

func hideUI():
	prefabPropertiesUI.visible = false
	propPropertiesUI.visible = false
	editorShortcutsUI.visible = false
	prefabSelectorUI.visible = false
