extends Node3D
class_name InteractiveMap

@onready var roadElements: Node3D = %RoadElements
var roadNodes: Node3D
var roadPieces: Node3D

func _ready():
	roadNodes = roadElements.get_child(0)
	roadPieces = roadElements.get_child(1)


func addRoadNode(node: RoadNode):
	roadNodes.add_child(node)
	
