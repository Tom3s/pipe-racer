extends Node3D
class_name Map

var trackPieces: Node3D

@onready
var roadMaterial = preload("res://Tracks/RacetrackMaterial.tres")

var operationStack: Array = []

var lastOperationIndex: int = -1

const PLACED = 0
const REMOVED = 1
const UPDATED = 2

signal undidLastOperation()
signal redidLastOperation()
signal noOperationToBeUndone()
signal noOperationToBeRedone()

# Called when the node enters the scene tree for the first time.
func _ready():
	trackPieces = %TrackPieces


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func addPrefab(prefab: PrefabProperties, prefabPosition: Vector3, prefabRotation: Vector3):
	trackPieces.add_child(prefab)
	prefab.global_position = prefabPosition
	prefab.global_rotation = prefabRotation
	prefab.mesh.surface_set_material(0, roadMaterial)
	prefab.create_trimesh_collision()

	if operationStack.size() > lastOperationIndex + 1:
		operationStack.resize(lastOperationIndex + 1)

	operationStack.append({
		"prefab": prefab,
		"operation": PLACED
	})
	lastOperationIndex += 1

func undo():
	if lastOperationIndex < 0:
		# print("No more operations to undo")
		noOperationToBeUndone.emit()
		return

	var lastOperation = operationStack[lastOperationIndex]

	if lastOperation["operation"] == PLACED:
		for child in lastOperation["prefab"].get_children(true):
			child.queue_free()
		trackPieces.remove_child(lastOperation["prefab"])
		lastOperationIndex -= 1
		undidLastOperation.emit()

func redo():
	if lastOperationIndex >= operationStack.size() - 1:
		# print("No more operations to redo")
		noOperationToBeRedone.emit()
		return

	lastOperationIndex += 1
	var lastOperation = operationStack[lastOperationIndex]

	if lastOperation["operation"] == PLACED:
		trackPieces.add_child(lastOperation["prefab"])
		lastOperation["prefab"].create_trimesh_collision()
		redidLastOperation.emit()