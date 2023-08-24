extends Node3D
class_name Map

var StartScene = load("res://Start.tscn")

var trackPieces: Node3D

@onready
# var roadMaterial = preload("res://Tracks/RacetrackMaterial.tres")
var materials = [
	preload("res://Tracks/RacetrackMaterial.tres"), # ROAD
	preload("res://grass2.tres") # GRASS
]

var frictions = [
	1.0, # ROAD
	0.3 # GRASS
]

var operationStack: Array = []

var lastOperationIndex: int = -1

const PLACED = 0
const REMOVED = 1
const UPDATED = 2
const PLACED_START = 3

signal undidLastOperation()
signal redidLastOperation()
signal noOperationToBeUndone()
signal noOperationToBeRedone()

var start
const START_MAGIC_VECTOR = Vector3(0.134, 1.224, -0.0788)

# Called when the node enters the scene tree for the first time.
func _ready():
	trackPieces = %TrackPieces
	start = StartScene.instantiate()
	add_child(start)
	start.global_position = START_MAGIC_VECTOR
	start.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add(prefabMesher: PrefabMesher):
	var prefab = prefabMesher.objectFromData()
	addPrefab(prefab)
	storeAddPrefab(prefab)

func addPrefab(prefab: PrefabProperties, prefabPosition: Vector3 = Vector3.INF, prefabRotation: Vector3 = Vector3.INF):
	trackPieces.add_child(prefab)
	var prefabData = prefab.prefabData
	# if prefabPosition != Vector3.INF:
	# 	prefab.global_position = prefabPosition
	# if prefabRotation != Vector3.INF:
	# 	prefab.global_rotation = prefabRotation
	prefab.global_position = prefabData["global_position"]
	prefab.global_rotation = prefabData["global_rotation"]
	prefab.mesh.surface_set_material(0, materials[prefabData["roadType"]])
	prefab.create_trimesh_collision()

func storeAddPrefab(prefab: PrefabProperties):
	if operationStack.size() > lastOperationIndex + 1:
		operationStack.resize(lastOperationIndex + 1)

	operationStack.append({
		"prefab": prefab,
		"operation": PLACED
	})
	lastOperationIndex += 1

func addStart(startObject):
	var oldPosition = start.global_position
	var oldRotation = start.global_rotation
	
	updateStartPosition(startObject.global_position, startObject.global_rotation)
	storeAddStartObject(oldPosition, oldRotation, start.global_position, start.global_rotation)

func updateStartPosition(newPosition: Vector3, newRotation: Vector3):
	start.global_position = newPosition
	start.global_rotation = newRotation

	start.visible = start.global_position != START_MAGIC_VECTOR

func storeAddStartObject(oldPosition: Vector3, oldRotation: Vector3, newPosition: Vector3, newRotation: Vector3):
	if operationStack.size() > lastOperationIndex + 1:
		operationStack.resize(lastOperationIndex + 1)

	operationStack.append({
		"oldPosition": oldPosition,
		"oldRotation": oldRotation,
		"newPosition": newPosition,
		"newRotation": newRotation,
		"operation": PLACED_START
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
	var prefab = prefabMesher.objectFromData()

	if oldPrefab.equals(prefab):
		return

	removePrefab(oldPrefab)
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
	elif lastOperation["operation"] == PLACED_START:
		updateStartPosition(lastOperation["oldPosition"], lastOperation["oldRotation"])
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
	elif lastOperation["operation"] == PLACED_START:
		updateStartPosition(lastOperation["newPosition"], lastOperation["newRotation"])
		redidLastOperation.emit()
