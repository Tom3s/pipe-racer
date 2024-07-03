extends Node3D
class_name EditorEventListener

@onready var ledBoardScene: PackedScene = preload("res://Editor/Props/LedBoard.tscn")


@onready var inputHandler: EditorInputHandler = %EditorInputHandler
@onready var camera: EditorCamera = %EditorCamera
# @onready var previewElementParent: Node3D = %PreviewElement
@onready var map: InteractiveMap = %InteractiveMap

@onready var roadNode: RoadNode = %RoadNode
@onready var pipeNode: PipeNode = %PipeNode
@onready var startLine: ProceduralStartLine = %StartLine
@onready var checkpoint: FunctionalCheckpoint = %Checkpoint
@onready var ledBoard: LedBoard = %LedBoard
var currentElement: Node3D = null

@onready var gridMesh: MeshInstance3D = %GridMesh

@onready var editorSidebarUI: EditorSidebarUI = %EditorSidebarUI

@onready var roadNodePropertiesUI: RoadNodePropertiesUI = %RoadNodePropertiesUI
@onready var roadPropertiesUI: RoadPropertiesUI = %RoadPropertiesUI

@onready var pipeNodePropertiesUI: PipeNodePropertiesUI = %PipeNodePropertiesUI
@onready var pipePropertiesUI: PipePropertiesUI = %PipePropertiesUI

@onready var startLinePropertiesUI: StartLinePropertiesUI = %StartLinePropertiesUI
@onready var checkpointPropertiesUI: CheckpointPropertiesUI = %CheckpointPropertiesUI
@onready var ledBoardPropertiesUI: LedBoardPropertiesUI = %LedBoardPropertiesUI

@onready var sceneryEditorUI: SceneryEditorUI = %SceneryEditorUI

@onready var paintBrushUI: PaintBrushUI = %PaintBrushUI

@onready var pauseMenu: PauseMenu = %PauseMenu

@onready var levelSavedLabel: Label = %LevelSavedLabel


# gizmos
@onready var rotator: Rotator = %Rotator
@onready var translator: Translator = %Translator

# player
@onready var playerParent: Node3D = %Player
@onready var car: CarController = %CarController
@onready var carPreview: Node3D = %CarPreview
var carCamera: FollowingCamera
@onready var carPath: Node3D = %CarPath



enum EditorMode {
	BUILD,
	EDIT,
	DELETE,
	SCENERY,
	PAINT,
	TEST,
}

var currentEditorMode: EditorMode = EditorMode.BUILD

enum BuildMode {
	ROAD,
	PIPE,
	START,
	CP,
	DECO
}

var currentBuildMode: BuildMode = BuildMode.ROAD

enum TestMode {
	PLACING,
	DRIVING
}

var currentTestMode: TestMode = TestMode.PLACING


var capturedGizmo: Node3D = null

var gizmoCenter: Vector2 = Vector2.ZERO
var rotationAxis: Vector3 = Vector3.ZERO
var moveAxis: Vector3 = Vector3.ZERO


var lastMousePos: Vector2 = Vector2.ZERO

var currentPaintBrushSurface: PhysicsSurface.SurfaceType = PhysicsSurface.SurfaceType.ROAD

var editorStats: EditorStats

var carPreviewAngleOffset: float = 0

func _ready():
	setUIVisibility()
	setCurrentElement()

	connectSignals()

	rotator.disable()
	translator.disable()



	pauseMenu.visible = false
	pauseMenu.restartButton.visible = false
	pauseMenu.editorGuide.visible = true
	pauseMenu.leaderboardButton.visible = false

	editorStats = EditorStats.new()

	carCamera = FollowingCamera.new(car)
	carCamera.current = false
	playerParent.add_child(carCamera)

	car.isResetting.connect(func(_sink1 = null, _sink2 = null, _sink3 = null):
		if currentEditorMode == EditorMode.TEST && currentTestMode == TestMode.DRIVING:
			car.setRespawnPositionFromDictionary(originalRespawn)
			car.respawn()
	)

	carPreview.visible = false

	levelSavedLabel.modulate.a = 0
	levelSavedLabel.text = "Level Saved As: " + map.trackName

	set_physics_process(true)

const MAX_CAR_PATH_LENGTH: int = 8192
const MAX_CAR_PATHS: int = 16

var wasTesting: bool = false

func _physics_process(delta):
	if currentTestMode == TestMode.DRIVING && !wasTesting:
		carPathArray.clear()
		carPathArray.append([])
		if carPathArray.size() > MAX_CAR_PATHS:
			carPathArray.pop_front()
	
	if currentTestMode == TestMode.DRIVING:
		if car != null:
			carPathArray.back().append(car.getCurrentFrame())
			if carPathArray.back().size() > MAX_CAR_PATH_LENGTH:
				carPathArray.back().pop_front()

	wasTesting = currentTestMode == TestMode.DRIVING


func connectSignals():
	inputHandler.mouseMovedTo.connect(func(worldPos: Vector3):
		if worldPos == Vector3.INF:
			return
		
		if currentElement == null:
			return

		currentElement.global_position = worldPos
		gridMesh.global_position = worldPos
	)

	inputHandler.moveUpGrid.connect(func():
		camera.global_position += Vector3.UP * PrefabConstants.GRID_SIZE
	)

	inputHandler.moveDownGrid.connect(func():
		camera.global_position += Vector3.DOWN * PrefabConstants.GRID_SIZE
	)

	inputHandler.rotatePressed.connect(func(axis: Vector3, angle: float):
		if currentEditorMode == EditorMode.TEST:
			carPreviewAngleOffset += angle

		if currentElement == null:
			return

		if axis == Vector3.UP:
			currentElement.global_rotation.y += angle
		elif axis == Vector3.RIGHT:
			currentElement.global_rotation.x += angle
		elif axis == Vector3.FORWARD:
			currentElement.global_rotation.z += angle
		
		# currentElement.global_rotation = currentElement.global_rotation.snapped(Vector3.ONE * deg_to_rad(5))
		# round(angle / ROTATION_SNAP) * ROTATION_SNAP
		var vec3Snap = Vector3.ONE * ROTATION_SNAP

		currentElement.global_rotation = (currentElement.global_rotation / vec3Snap) * vec3Snap
	)
	inputHandler.resetRotationPressed.connect(func():
		if currentElement == null:
			return

		currentElement.global_rotation = Vector3.ZERO
	)

	inputHandler.placePressed.connect(func():
		if currentEditorMode == EditorMode.SCENERY:
			map.onInputHandler_placePressed()
			return
		elif currentEditorMode == EditorMode.BUILD:
			if currentElement == null:
				return

			if ClassFunctions.getClassName(currentElement) == "RoadNode":
				var collidedObject = screenPointToRay()
				var newElement = currentElement.getCopy()	
				if collidedObject != null: # && map.lastRoadElement == null:
					collidedObject = collidedObject.get_parent()
					print("[EditorEventListener.gd] Class of collidedObject: ", ClassFunctions.getClassName(collidedObject))

					if ClassFunctions.getClassName(collidedObject) == "RoadNode":
						currentElement.global_position = collidedObject.global_position
						currentElement.global_rotation = collidedObject.global_rotation
						newElement = collidedObject

				map.addRoadNode(
					newElement, 
					currentElement.global_position, 
					currentElement.global_rotation,
					roadPropertiesUI.getProperties()
				)
				editorStats.increasePlacedTrackPieces()
			elif ClassFunctions.getClassName(currentElement) == "PipeNode":
				var collidedObject = screenPointToRay()
				var newElement = currentElement.getCopy()
				if collidedObject != null:
					collidedObject = collidedObject.get_parent()
					print("[EditorEventListener.gd] Class of collidedObject: ", ClassFunctions.getClassName(collidedObject))

					if ClassFunctions.getClassName(collidedObject) == "PipeNode":
						currentElement.global_position = collidedObject.global_position
						currentElement.global_rotation = collidedObject.global_rotation
						newElement = collidedObject
					
				map.addPipeNode(
					newElement, 
					currentElement.global_position, 
					currentElement.global_rotation,
					pipePropertiesUI.getProperties()
				)
				editorStats.increasePlacedTrackPieces()
			elif ClassFunctions.getClassName(currentElement) == "ProceduralStartLine":
				map.setStartLine(
					currentElement.global_position, 
					currentElement.global_rotation,
					currentElement.getProperties()
				)
				editorStats.increasePlacedProps()
			elif ClassFunctions.getClassName(currentElement) == "FunctionalCheckpoint":
				map.addCheckpoint(
					currentElement.getCopy(),
					currentElement.global_position, 
					currentElement.global_rotation,
					currentElement.getProperties()
				)
				editorStats.increasePlacedCheckpoints()
			elif ClassFunctions.getClassName(currentElement) == "LedBoard":
				map.addLedBoard(
					# currentElement.getCopy(),
					ledBoardScene.instantiate(),
					currentElement.global_position, 
					currentElement.global_rotation,
					currentElement.getProperties()
				)
				editorStats.increasePlacedProps()
			
			

		elif currentEditorMode == EditorMode.EDIT:
			var collidedObject = screenPointToRay()
			if collidedObject != null: 
				if ClassFunctions.getClassName(collidedObject) == "RotatorGizmo" || \
					ClassFunctions.getClassName(collidedObject) == "TranslatorGizmo":
					return
				rotator.disable()
				translator.disable()

				collidedObject = collidedObject.get_parent()
				if ClassFunctions.getClassName(collidedObject) == "PhysicsSurface" || \
					ClassFunctions.getClassName(collidedObject) == "ProceduralCheckpoint":
					collidedObject = collidedObject.get_parent()

				print("[EditorEventListener.gd] Class of collided Object (edit mode): ", ClassFunctions.getClassName(collidedObject))

				# apply edits to prev element
				if map.lastRoadElement != null:
					map.lastRoadElement.convertToPhysicsObject()
				if map.lastPipeElement != null:
					map.lastPipeElement.convertToPhysicsObject()

				if currentElement != null && \
					(ClassFunctions.getClassName(currentElement) == "RoadNode" || \
					 ClassFunctions.getClassName(currentElement) == "PipeNode"):
					# currentElement.setCollision(true)
					for meshGenerator in currentElement.meshGeneratorRefs:
						meshGenerator.convertToPhysicsObject()

				if currentElement != null && \
					(ClassFunctions.getClassName(currentElement) == "FunctionalStartLine" || \
					 ClassFunctions.getClassName(currentElement) == "LedBoard"):
					currentElement.convertToPhysicsObject()

				if ClassFunctions.getClassName(collidedObject) == "RoadMeshGenerator":
					map.lastRoadElement = collidedObject
					roadPropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.ROAD_PROPERTIES)
				elif ClassFunctions.getClassName(collidedObject) == "PipeMeshGenerator":
					map.lastPipeElement = collidedObject
					pipePropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.PIPE_PROPERTIES)
				elif ClassFunctions.getClassName(collidedObject) == "RoadNode":
					# map.lastRoadNode = collidedObject
					currentElement = collidedObject
					currentElement.setCollision(false)
					roadNodePropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.ROAD_NODE_PROPERTIES)
					rotator.enable()
					rotator.moveToNode(currentElement)
					translator.enable()
					translator.global_position = currentElement.global_position
					setGizmoScale(camera.global_position)
				elif ClassFunctions.getClassName(collidedObject) == "PipeNode":
					# map.lastPipeNode = collidedObject
					currentElement = collidedObject
					currentElement.setCollision(false)
					pipeNodePropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.PIPE_NODE_PROPERTIES)
					rotator.enable()
					rotator.moveToNode(currentElement)
					translator.enable()
					translator.global_position = currentElement.global_position
				elif ClassFunctions.getClassName(collidedObject) == "ProceduralStartLine":
					currentElement = collidedObject.get_parent() as FunctionalStartLine
					startLinePropertiesUI.setProperties(currentElement.getProperties())
					setEditUIVisibility(EditUIType.START_LINE_PROPERTIES)
					rotator.enable()
					rotator.moveToNode(currentElement)
					translator.enable()
					translator.global_position = currentElement.global_position
					setGizmoScale(camera.global_position)

				elif ClassFunctions.getClassName(collidedObject) == "FunctionalCheckpoint":
					currentElement = collidedObject
					checkpointPropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.CP_PROPERTIES)
					rotator.enable()
					rotator.moveToNode(currentElement)
					translator.enable()
					translator.global_position = currentElement.global_position
					setGizmoScale(camera.global_position)

				elif ClassFunctions.getClassName(collidedObject) == "LedBoard":
					currentElement = collidedObject
					ledBoardPropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.LED_BOARD_PROPERTIES)
					rotator.enable()
					rotator.moveToNode(currentElement)
					translator.enable()
					translator.global_position = currentElement.global_position
					setGizmoScale(camera.global_position)

				else:
					map.lastRoadElement = null
					map.lastPipeElement = null
					
					currentElement = null

					setEditUIVisibility(EditUIType.NONE)
		elif currentEditorMode == EditorMode.DELETE:
			var collidedObject = screenPointToRay()
			if collidedObject == null:
				return

			collidedObject = collidedObject.get_parent()
			if ClassFunctions.getClassName(collidedObject) == "PhysicsSurface" || \
				ClassFunctions.getClassName(collidedObject) == "ProceduralCheckpoint":
				collidedObject = collidedObject.get_parent()

			if ClassFunctions.getClassName(collidedObject) == "RoadMeshGenerator":
				map.removeRoadElement(collidedObject)
			elif ClassFunctions.getClassName(collidedObject) == "PipeMeshGenerator":
				map.removePipeElement(collidedObject)
			elif ClassFunctions.getClassName(collidedObject) == "RoadNode":
				map.removeRoadNode(collidedObject)
			elif ClassFunctions.getClassName(collidedObject) == "PipeNode":
				map.removePipeNode(collidedObject)
			elif ClassFunctions.getClassName(collidedObject) == "FunctionalCheckpoint":
				map.removeCheckpoint(collidedObject)
			elif ClassFunctions.getClassName(collidedObject) == "LedBoard":
				map.removeLedBoard(collidedObject)
			else:
				print("[EditorEventListener.gd] Class of collided Object (delete mode): ", ClassFunctions.getClassName(collidedObject)) 


		elif currentEditorMode == EditorMode.PAINT:
			var collidedObject = screenPointToRay()
			if collidedObject == null:
				return

			collidedObject = collidedObject.get_parent()
			if !ClassFunctions.getClassName(collidedObject) == "PhysicsSurface":
				return
			
			collidedObject = collidedObject.get_parent()

			if ClassFunctions.getClassName(collidedObject) == "RoadMeshGenerator":
				collidedObject.surfaceType = currentPaintBrushSurface
				collidedObject.convertToPhysicsObject()
			elif ClassFunctions.getClassName(collidedObject) == "PipeMeshGenerator":
				collidedObject.surfaceType = currentPaintBrushSurface
				collidedObject.convertToPhysicsObject()

		elif currentEditorMode == EditorMode.TEST:
			var collidedObject = screenPointToRay()
			if collidedObject == null:
				
				return
			
			collidedObject = collidedObject.get_parent()
			if ClassFunctions.getClassName(collidedObject) == "PhysicsSurface" || \
				ClassFunctions.getClassName(collidedObject) == "ProceduralCheckpoint":
				collidedObject = collidedObject.get_parent()

			if ClassFunctions.getClassName(collidedObject) == "FunctionalCheckpoint":
				collidedObject = collidedObject as FunctionalCheckpoint
				var respawn: Dictionary = collidedObject.getRespawnPosition(0, 1)
				startTesting(
					respawn.position,
					respawn.rotation
				)
			elif ClassFunctions.getClassName(collidedObject) == "ProceduralStartLine":
				collidedObject = collidedObject.get_parent() as FunctionalStartLine
				var respawn: Dictionary = collidedObject.getStartPosition(0, 1)
				startTesting(
					respawn.position,
					respawn.rotation
				)
			else:
				startTesting(
					carPreview.global_position,
					carPreview.global_rotation
				)

	)

	inputHandler.clickStarted.connect(func(): 
		capturedGizmo = screenPointToRay() 
		if capturedGizmo != null && capturedGizmo.has_method("capture"):
			capturedGizmo.capture()
			if ClassFunctions.getClassName(capturedGizmo) == "RotatorGizmo":
				gizmoCenter = capturedGizmo.getCenterPoint()
				rotationAxis = capturedGizmo.rotationAxis
			elif ClassFunctions.getClassName(capturedGizmo) == "TranslatorGizmo":
				gizmoCenter = capturedGizmo.getCenterPoint()
				moveAxis = capturedGizmo.moveAxis
				gridMesh.global_position = capturedGizmo.global_position
				gridMesh.visible = true				
			lastMousePos = get_viewport().get_mouse_position()
	)

	inputHandler.clickEnded.connect(func():
		if capturedGizmo != null && capturedGizmo.has_method("release"):
			capturedGizmo.release()
		gizmoCenter = Vector2.ZERO
		rotationAxis = Vector3.ZERO
		moveAxis = Vector3.ZERO
		capturedGizmo = null
		gridMesh.visible = false
	)

	inputHandler.mouseMovedOnScreen.connect(func(mousePos: Vector2):
		if currentEditorMode == EditorMode.EDIT:
			# handle mouse movement
			handleMouseMovement(mousePos)

		elif currentEditorMode == EditorMode.TEST:
			var intersectData = screenPointToRay_worldPos()
			if intersectData.has("position") && intersectData.has("normal"):
				carPreview.global_position = intersectData["position"] + 0.35 * intersectData["normal"]
				carPreview.global_rotation = intersectData["normal"]
				# carPreview.global_rotation.y += carPreviewAngleOffset
				carPreview.rotate(carPreview.global_basis.y, carPreviewAngleOffset)
				
				
	)

	inputHandler.stopTestingPressed.connect(func():
		stopTesting()
	)

	inputHandler.pausePressed.connect(func(paused: bool):
		pauseMenu.visible = paused
		inputHandler.paused = paused
	)

	rotator.rotationChanged.connect(func(newRotation: Vector3):
		if currentElement != null:
			currentElement.rotation = newRotation
			if ClassFunctions.getClassName(currentElement) == "RoadNode":
				roadNodePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "PipeNode":
				pipeNodePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "FunctionalStartLine":
				startLinePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "FunctionalCheckpoint":
				checkpointPropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "LedBoard":
				ledBoardPropertiesUI.setProperties(currentElement.getProperties())
	)

	translator.positionChanged.connect(func(newPos: Vector3):
		if currentElement != null:
			currentElement.global_position = newPos
			gridMesh.global_position = newPos
			rotator.moveToNode(currentElement)
			setGizmoScale(camera.global_position)

			if ClassFunctions.getClassName(currentElement) == "RoadNode":
				roadNodePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "PipeNode":
				pipeNodePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "FunctionalStartLine":
				startLinePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "FunctionalCheckpoint":
				checkpointPropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "LedBoard":
				ledBoardPropertiesUI.setProperties(currentElement.getProperties())
	)

	map.roadPreviewElementRequested.connect(func():
		map.onRoadPreviewElementProvided(roadNode)
	)

	map.pipePreviewElementRequested.connect(func():
		map.onPipePreviewElementProvided(pipeNode)
	)

	# sidebar
	editorSidebarUI.buildModeChanged.connect(func(mode: BuildMode):
		map.clearPreviews()
		currentBuildMode = mode
		setUIVisibility()
		setCurrentElement()
	)

	editorSidebarUI.editorModeChanged.connect(func(mode: EditorMode):
		if currentEditorMode == EditorMode.BUILD:
			map.clearPreviews()

		currentEditorMode = mode
		inputHandler.editorMode = mode

		if mode == EditorMode.TEST:
			currentTestMode = TestMode.PLACING
			inputHandler.carTestDriving = false
			carPreview.visible = true

		

		if mode != EditorMode.EDIT:
			if map.lastRoadElement != null:
				map.lastRoadElement.convertToPhysicsObject()
			map.lastRoadElement = null

			if map.lastPipeElement != null:
				map.lastPipeElement.convertToPhysicsObject()
			map.lastPipeElement = null

			if currentElement != null:
				if ClassFunctions.getClassName(currentElement) == "RoadNode" || \
					ClassFunctions.getClassName(currentElement) == "RoadNode":
					currentElement.setCollision(true)
					for meshGenerator in currentElement.meshGeneratorRefs:
						if meshGenerator != null:
							meshGenerator.convertToPhysicsObject()
				
				if ClassFunctions.getClassName(currentElement) == "LedBoard":
					currentElement.convertToPhysicsObject()
					
			currentElement = null

			var roadNodeProperties = roadNodePropertiesUI.getProperties()
			roadNodeProperties.erase("position")
			roadNodeProperties.erase("rotation")
			roadNode.setProperties(roadNodeProperties)

			var pipeNodeProperties = pipeNodePropertiesUI.getProperties()
			pipeNodeProperties.erase("position")
			pipeNodeProperties.erase("rotation")
			pipeNode.setProperties(pipeNodeProperties)

			# var startLineProperties = startLinePropertiesUI.getProperties()
			# startLineProperties.erase("position")
			# startLineProperties.erase("rotation")

			var checkpointProperties = checkpointPropertiesUI.getProperties()
			checkpointProperties.erase("position")
			checkpointProperties.erase("rotation")
			checkpoint.setProperties(checkpointProperties)

			var ledBoardProperties = ledBoardPropertiesUI.getProperties()
			ledBoardProperties.erase("position")
			ledBoardProperties.erase("rotation")
			ledBoard.setProperties(ledBoardProperties)

			rotator.disable()
			translator.disable()

		setUIVisibility()
		setCurrentElement()
	)

	editorSidebarUI.trackNameChanged.connect(func(name: String):
		map.trackName = name
	)

	editorSidebarUI.lapCountChanged.connect(func(count: int):
		map.lapCount = count
	)

	editorSidebarUI.savePressed.connect(func():
		map.exportTrack()

		levelSavedLabel.text = "Level Saved As: " + map.trackName
	
		var tween = create_tween().set_ease(Tween.EASE_OUT)

		tween.tween_property(levelSavedLabel, "modulate:a", 1, 0)
		tween.tween_property(levelSavedLabel, "modulate:a", 1, 1.5)
		tween.tween_property(levelSavedLabel, "modulate:a", 0, 0.3)
	)

	# road node properties ui
	roadNodePropertiesUI.roadProfileChanged.connect(func(profile: int):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "RoadNode":
			return
		
		currentElement = currentElement as RoadNode
		currentElement.profileType = profile as RoadNode.RoadProfile
	)

	roadNodePropertiesUI.profileHeightChanged.connect(func(value: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "RoadNode":
			return
		
		currentElement = currentElement as RoadNode
		currentElement.profileHeight = value
	)

	roadNodePropertiesUI.widthChanged.connect(func(value: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "RoadNode":
			return
		
		currentElement = currentElement as RoadNode
		currentElement.width = value
	)

	roadNodePropertiesUI.leftRunoffChanged.connect(func(value: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "RoadNode":
			return
		
		currentElement = currentElement as RoadNode
		currentElement.leftRunoff = value
	)

	roadNodePropertiesUI.rightRunoffChanged.connect(func(value: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "RoadNode":
			return
		
		currentElement = currentElement as RoadNode
		currentElement.rightRunoff = value
	)

	roadNodePropertiesUI.positionChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "RoadNode":
			return
		
		currentElement = currentElement as RoadNode
		currentElement.global_position = value

		rotator.moveToNode(currentElement)
		translator.global_position = value
	)

	roadNodePropertiesUI.rotationChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "RoadNode":
			return
		
		currentElement = currentElement as RoadNode
		currentElement.global_rotation = value

		rotator.moveToNode(currentElement)
	)

	# road properties ui
	roadPropertiesUI.roadSurfaceChanged.connect(func(surface: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.surfaceType = surface as PhysicsSurface.SurfaceType
	)

	roadPropertiesUI.wallMaterialChanged.connect(func(material: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.wallSurfaceType = material as PhysicsSurface.SurfaceType
	)

	roadPropertiesUI.supportTypeChanged.connect(func(type: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.supportType = type as RoadMeshGenerator.SupportType
	)

	roadPropertiesUI.supportMaterialChanged.connect(func(material: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.supportMaterial = material as PhysicsSurface.SurfaceType
	)

	roadPropertiesUI.supportBottomChanged.connect(func(bottom: float):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.supportBottomHeight = bottom
	)

	roadPropertiesUI.leftWallTypeChanged.connect(func(type: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.leftWallType = type as RoadMeshGenerator.WallTypes
	)

	roadPropertiesUI.leftWallStartHeightChanged.connect(func(height: float):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.leftWallStartHeight = height
	)

	roadPropertiesUI.leftWallEndHeightChanged.connect(func(height: float):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.leftWallEndHeight = height
	)

	roadPropertiesUI.leftRunoffMaterialChanged.connect(func(material: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.leftRunoffSurfaceType = material as PhysicsSurface.SurfaceType
	)

	roadPropertiesUI.rightWallTypeChanged.connect(func(type: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.rightWallType = type as RoadMeshGenerator.WallTypes
	)

	roadPropertiesUI.rightWallStartHeightChanged.connect(func(height: float):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.rightWallStartHeight = height
	)

	roadPropertiesUI.rightWallEndHeightChanged.connect(func(height: float):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.rightWallEndHeight = height
	)

	roadPropertiesUI.rightRunoffMaterialChanged.connect(func(material: int):
		if map.lastRoadElement == null:
			return

		map.lastRoadElement.rightRunoffSurfaceType = material as PhysicsSurface.SurfaceType
	)

	# pipe node properties ui

	pipeNodePropertiesUI.profileChanged.connect(func(profile: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "PipeNode":
			return
		
		currentElement = currentElement as PipeNode
		currentElement.profile = profile
	)

	pipeNodePropertiesUI.radiusChanged.connect(func(radius: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "PipeNode":
			return
		
		currentElement = currentElement as PipeNode
		currentElement.radius = radius
	)

	pipeNodePropertiesUI.flatChanged.connect(func(flat: bool):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "PipeNode":
			return
		
		currentElement = currentElement as PipeNode
		currentElement.flat = flat
	)

	pipeNodePropertiesUI.positionChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "PipeNode":
			return
		
		currentElement = currentElement as PipeNode
		currentElement.global_position = value
	
		rotator.moveToNode(currentElement)
		translator.global_position = value
	)

	pipeNodePropertiesUI.rotationChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "PipeNode":
			return
		
		currentElement = currentElement as PipeNode
		currentElement.global_rotation = value

		rotator.moveToNode(currentElement)
	)


	# pipe properties ui

	pipePropertiesUI.pipeSurfaceChanged.connect(func(surface: int):
		if map.lastPipeElement == null:
			return

		map.lastPipeElement.surfaceType = surface as PhysicsSurface.SurfaceType
	)

	# start line properties ui

	startLinePropertiesUI.widthChanged.connect(func(width: float):
		if currentElement == null || \
			(ClassFunctions.getClassName(currentElement) != "FunctionalStartLine" && \
			 ClassFunctions.getClassName(currentElement) != "ProceduralStartLine"):
			return
		
		# currentElement = currentElement as FunctionalStartLine
		currentElement.width = width
	)

	startLinePropertiesUI.heightChanged.connect(func(height: float):
		if currentElement == null || \
			(ClassFunctions.getClassName(currentElement) != "FunctionalStartLine" && \
			 ClassFunctions.getClassName(currentElement) != "ProceduralStartLine"):
			return
		
		# currentElement = currentElement as FunctionalStartLine
		currentElement.height = height
	)

	startLinePropertiesUI.positionChanged.connect(func(value: Vector3):
		if currentElement == null || \
			(ClassFunctions.getClassName(currentElement) != "FunctionalStartLine" && \
			 ClassFunctions.getClassName(currentElement) != "ProceduralStartLine"):
			return
		
		# currentElement = currentElement as FunctionalStartLine
		currentElement.global_position = value

		rotator.moveToNode(currentElement)
		translator.global_position = value
	)

	startLinePropertiesUI.rotationChanged.connect(func(value: Vector3):
		if currentElement == null || \
			(ClassFunctions.getClassName(currentElement) != "FunctionalStartLine" && \
			 ClassFunctions.getClassName(currentElement) != "ProceduralStartLine"):
			return
		
		# currentElement = currentElement as FunctionalStartLine
		currentElement.global_rotation = value

		rotator.moveToNode(currentElement)
	)

	# checkpoint properties ui

	checkpointPropertiesUI.ringWidthChanged.connect(func(width: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "FunctionalCheckpoint":
			return
		
		currentElement = currentElement as FunctionalCheckpoint
		currentElement.ringWidth = width
	)

	checkpointPropertiesUI.radiusChanged.connect(func(radius: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "FunctionalCheckpoint":
			return
		
		currentElement = currentElement as FunctionalCheckpoint
		currentElement.ringRadius = radius
	)

	checkpointPropertiesUI.positionChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "FunctionalCheckpoint":
			return
		
		currentElement = currentElement as FunctionalCheckpoint
		currentElement.global_position = value

		rotator.moveToNode(currentElement)
		translator.global_position = value
	)

	checkpointPropertiesUI.rotationChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "FunctionalCheckpoint":
			return
		
		currentElement = currentElement as FunctionalCheckpoint
		currentElement.global_rotation = value

		rotator.moveToNode(currentElement)
	)

	# led board ui

	ledBoardPropertiesUI.widthChanged.connect(func(width: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.width = width
	)

	ledBoardPropertiesUI.heightChanged.connect(func(height: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.height = height
	)

	ledBoardPropertiesUI.supportChanged.connect(func(support: bool):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.support = support
	)

	ledBoardPropertiesUI.supportBottomHeightChanged.connect(func(height: float):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.supportBottomHeight = height
	)

	ledBoardPropertiesUI.customTextureChanged.connect(func(usingOnlineTexture: bool):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.usingOnlineTexture = usingOnlineTexture
	)

	ledBoardPropertiesUI.localTextureChanged.connect(func(textureName: String):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.textureName = textureName
	)

	ledBoardPropertiesUI.customTextureUrlChanged.connect(func(textureUrl: String):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.customTextureUrl = textureUrl
	)

	ledBoardPropertiesUI.positionChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.global_position = value

		rotator.moveToNode(currentElement)
		translator.global_position = value
	)

	ledBoardPropertiesUI.rotationChanged.connect(func(value: Vector3):
		if currentElement == null || ClassFunctions.getClassName(currentElement) != "LedBoard":
			return
		
		currentElement = currentElement as LedBoard
		currentElement.global_rotation = value

		rotator.moveToNode(currentElement)
	)

	# scenery editor ui

	inputHandler.mouseMovedTo_Scenery.connect(
		map.onInputHandler_mouseMovedTo
	)

	sceneryEditorUI.modeChanged.connect(func(mode: int):
		map.setEditMode(mode)
	)

	sceneryEditorUI.directionChanged.connect(func(direction: int):
		map.setEditDirection(direction)
	)

	sceneryEditorUI.brushSizeChanged.connect(func(size: int):
		map.setBrushSize(size)
	)

	sceneryEditorUI.timeChanged.connect(func(time: float):
		map.setDayTime(time)
	)

	sceneryEditorUI.cloudChanged.connect(func(cloud: float):
		map.setCloudiness(cloud)
	)

	sceneryEditorUI.gloomyChanged.connect(func(gloomy: float):
		map.setGloomyness(gloomy)
	)

	sceneryEditorUI.groundSizeChanged.connect(func(size: int):
		map.setGroundSize(size)
	)

	# paint brush ui

	paintBrushUI.surfaceMaterialChanged.connect(func(surface: int):
		currentPaintBrushSurface = surface as PhysicsSurface.SurfaceType
	)

	# pause menu

	pauseMenu.resumePressed.connect(func(paused: bool = false):
		pauseMenu.visible = paused
		inputHandler.paused = paused
	)

	
	pauseMenu.exitPressed.connect(func():
		# AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), oldSoundVolume)
		if !VersionCheck.offline:
			var signalResponse = submitEditorStats(editorStats.getObject())
			await signalResponse
		else:
			AlertManager.showAlert(self, "Offline", "Please update the game to keep track of your stats")
		get_parent().editorExited.emit()
	)

	camera.positionChanged.connect(func(value: Vector3):
		setGizmoScale(value)
	)

@export
var defaultGizmoDistance: float = 220

func setGizmoScale(value: Vector3):
	var distanceToGizmos: float = (value - rotator.global_position).length()

	rotator.scale = (distanceToGizmos / defaultGizmoDistance) * Vector3.ONE
	translator.scale = (distanceToGizmos / defaultGizmoDistance) * Vector3.ONE

func setUIVisibility():
	roadNodePropertiesUI.visible = currentBuildMode == BuildMode.ROAD && currentEditorMode == EditorMode.BUILD
	roadPropertiesUI.visible = currentBuildMode == BuildMode.ROAD && currentEditorMode == EditorMode.BUILD

	pipeNodePropertiesUI.visible = currentBuildMode == BuildMode.PIPE && currentEditorMode == EditorMode.BUILD
	pipePropertiesUI.visible = currentBuildMode == BuildMode.PIPE && currentEditorMode == EditorMode.BUILD

	startLinePropertiesUI.visible = currentBuildMode == BuildMode.START && currentEditorMode == EditorMode.BUILD

	checkpointPropertiesUI.visible = currentBuildMode == BuildMode.CP && currentEditorMode == EditorMode.BUILD

	ledBoardPropertiesUI.visible = currentBuildMode == BuildMode.DECO && currentEditorMode == EditorMode.BUILD

	sceneryEditorUI.visible = currentEditorMode == EditorMode.SCENERY

	paintBrushUI.visible = currentEditorMode == EditorMode.PAINT




enum EditUIType {
	ROAD_NODE_PROPERTIES,
	ROAD_PROPERTIES,
	PIPE_NODE_PROPERTIES,
	PIPE_PROPERTIES,
	START_LINE_PROPERTIES,
	CP_PROPERTIES,
	LED_BOARD_PROPERTIES,
	NONE,
}

func setEditUIVisibility(ui: EditUIType):
	roadPropertiesUI.visible = ui == EditUIType.ROAD_PROPERTIES
	roadNodePropertiesUI.visible = ui == EditUIType.ROAD_NODE_PROPERTIES
	pipePropertiesUI.visible = ui == EditUIType.PIPE_PROPERTIES
	pipeNodePropertiesUI.visible = ui == EditUIType.PIPE_NODE_PROPERTIES
	startLinePropertiesUI.visible = ui == EditUIType.START_LINE_PROPERTIES
	checkpointPropertiesUI.visible = ui == EditUIType.CP_PROPERTIES
	ledBoardPropertiesUI.visible = ui == EditUIType.LED_BOARD_PROPERTIES

func setCurrentElement():
	
	gridMesh.visible = currentEditorMode == EditorMode.BUILD

	carPreview.visible = currentEditorMode == EditorMode.TEST && currentTestMode == TestMode.PLACING

	if currentEditorMode == EditorMode.BUILD:
		roadNode.visible = currentBuildMode == BuildMode.ROAD
		pipeNode.visible = currentBuildMode == BuildMode.PIPE
		startLine.visible = currentBuildMode == BuildMode.START
		checkpoint.visible = currentBuildMode == BuildMode.CP
		ledBoard.visible = currentBuildMode == BuildMode.DECO


		if currentBuildMode == BuildMode.ROAD:
			currentElement = roadNode
		elif currentBuildMode == BuildMode.PIPE:
			currentElement = pipeNode
		elif currentBuildMode == BuildMode.START:
			currentElement = startLine
		elif currentBuildMode == BuildMode.CP:
			currentElement = checkpoint
		elif currentBuildMode == BuildMode.DECO:
			currentElement = ledBoard
		
		else:
			print("[EditorEventListener.gd] Build Mode Not Implemented Yet!")
			currentElement = null
		return

	roadNode.visible = currentEditorMode == EditorMode.BUILD
	pipeNode.visible = currentEditorMode == EditorMode.BUILD
	startLine.visible = currentEditorMode == EditorMode.BUILD
	checkpoint.visible = currentEditorMode == EditorMode.BUILD
	ledBoard.visible = currentEditorMode == EditorMode.BUILD
	
	currentElement = null


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


func screenPointToRay_worldPos():
	var spaceState = get_world_3d().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * maxRaycastDistance
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 4294967295 - 16))
	
	# if rayArray.has("position"):
	# 	return rayArray["position"]
	# return null
	var data = {
		"position": Vector3.ZERO,
		"normal": Vector3.ZERO,
		"collider": null
	}

	if rayArray.has("position"):
		data["position"] = rayArray["position"]
	if rayArray.has("normal"):
		data["normal"] = rayArray["normal"]
	if rayArray.has("collider"):
		data["collider"] = rayArray["collider"]
	
	return data

@export
var ROTATION_STRENGTH: float = 0.01

const ROTATION_SNAP = deg_to_rad(5)

var rotateTreshold: float = 5

@export
var MOVE_SPEED: float = 1

const MOVE_SNAP = PrefabConstants.GRID_SIZE

var moveTreshold: float = 5

func handleMouseMovement(mousePos: Vector2):
	if capturedGizmo == null:
		return

	# print("[EditorEventListener.gd] Handling mouse movement; Gizmo: ", ClassFunctions.getClassName(capturedGizmo))
	
	if ClassFunctions.getClassName(capturedGizmo) == "RotatorGizmo":
		var delta = mousePos - lastMousePos
		if delta.length() < rotateTreshold:
			return
		
		var angleX = delta.x * ROTATION_STRENGTH
		if mousePos.y < gizmoCenter.y:
			angleX = -angleX
		
		var angleY = delta.y * ROTATION_STRENGTH
		if mousePos.x > gizmoCenter.x:
			angleY = -angleY
		
		var angle = angleX + angleY

		angle = round(angle / ROTATION_SNAP) * ROTATION_SNAP

		# print("[EditorEventListener.gd] Rotating gizmo by: ", angle)

		capturedGizmo.rotateGizmo(angle)

		lastMousePos = mousePos
	elif ClassFunctions.getClassName(capturedGizmo) == "TranslatorGizmo":
		var delta = mousePos - lastMousePos
		if delta.length() < moveTreshold:
			return
		
		var move = delta * MOVE_SPEED

		if moveAxis.y == 1:
			move.x = 0
		else:
			move.y = 0
		
		move = round(move / MOVE_SNAP) * MOVE_SNAP

		capturedGizmo.moveGizmo(move.x - move.y)

		lastMousePos = mousePos

func submitEditorStats(stats: Dictionary) -> Signal:
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 5
	request.request_completed.connect(onSubmitEditorStats_requestCompleted)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/stats/editor",
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(stats)
	)
	if httpError != OK:
		print("Error submitting time: " + error_string(httpError))
	
	return request.request_completed

func onSubmitEditorStats_requestCompleted(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	print("Editor stat Submit Response: ", _responseCode)
	return

var originalRespawn: Dictionary = {
	"position": Vector3.ZERO,
	"rotation": Vector3.ZERO
}

func startTesting(
	pos: Vector3,
	rot: Vector3
) -> void:
	currentTestMode = TestMode.DRIVING
	inputHandler.carTestDriving = true

	originalRespawn = {
		"position": pos,
		"rotation": rot
	}

	car.resumeMovement()
	car.setRespawnPositionFromDictionary(
		{
			"position": pos,
			"rotation": rot
		}
	)

	car.respawn()
	car.visible = true
	car.state.hasControl = true
	car.state.isReady = true

	carCamera.current = true
	camera.current = false
	camera.inputEnabled = false

	editorStats.increaseNrTests()

	editorSidebarUI.visible = false

	for cp in map.getCheckpoints():
		cp.bodyEnteredCheckpoint.connect(onCheckpoint_bodyEnteredCheckpoint)

	map.setIngame(true)

	carPreview.visible = false

	clearCarPath()

func stopTesting() -> void:
	currentTestMode = TestMode.PLACING
	inputHandler.carTestDriving = false

	editorSidebarUI.visible = true

	car.setRespawnPosition(Vector3(0, -1000, 0), Vector3(0, 0, 0))
	car.respawn()
	car.pauseMovement()
	car.visible = false
	carCamera.current = false
	camera.current = true
	camera.inputEnabled = true

	map.setIngame(false)

	carPreview.visible = true

	generateCarPath()

func onCheckpoint_bodyEnteredCheckpoint(car: CarController, checkpoint: FunctionalCheckpoint):
	car.setRespawnPositionFromDictionary(checkpoint.getRespawnPosition(0, 1))

func clearCarPath():
	for child in carPath.get_children():
		child.queue_free()


var carPathArray: Array = []
func generateCarPath():
	for path in carPathArray:
		var length = path.size()
		for i in length - 1:
			if i <= 2:
				continue
			carPath.add_child(PathDrawer3D.get3DLine(
				path[i].position + Vector3(0, 0.6, 0),
				path[i + 1].position + Vector3(0, 0.6, 0),
				path[i].getColor()
				)
			)

func loadMap(filePath: String) -> bool:
	var success = map.importTrack(filePath)
	if success:
		editorSidebarUI.trackNameLineEdit.text = map.trackName
		editorSidebarUI.lapCountSpinbox.value = map.lapCount
	
	return success