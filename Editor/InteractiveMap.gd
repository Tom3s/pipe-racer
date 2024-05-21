extends Node3D
class_name InteractiveMap

@onready var roadScene: PackedScene = preload("res://Editor/Road/RoadMeshGenerator.tscn")

@onready var roadElements: Node3D = %RoadElements
var roadNodes: Node3D
var roadPieces: Node3D

var lastRoadNode: RoadNode
var lastRoadElement: RoadMeshGenerator

signal roadPreviewElementRequested()

func _ready():
	roadNodes = roadElements.get_child(0)
	roadPieces = roadElements.get_child(1)


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
