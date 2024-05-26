extends Node3D
class_name InteractiveMap

@onready var roadScene: PackedScene = preload("res://Editor/Road/RoadMeshGenerator.tscn")
@onready var pipeScene: PackedScene = preload("res://Editor/Pipe/PipeMeshGenerator.tscn")
@onready var startLineScene: PackedScene = preload("res://Editor/FunctionalElements/FunctionalStartLine.tscn")

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


@onready var start: Node3D = %Start
var startLine: FunctionalStartLine

# scenery

@onready var scenery: EditableScenery = %EditableScenery
@onready var dynamicSky: DynamicSky = %DynamicSky

func _ready():
	roadNodes = roadElements.get_child(0)
	roadPieces = roadElements.get_child(1)

	pipeNodes = pipeElements.get_child(0)
	pipePieces = pipeElements.get_child(1)


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
		lastRoadElement.queue_free()
		lastRoadElement = null
		lastRoadNode.queue_free()
		lastRoadNode = null
	
	if lastPipeElement != null:
		lastPipeElement.queue_free()
		lastPipeElement = null
		lastPipeNode.queue_free()
		lastPipeNode = null

func setStartLine(position: Vector3, rotation: Vector3, properties: Dictionary):
	if startLine == null:
		startLine = startLineScene.instantiate()
		start.add_child(startLine)
	startLine.global_position = position
	startLine.global_rotation = rotation
	startLine.setProperties(properties)
	startLine.convertToPhysicsObject()
	

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

	while node.meshGeneratorRefs.find(null) != -1:
		node.meshGeneratorRefs.erase(null)
	if node.startNode.meshGeneratorRefs.size() == 0:
		node.startNode.queue_free()

	while node.meshGeneratorRefs.find(null) != -1:
		node.meshGeneratorRefs.erase(null)
	if node.endNode.meshGeneratorRefs.size() == 0:
		node.endNode.queue_free()

	node.queue_free()

func removePipeElement(node: PipeMeshGenerator):
	node.startNode.meshGeneratorRefs.erase(node) 
	node.endNode.meshGeneratorRefs.erase(node)

	while node.meshGeneratorRefs.find(null) != -1:
		node.meshGeneratorRefs.erase(null)
	if node.startNode.meshGeneratorRefs.size() == 0:
		node.startNode.queue_free()

	while node.meshGeneratorRefs.find(null) != -1:
		node.meshGeneratorRefs.erase(null)
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
