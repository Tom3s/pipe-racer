extends Node3D
class_name EditorEventListener

@onready var inputHandler: EditorInputHandler = %EditorInputHandler
@onready var camera: EditorCamera = %EditorCamera
# @onready var previewElementParent: Node3D = %PreviewElement
@onready var map: InteractiveMap = %InteractiveMap

@onready var roadNode: RoadNode = %RoadNode
@onready var pipeNode: PipeNode = %PipeNode
@onready var startLine: ProceduralStartLine = %StartLine
@onready var checkpoint: FunctionalCheckpoint = %Checkpoint
var currentElement: Node3D = null

@onready var gridMesh: MeshInstance3D = %GridMesh

@onready var editorSidebarUI: EditorSidebarUI = %EditorSidebarUI

@onready var roadNodePropertiesUI: RoadNodePropertiesUI = %RoadNodePropertiesUI
@onready var roadPropertiesUI: RoadPropertiesUI = %RoadPropertiesUI

@onready var pipeNodePropertiesUI: PipeNodePropertiesUI = %PipeNodePropertiesUI
@onready var pipePropertiesUI: PipePropertiesUI = %PipePropertiesUI

@onready var startLinePropertiesUI: StartLinePropertiesUI = %StartLinePropertiesUI

@onready var checkpointPropertiesUI: CheckpointPropertiesUI = %CheckpointPropertiesUI

@onready var sceneryEditorUI: SceneryEditorUI = %SceneryEditorUI


# gizmos
@onready var rotator: Rotator = %Rotator
@onready var translator: Translator = %Translator

enum EditorMode {
	BUILD,
	EDIT,
	DELETE,
	SCENERY,
	PAINT,
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

var capturedGizmo: Node3D = null

var gizmoCenter: Vector2 = Vector2.ZERO
var rotationAxis: Vector3 = Vector3.ZERO
var moveAxis: Vector3 = Vector3.ZERO


var lastMousePos: Vector2 = Vector2.ZERO

func _ready():
	setUIVisibility()
	setCurrentElement()

	connectSignals()

	rotator.disable()
	translator.disable()

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
			elif ClassFunctions.getClassName(currentElement) == "ProceduralStartLine":
				map.setStartLine(
					currentElement.global_position, 
					currentElement.global_rotation,
					currentElement.getProperties()
				)
			elif ClassFunctions.getClassName(currentElement) == "FunctionalCheckpoint":
				map.addCheckpoint(
					currentElement.getCopy(),
					currentElement.global_position, 
					currentElement.global_rotation,
					currentElement.getProperties()
				)
			

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
					for meshGenerator in currentElement.meshGeneratorRefs:
						meshGenerator.convertToPhysicsObject()

				if currentElement != null && \
					(ClassFunctions.getClassName(currentElement) == "FunctionalStartLine"):
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
					roadNodePropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.ROAD_NODE_PROPERTIES)
					rotator.enable()
					rotator.moveToNode(currentElement)
					translator.enable()
					translator.global_position = currentElement.global_position
				elif ClassFunctions.getClassName(collidedObject) == "PipeNode":
					# map.lastPipeNode = collidedObject
					currentElement = collidedObject
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
				elif ClassFunctions.getClassName(collidedObject) == "FunctionalCheckpoint":
					currentElement = collidedObject
					checkpointPropertiesUI.setProperties(collidedObject.getProperties())
					setEditUIVisibility(EditUIType.CP_PROPERTIES)
					rotator.enable()
					rotator.moveToNode(currentElement)
					translator.enable()
					translator.global_position = currentElement.global_position
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
			else:
				print("[EditorEventListener.gd] Class of collided Object (delete mode): ", ClassFunctions.getClassName(collidedObject)) 

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
		# handle mouse movement
		handleMouseMovement(mousePos)
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
				pass
	)

	translator.positionChanged.connect(func(newPos: Vector3):
		if currentElement != null:
			currentElement.global_position = newPos
			gridMesh.global_position = newPos
			rotator.moveToNode(currentElement)
			if ClassFunctions.getClassName(currentElement) == "RoadNode":
				roadNodePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "PipeNode":
				pipeNodePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "FunctionalStartLine":
				startLinePropertiesUI.setProperties(currentElement.getProperties())
			elif ClassFunctions.getClassName(currentElement) == "FunctionalCheckpoint":
				checkpointPropertiesUI.setProperties(currentElement.getProperties())
				pass
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
		currentEditorMode = mode
		inputHandler.editorMode = mode

		if mode == EditorMode.BUILD:
			map.clearPreviews()

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
					for meshGenerator in currentElement.meshGeneratorRefs:
						meshGenerator.convertToPhysicsObject()
					
			currentElement = null

			var roadNodeProperties = roadNodePropertiesUI.getProperties()
			roadNodeProperties.erase("position")
			roadNodeProperties.erase("rotation")
			roadNode.setProperties(roadNodeProperties)

			var pipeNodeProperties = pipeNodePropertiesUI.getProperties()
			pipeNodeProperties.erase("position")
			pipeNodeProperties.erase("rotation")
			pipeNode.setProperties(pipeNodeProperties)

			var startLineProperties = startLinePropertiesUI.getProperties()
			startLineProperties.erase("position")
			startLineProperties.erase("rotation")

			var checkpointProperties = checkpointPropertiesUI.getProperties()
			checkpointProperties.erase("position")
			checkpointProperties.erase("rotation")

			rotator.disable()
			translator.disable()

		setUIVisibility()
		setCurrentElement()
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

func setUIVisibility():
	roadNodePropertiesUI.visible = currentBuildMode == BuildMode.ROAD && currentEditorMode == EditorMode.BUILD
	roadPropertiesUI.visible = currentBuildMode == BuildMode.ROAD && currentEditorMode == EditorMode.BUILD

	pipeNodePropertiesUI.visible = currentBuildMode == BuildMode.PIPE && currentEditorMode == EditorMode.BUILD
	pipePropertiesUI.visible = currentBuildMode == BuildMode.PIPE && currentEditorMode == EditorMode.BUILD

	startLinePropertiesUI.visible = currentBuildMode == BuildMode.START && currentEditorMode == EditorMode.BUILD

	checkpointPropertiesUI.visible = currentBuildMode == BuildMode.CP && currentEditorMode == EditorMode.BUILD

	sceneryEditorUI.visible = currentEditorMode == EditorMode.SCENERY

enum EditUIType {
	ROAD_NODE_PROPERTIES,
	ROAD_PROPERTIES,
	PIPE_NODE_PROPERTIES,
	PIPE_PROPERTIES,
	START_LINE_PROPERTIES,
	CP_PROPERTIES,
	NONE,
}

func setEditUIVisibility(ui: EditUIType):
	roadPropertiesUI.visible = ui == EditUIType.ROAD_PROPERTIES
	roadNodePropertiesUI.visible = ui == EditUIType.ROAD_NODE_PROPERTIES
	pipePropertiesUI.visible = ui == EditUIType.PIPE_PROPERTIES
	pipeNodePropertiesUI.visible = ui == EditUIType.PIPE_NODE_PROPERTIES
	startLinePropertiesUI.visible = ui == EditUIType.START_LINE_PROPERTIES
	checkpointPropertiesUI.visible = ui == EditUIType.CP_PROPERTIES

func setCurrentElement():
	
	gridMesh.visible = currentEditorMode == EditorMode.BUILD

	if currentEditorMode == EditorMode.BUILD:
		roadNode.visible = currentBuildMode == BuildMode.ROAD
		pipeNode.visible = currentBuildMode == BuildMode.PIPE
		startLine.visible = currentBuildMode == BuildMode.START
		checkpoint.visible = currentBuildMode == BuildMode.CP

		if currentBuildMode == BuildMode.ROAD:
			currentElement = roadNode
		elif currentBuildMode == BuildMode.PIPE:
			currentElement = pipeNode
		elif currentBuildMode == BuildMode.START:
			currentElement = startLine
		elif currentBuildMode == BuildMode.CP:
			currentElement = checkpoint
		
		else:
			print("[EditorEventListener.gd] Build Mode Not Implemented Yet!")
			currentElement = null
		return

	roadNode.visible = currentEditorMode == EditorMode.BUILD
	pipeNode.visible = currentEditorMode == EditorMode.BUILD
	startLine.visible = currentEditorMode == EditorMode.BUILD
	checkpoint.visible = currentEditorMode == EditorMode.BUILD
	
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
