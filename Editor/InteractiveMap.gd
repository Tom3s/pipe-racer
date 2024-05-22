extends Node3D
class_name InteractiveMap

@onready var roadScene: PackedScene = preload("res://Editor/Road/RoadMeshGenerator.tscn")
@onready var pipeScene: PackedScene = preload("res://Editor/Pipe/PipeMeshGenerator.tscn")

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
		lastRoadElement.endNode = node
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
		lastPipeElement.endNode = node
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