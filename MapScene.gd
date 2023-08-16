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


func add(prefabMesher: PrefabMesher):
	var prefab = prefabMesher.objectFromData()
	addPrefab(prefab, prefabMesher.position, prefabMesher.rotation)
	storeAddPrefab(prefab)

func addPrefab(prefab: PrefabProperties, prefabPosition: Vector3 = Vector3.INF, prefabRotation: Vector3 = Vector3.INF):
	trackPieces.add_child(prefab)
	if prefabPosition != Vector3.INF:
		prefab.global_position = prefabPosition
	if prefabRotation != Vector3.INF:
		prefab.global_rotation = prefabRotation
	prefab.mesh.surface_set_material(0, roadMaterial)
	prefab.create_trimesh_collision()

func storeAddPrefab(prefab: PrefabProperties):
	if operationStack.size() > lastOperationIndex + 1:
		operationStack.resize(lastOperationIndex + 1)

	operationStack.append({
		"prefab": prefab,
		"operation": PLACED
	})
	lastOperationIndex += 1

func remove(prefab: PrefabProperties):
	removePrefab(prefab)
	storeRemovePrefab(prefab)

func removePrefab(prefab: PrefabProperties):
	for child in prefab.get_children(true):
		child.queue_free()
	trackPieces.remove_child(prefab)

func storeRemovePrefab(prefab: PrefabProperties):
	if operationStack.size() > lastOperationIndex + 1:
		operationStack.resize(lastOperationIndex + 1)

	operationStack.append({
		"prefab": prefab,
		"operation": REMOVED
	})
	lastOperationIndex += 1

func update(oldPrefab: PrefabProperties, prefabMesher: PrefabMesher):
	removePrefab(oldPrefab)
	var prefab = prefabMesher.objectFromData()
	addPrefab(prefab, prefabMesher.position, prefabMesher.rotation)

	storeUpdatePrefab(oldPrefab, prefab)

func storeUpdatePrefab(oldPrefab: PrefabProperties, newPrefab: PrefabProperties):
	if operationStack.size() > lastOperationIndex + 1:
		operationStack.resize(lastOperationIndex + 1)

	operationStack.append({
		"oldPrefab": oldPrefab,
		"newPrefab": newPrefab,
		"operation": UPDATED
	})
	lastOperationIndex += 1

func undo():
	if lastOperationIndex < 0:
		# print("No more operations to undo")
		noOperationToBeUndone.emit()
		return

	var lastOperation = operationStack[lastOperationIndex]

	if lastOperation["operation"] == PLACED:
		# for child in lastOperation["prefab"].get_children(true):
		# 	child.queue_free()
		# trackPieces.remove_child(lastOperation["prefab"])
		removePrefab(lastOperation["prefab"])
		lastOperationIndex -= 1
		undidLastOperation.emit()
	elif lastOperation["operation"] == REMOVED:
		addPrefab(lastOperation["prefab"])
		lastOperationIndex -= 1
		undidLastOperation.emit()
	elif lastOperation["operation"] == UPDATED:
		removePrefab(lastOperation["newPrefab"])
		addPrefab(lastOperation["oldPrefab"])
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
		addPrefab(lastOperation["prefab"])
		redidLastOperation.emit()
	elif lastOperation["operation"] == REMOVED:
		removePrefab(lastOperation["prefab"])
		redidLastOperation.emit()
	elif lastOperation["operation"] == UPDATED:
		removePrefab(lastOperation["oldPrefab"])
		addPrefab(lastOperation["newPrefab"])
		redidLastOperation.emit()