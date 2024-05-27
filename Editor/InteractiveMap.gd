extends Node3D
class_name InteractiveMap

const CURRENT_FORMAT_VERSION = 4

# metadata
var trackName: String = "track_" + str(Time.get_datetime_string_from_system().replace(":", "-"))
var lapCount: int = 3
var trackId: String = ""
var author: String = ""

# misc
var autoSaveInterval: float = 12

@onready var roadScene: PackedScene = preload("res://Editor/Road/RoadMeshGenerator.tscn")
@onready var pipeScene: PackedScene = preload("res://Editor/Pipe/PipeMeshGenerator.tscn")
@onready var startLineScene: PackedScene = preload("res://Editor/FunctionalElements/FunctionalStartLine.tscn")
@onready var checkpointScene: PackedScene = preload("res://Editor/FunctionalElements/FunctionalCheckpoint.tscn")
@onready var roadNodeScene: PackedScene = preload("res://Editor/Road/RoadNode.tscn")
@onready var pipeNodeScene: PackedScene = preload("res://Editor/Pipe/PipeNode.tscn")
@onready var ledBoardScene: PackedScene = preload("res://Editor/Props/LedBoard.tscn")


@onready var roadElements: Node3D = %RoadElements
var roadNodes: Node3D
var roadPieces: Node3D

var lastRoadNode: RoadNode
var lastRoadElement: RoadMeshGenerator

signal roadPreviewElementRequested()


@onready var pipeElements: Node3D = %PipeElements
var pipeNodes: Node3D
var pipePieces: Node3D

var lastPipeNode: PipeNode
var lastPipeElement: PipeMeshGenerator

signal pipePreviewElementRequested()


@onready var startParent: Node3D = %Start
var start: FunctionalStartLine

@onready var checkpoints: Node3D = %Checkpoints

@onready var deco: Node3D = %Deco
var ledBoards: Node3D

# scenery

@onready var scenery: EditableScenery = %EditableScenery
@onready var dynamicSky: DynamicSky = %DynamicSky

func _ready():
	roadNodes = roadElements.get_child(0)
	roadPieces = roadElements.get_child(1)

	pipeNodes = pipeElements.get_child(0)
	pipePieces = pipeElements.get_child(1)

	ledBoards = deco.get_child(0)



func addRoadNode(node: RoadNode, position: Vector3, rotation: Vector3, roadProperties: Dictionary):
	roadNodes.add_child(node)
	node.global_position = position
	node.global_rotation = rotation

	if lastRoadNode == null:
		var roadElement: RoadMeshGenerator = roadScene.instantiate()
		roadPieces.add_child(roadElement)
		roadElement.setProperties(roadProperties)
		roadElement.startNode = node
		lastRoadNode = node
		lastRoadElement = roadElement
		roadPreviewElementRequested.emit()
	else:
		if EditorMath.positionsMatch(lastRoadElement.startNode, node):
			roadNodes.remove_child(node)
			return
		lastRoadElement.endNode = node
		lastRoadElement.refreshAll()
		lastRoadElement.convertToPhysicsObject()
		lastRoadNode = null
		lastRoadElement = null

func onRoadPreviewElementProvided(node: RoadNode):
	if lastRoadElement != null:
		lastRoadElement.endNode	= node


func addPipeNode(node: PipeNode, position: Vector3, rotation: Vector3, pipeProperties: Dictionary):
	pipeNodes.add_child(node)
	node.global_position = position
	node.global_rotation = rotation

	if lastPipeNode == null:
		var pipeElement: PipeMeshGenerator = pipeScene.instantiate()
		pipePieces.add_child(pipeElement)
		pipeElement.setProperties(pipeProperties)
		pipeElement.startNode = node
		lastPipeNode = node
		lastPipeElement = pipeElement
		pipePreviewElementRequested.emit()
	else:
		if EditorMath.positionsMatch(lastPipeElement.startNode, node):
			pipeNodes.remove_child(node)
			return
		lastPipeElement.endNode = node
		lastPipeElement.refreshMesh()
		lastPipeElement.convertToPhysicsObject()
		lastPipeNode = null
		lastPipeElement = null
	
func onPipePreviewElementProvided(node: PipeNode):
	if lastPipeElement != null:
		lastPipeElement.endNode = node

func clearPreviews():
	if lastRoadElement != null:
		if lastRoadNode.meshGeneratorRefs.size() == 1:
			lastRoadNode.queue_free()
		else:
			lastRoadNode.meshGeneratorRefs.erase(lastRoadElement)
		lastRoadElement.queue_free()
		lastRoadElement = null
		lastRoadNode = null
	
	if lastPipeElement != null:
		if lastPipeNode.meshGeneratorRefs.size() == 1:
			lastPipeNode.queue_free()
		else:
			lastPipeNode.meshGeneratorRefs.erase(lastPipeElement)
		lastPipeElement.queue_free()
		lastPipeElement = null
		lastPipeNode = null

func setStartLine(position: Vector3, rotation: Vector3, properties: Dictionary):
	if start == null:
		start = startLineScene.instantiate()
		startParent.add_child(start)
	start.global_position = position
	start.global_rotation = rotation
	start.setProperties(properties, false)
	start.convertToPhysicsObject()

func addCheckpoint(node: FunctionalCheckpoint, position: Vector3, rotation: Vector3, properties: Dictionary):
	checkpoints.add_child(node)
	node.global_position = position
	node.global_rotation = rotation
	node.setProperties(properties, false)

func addLedBoard(node: LedBoard, position: Vector3, rotation: Vector3, properties: Dictionary):
	ledBoards.add_child(node)
	node.global_position = position
	node.global_rotation = rotation
	node.setProperties(properties, false)
	node.convertToPhysicsObject()

var lastSceneryVertexIndex: Vector2i = Vector2i(-1, -1)
var scenerySelectionSize: int = 1
var sceneryEditDirection: int = 1
var sceneryEditMode: int = SceneryEditorUI.NORMAL_MODE

var sceneryFlattenHeight: float = 0.0

func onInputHandler_mouseMovedTo(
	pos: Vector3,
	placePressed: bool,
) -> void:
	if pos != Vector3.INF:
		var newVertexIndex = scenery.getClosestVertex(pos)

		if newVertexIndex != lastSceneryVertexIndex && placePressed:
			if sceneryEditMode == SceneryEditorUI.NORMAL_MODE:
				scenery.moveVertex(newVertexIndex, sceneryEditDirection, scenerySelectionSize)
			elif sceneryEditMode == SceneryEditorUI.FLATTEN_MODE:
				scenery.flattenAtVertex(newVertexIndex, sceneryFlattenHeight, scenerySelectionSize)
				

		lastSceneryVertexIndex = newVertexIndex
		scenery.setSelection(true, lastSceneryVertexIndex, scenerySelectionSize)
	else:
		lastSceneryVertexIndex = Vector2i(-1, -1)
		scenery.setSelection(false, lastSceneryVertexIndex, scenerySelectionSize)

func onInputHandler_placePressed():
	if lastSceneryVertexIndex != Vector2i(-1, -1):
		if sceneryEditMode == SceneryEditorUI.NORMAL_MODE:
			scenery.moveVertex(lastSceneryVertexIndex, sceneryEditDirection, scenerySelectionSize)
		elif sceneryEditMode == SceneryEditorUI.FLATTEN_MODE:
			sceneryFlattenHeight = scenery.vertexHeights.getHeight(lastSceneryVertexIndex.y, lastSceneryVertexIndex.x)
			scenery.flattenAtVertex(lastSceneryVertexIndex, sceneryFlattenHeight, scenerySelectionSize)

func setDayTime(time: float):
	dynamicSky.day_time = time

func setCloudiness(cloudiness: float):
	dynamicSky.cloudiness = cloudiness

func setGloomyness(gloomyness: float):
	dynamicSky.gloomyness = gloomyness

func setBrushSize(size: int):
	scenerySelectionSize = size
	if lastSceneryVertexIndex != Vector2i(-1, -1):
		scenery.setSelection(true, lastSceneryVertexIndex, scenerySelectionSize)

func setEditDirection(direction: int):
	sceneryEditDirection = direction

func setEditMode(mode: int):
	sceneryEditMode = mode

func setGroundSize(size: int):
	scenery.groundSize = size


func removeRoadElement(node: RoadMeshGenerator):
	node.startNode.meshGeneratorRefs.erase(node) 
	node.endNode.meshGeneratorRefs.erase(node)

	while node.startNode.meshGeneratorRefs.find(null) != -1:
		node.startNode.meshGeneratorRefs.erase(null)
	if node.startNode.meshGeneratorRefs.size() == 0:
		node.startNode.queue_free()

	while node.endNode.meshGeneratorRefs.find(null) != -1:
		node.endNode.meshGeneratorRefs.erase(null)
	if node.endNode.meshGeneratorRefs.size() == 0:
		node.endNode.queue_free()

	node.queue_free()

func removePipeElement(node: PipeMeshGenerator):
	node.startNode.meshGeneratorRefs.erase(node) 
	node.endNode.meshGeneratorRefs.erase(node)

	while node.startNode.meshGeneratorRefs.find(null) != -1:
		node.startNode.meshGeneratorRefs.erase(null)
	if node.startNode.meshGeneratorRefs.size() == 0:
		node.startNode.queue_free()

	while node.endNode.meshGeneratorRefs.find(null) != -1:
		node.endNode.meshGeneratorRefs.erase(null)
	if node.endNode.meshGeneratorRefs.size() == 0:
		node.endNode.queue_free()

	node.queue_free()

func removeRoadNode(node: RoadNode):
	var roadNodes: Dictionary = {}
	var meshGeneratorRefs: Array = []
	meshGeneratorRefs.append_array(node.meshGeneratorRefs)

	for meshGenerator in meshGeneratorRefs:
		if !roadNodes.has(meshGenerator.startNode):
			roadNodes[meshGenerator.startNode] = null
		if !roadNodes.has(meshGenerator.endNode):
			roadNodes[meshGenerator.endNode] = null
		meshGenerator.startNode.meshGeneratorRefs.erase(meshGenerator)
		meshGenerator.endNode.meshGeneratorRefs.erase(meshGenerator)
		meshGenerator.queue_free()
	
	for roadNode in roadNodes.keys():
		while roadNode.meshGeneratorRefs.find(null) != -1:
			roadNode.meshGeneratorRefs.erase(null)
		if roadNode.meshGeneratorRefs.size() == 0:
			roadNode.queue_free()
	
	if node != null:
		node.queue_free()



func removePipeNode(node: PipeNode):
	var pipeNodes: Dictionary = {}
	var meshGeneratorRefs: Array = []
	meshGeneratorRefs.append_array(node.meshGeneratorRefs)

	for meshGenerator in meshGeneratorRefs:
		if !pipeNodes.has(meshGenerator.startNode):
			pipeNodes[meshGenerator.startNode] = null
		if !pipeNodes.has(meshGenerator.endNode):
			pipeNodes[meshGenerator.endNode] = null
		meshGenerator.startNode.meshGeneratorRefs.erase(meshGenerator)
		meshGenerator.endNode.meshGeneratorRefs.erase(meshGenerator)
		meshGenerator.queue_free()
	
	for pipeNode in pipeNodes.keys():
		while pipeNode.meshGeneratorRefs.find(null) != -1:
			pipeNode.meshGeneratorRefs.erase(null)
		if pipeNode.meshGeneratorRefs.size() == 0:
			pipeNode.queue_free()
	
	if node != null:
		node.queue_free()

func removeCheckpoint(node: FunctionalCheckpoint):
	node.queue_free()

func removeLedBoard(node: LedBoard):
	node.queue_free()


var validated: bool = false
var bestTotalTime: int = -1
var bestTotalReplay: String = ""
var bestLapTime: int = -1
var bestLapReplay: String = ""

func unvalidate():
	validated = false
	bestTotalTime = -1
	bestTotalReplay = ""
	bestLapTime = -1
	bestLapReplay = ""

func clearMap():
	for child in roadNodes.get_children():
		child.queue_free()
	for child in roadPieces.get_children():
		child.queue_free()
	for child in pipeNodes.get_children():
		child.queue_free()
	for child in pipePieces.get_children():
		child.queue_free()
	for child in checkpoints.get_children():
		child.queue_free()
	if start != null:
		start.queue_free()
	scenery.vertexHeights.reset(64)
	dynamicSky.reset()

	# TODO: clear operation stack

# save / load

func exportTrack(autosave: bool = false) -> bool:
	var trackData = {
		"format": CURRENT_FORMAT_VERSION,
		"metadata": {
			"trackName": trackName,
			"lapCount": lapCount,

			"validated": validated,
			"bestTotalTime": bestTotalTime,
			"bestTotalReplay": bestTotalReplay,
			"bestLapTime": bestLapTime,
			"bestLapReplay": bestLapReplay,
		},
	}

	# add start line
	if start == null:
		print("[InteractiveMap.gd] No start line found! Please add one.")
		return false
	trackData["start"] = start.getExportData()

	# add checkpoints
	if checkpoints.get_child_count() <= 0:
		print("[InteractiveMap.gd] No checkpoints found! Please add at least one.")
		return false
	trackData["checkpoints"] = []
	for checkpoint in checkpoints.get_children():
		trackData["checkpoints"].append(checkpoint.getExportData())

	# add terrain if modified
	var terrainData: Dictionary = scenery.getExportData()
	if terrainData.size() > 0:
		trackData["terrain"] = terrainData

	# add sky properties if modified
	var skyData: Dictionary = dynamicSky.getExportData()
	if skyData.size() > 0:
		trackData["sky"] = skyData

	# add roads
	if roadNodes.get_child_count() > 0:
		var roadData: Dictionary = {
			"nodes": [],
			"elements": [],
		}
		for node in roadNodes.get_children():
			roadData["nodes"].append(node.getExportData())
		for element in roadPieces.get_children():
			roadData["elements"].append(element.getExportData())
		trackData["roads"] = roadData

	# add pipes
	if pipeNodes.get_child_count() > 0:
		var pipeData: Dictionary = {
			"nodes": [],
			"elements": [],
		}
		for node in pipeNodes.get_children():
			pipeData["nodes"].append(node.getExportData())
		for element in pipePieces.get_children():
			pipeData["elements"].append(element.getExportData())
		trackData["pipes"] = pipeData

	trackData["deco"] = {}
	if ledBoards.get_child_count() > 0:
		trackData["deco"]["ledBoards"] = []
		for node in ledBoards.get_children():
			trackData["deco"]["ledBoards"].append(node.getExportData())

	# return false
	var path = "user://tracks/local/" + trackName + ".json"
	if autosave:
		path = "user://tracks/autosave/" + trackName + "_" + str(Time.get_datetime_string_from_system().replace(":", "-")) + ".json"
	var fileHandler = FileAccess.open(path, FileAccess.WRITE)

	if fileHandler == null:
		print("[InteractiveMap.gd] Error opening file to save into")
		return false

	fileHandler.store_string(JSON.stringify(trackData, "\t"))
	fileHandler.close()

	return true



func importTrack(fileName: String) -> bool:
	var path = fileName
	if !fileName.begins_with("user://tracks/local/") && !fileName.begins_with("user://tracks/downloaded/"):
		path = "user://tracks/local/" + fileName
	
	if fileName.begins_with("user://tracks/downloaded/"):
		trackId = fileName.split("/")[-1].split(".")[0]
	else:
		trackId = ""

	var fileHandler = FileAccess.open(path, FileAccess.READ)

	if fileHandler == null:
		print("[InteractiveMap.gd] Error opening file to load from", path)
		return false
	
	var trackData = JSON.parse_string(fileHandler.get_as_text())

	if trackData == null:
		print("[InteractiveMap.gd] Error parsing JSON when loading map")
		return false
	

	if !trackData.has("metadata"):
		print("[InteractiveMap.gd] No metadata found in the file")
		return false

	if trackData["metadata"].has("author"):
		author = trackData["metadata"]["author"]
	else:
		author = ""
	
	if !trackData.has("format"):
		print("[InteractiveMap.gd] No format version found in the file")
		return false

	if trackData["format"] != CURRENT_FORMAT_VERSION:
		print("[InteractiveMap.gd] Error loading map: wrong format version")

		# handle different format versions here
		
		# if !path.begins_with("user://tracks/downloaded/"):
		# 	fileHandler.close()

		# 	MapUpdater.updateMap(trackData, path)

		# 	fileHandler = FileAccess.open(path, FileAccess.READ)
		# 	trackData = JSON.parse_string(fileHandler.get_as_text())
		# else:
		# 	return false
		return false
	
	clearMap()

	trackName = trackData["metadata"]["trackName"]
	lapCount = trackData["metadata"]["lapCount"]

	if !trackData.has("start"):
		print("[InteractiveMap.gd] No start line found in the file")
		# return false

	setStartLine(
		str_to_var(trackData["start"]["position"]),
		str_to_var(trackData["start"]["rotation"]),
		trackData["start"]
	)

	if !trackData.has("checkpoints"):
		print("[InteractiveMap.gd] No checkpoints found in the file")
		# return false
	
	var checkpointIndex = 0
	for checkpointData in trackData["checkpoints"]:
		var checkpoint: FunctionalCheckpoint = checkpointScene.instantiate()
		addCheckpoint(
			checkpoint,
			str_to_var(checkpointData["position"]),
			str_to_var(checkpointData["rotation"]),
			checkpointData
		)
		checkpoint.index = checkpointIndex
		checkpointIndex += 1
	
	if trackData.has("terrain"):
		scenery.importData(trackData["terrain"])
	
	if trackData.has("sky"):
		dynamicSky.importData(trackData["sky"])
		
	if trackData.has("roads"):
		var nodeIds: Dictionary = {}

		for nodeData in trackData["roads"]["nodes"]:
			var node: RoadNode = roadNodeScene.instantiate()
			roadNodes.add_child(node)
			node.importData(nodeData)
			nodeIds[nodeData["id"]] = node
		
		for elementData in trackData["roads"]["elements"]:
			var element: RoadMeshGenerator = roadScene.instantiate()
			roadPieces.add_child(element)
			element.importData(elementData, nodeIds)
			element.refreshAll()
			element.convertToPhysicsObject()
	
	if trackData.has("pipes"):
		var nodeIds: Dictionary = {}

		for nodeData in trackData["pipes"]["nodes"]:
			var node: PipeNode = pipeNodeScene.instantiate()
			pipeNodes.add_child(node)
			node.importData(nodeData)
			nodeIds[nodeData["id"]] = node
		
		for elementData in trackData["pipes"]["elements"]:
			var element: PipeMeshGenerator = pipeScene.instantiate()
			pipePieces.add_child(element)
			element.importData(elementData, nodeIds)
			element.refreshMesh()
			element.convertToPhysicsObject()
	
	if trackData["deco"].has("ledBoards"):
		for ledBoardData in trackData["deco"]["ledBoards"]:
			var ledBoard: LedBoard = ledBoardScene.instantiate() as LedBoard
			addLedBoard(
				ledBoard,
				str_to_var(ledBoardData["position"]),
				str_to_var(ledBoardData["rotation"]),
				ledBoardData
			)

	fileHandler.close()

	return true

# ingame functionality

func setIngame(ingame: bool = true) -> void:
	for child in roadNodes.get_children():
		child.setIngame()

	for child in pipeNodes.get_children():
		child.setIngame()

	for child in checkpoints.get_children():
		child.setArrowVisibility(!ingame)
	
	if start != null:
		start.setArrowVisibility(!ingame)

func getCheckpoints():
	return checkpoints.get_children()

func getCheckpointCount():
	return checkpoints.get_child_count()

func setNewValidationTime(totalTime: int, bestLap: int, replay: String):
	validated = true
	if bestTotalTime == -1 || totalTime < bestTotalTime:
		bestTotalTime = totalTime
		bestTotalReplay = replay
		exportTrack()
	if bestLapTime == -1 || bestLap < bestLapTime:
		bestLapTime = bestLap
		bestLapReplay = replay
		exportTrack()
