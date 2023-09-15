extends Node3D
class_name Map

const CURRENT_FORMAT_VERSION = 1

var StartScene = preload("res://Start.tscn")
@onready
var PropPlacer = preload("res://PropPlacer.tscn")

var trackPieces: Node3D
var checkPointSystem: Node3D
var props: Node3D

var trackName: String = "track_" + str(Time.get_datetime_string_from_system().replace(":", "-"))
var lapCount: int = 3
var trackId: String = ""
var author: String = ""

var autoSaveInterval: float = 12

@onready
# var roadMaterial = preload("res://Tracks/RacetrackMaterial.tres")
var materials = [
	preload("res://Tracks/AsphaltMaterial.tres"), # ROAD
	preload("res://grass2.tres"), # GRASS
	preload("res://Track Props/DirtMaterial.tres"), # DIRT
	preload("res://Track Props/BoosterMaterial.tres"), # BOOSTER	
	preload("res://Track Props/BoosterMaterialReversed.tres") # REVERSE BOOSTER	
]

var frictions = [
	1.0, # ROAD
	0.3, # GRASS
	0.3, # DIRT
	1.0, # BOOSTER
	1.0 # REVERSE BOOSTER
]

var accelerationMultipliers = [
	1.0, # ROAD
	0.2, # GRASS
	1.0, # DIRT
	3.0, # BOOSTER
	3.0 # REVERSE BOOSTER
]

var smokeParticles =[
	true, # ROAD
	true, # GRASS
	false, # DIRT
	true, # BOOSTER
	true # REVERSE BOOSTER
]

var operationStack: Array = []

var lastOperationIndex: int = -1

const PLACED = 0
const REMOVED = 1
const UPDATED = 2
const PLACED_START = 3
const PLACED_CP = 4
const REMOVED_CP = 5
const UPDATED_CP = 6
const PLACED_PROP = 7
const REMOVED_PROP = 8
const UPDATED_PROP = 9

signal undidLastOperation()
signal redidLastOperation()
signal noOperationToBeUndone()
signal noOperationToBeRedone()
signal canUndo(value: bool)
signal canRedo(value: bool)

signal mapLoaded(trackName: String, lapCount: int)

var start: Start
const START_MAGIC_VECTOR = Vector3(0.134, 1.224, -0.0788)
const START_OFFSET = Vector3(0, 9.15, 0)

@export_file("*.json")
var loadFrom: String:
	set(newFile):
		loadFrom = loadFromChanged(newFile)
		print("loadFrom changed to: ", loadFrom)
		# emit_signal("loadFromChanged", loadFrom)
		# load(loadFrom
	get:
		return loadFrom

func loadFromChanged(newFile: String) -> String:
	if newFile == "":
		return newFile
	
	if is_node_ready():
		loadMap(newFile)
		# return newFile
	
	return newFile

var connectionPoints: Array[Dictionary] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	trackPieces = %TrackPieces
	checkPointSystem = %CheckPointSystem
	props = %Props

	if find_child("Start") != null:
		start = find_child("Start")
	else:
		start = StartScene.instantiate()
		add_child(start)
		start.global_position = START_MAGIC_VECTOR
		start.visible = false
	
	if loadFrom != "":
		loadMap(loadFrom)

	setupAutoSave()

func setupAutoSave():
	var timer = Timer.new()
	timer.wait_time = autoSaveInterval * 60
	timer.one_shot = false
	add_child(timer)
	timer.start()
	timer.timeout.connect(autoSave)

func autoSave():
	saveToJSON(true)

func add(prefabMesher: PrefabMesher):
	var prefab: PrefabProperties = prefabMesher.objectFromData()
	addPrefab(prefab)
	storeAddPrefab(prefab)

func addPrefab(prefab: PrefabProperties, _prefabPosition: Vector3 = Vector3.INF, _prefabRotation: Vector3 = Vector3.INF):
	trackPieces.add_child(prefab)
	var prefabData = prefab.prefabData
	# if prefabPosition != Vector3.INF:
	# 	prefab.global_position = prefabPosition
	# if prefabRotation != Vector3.INF:
	# 	prefab.global_rotation = prefabRotation
	# prefab.global_position = prefabData["position"]
	# prefab.global_rotation = prefabData["rotation"]

	prefab.global_position = Vector3(prefabData["positionX"], prefabData["positionY"], prefabData["positionZ"])
	prefab.global_rotation = Vector3(0, prefabData["rotation"], 0)

	prefab.mesh.surface_set_material(0, materials[prefabData["roadType"]])
	prefab.friction = frictions[prefabData["roadType"]]
	prefab.accelerationPenalty = accelerationMultipliers[prefabData["roadType"]]
	prefab.smokeParticles = smokeParticles[prefabData["roadType"]]
	prefab.create_trimesh_collision()

	prefab.calculateCorners()

	tryAddingConnectionPoints(prefab.topLeft, prefab.topRight, prefab.bottomLeft, prefab.bottomRight)

func tryAddingConnectionPoints(topLeft: Vector3, topRight: Vector3, bottomLeft: Vector3, bottomRight: Vector3):
	var frontFound = false
	var backFound = false
	for connectionPoint in connectionPoints:
		if (connectionPoint["right"].is_equal_approx(topLeft) && connectionPoint["left"].is_equal_approx(topRight)):
			connectionPoints.erase(connectionPoint)
			frontFound = true
			break
		elif (connectionPoint["right"].is_equal_approx(bottomRight) && connectionPoint["left"].is_equal_approx(bottomLeft)):
			connectionPoints.erase(connectionPoint)
			backFound = true
			break


	if !frontFound:
		connectionPoints.append({
			"left": topLeft,
			"right": topRight,
		})
	if !backFound:
		connectionPoints.append({
			"left": bottomRight,
			"right": bottomLeft,
		})

func storeAddPrefab(prefab: PrefabProperties):
	safeResizeStack()

	operationStack.append({
		"prefab": prefab,
		"operation": PLACED
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()

func addStart(startObject):
	var oldPosition = start.global_position
	var oldRotation = start.global_rotation
	
	updateStartPosition(startObject.global_position + START_OFFSET, startObject.global_rotation)
	storeAddStartObject(oldPosition, oldRotation, start.global_position, start.global_rotation)

func updateStartPosition(newPosition: Vector3, newRotation: Vector3):
	start.global_position = newPosition
	start.global_rotation = newRotation

	start.visible = start.global_position != START_MAGIC_VECTOR

func storeAddStartObject(oldPosition: Vector3, oldRotation: Vector3, newPosition: Vector3, newRotation: Vector3):
	safeResizeStack()

	operationStack.append({
		"oldPosition": oldPosition,
		"oldRotation": oldRotation,
		"newPosition": newPosition,
		"newRotation": newRotation,
		"operation": PLACED_START
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()


func addCheckPoint(propPlacer: PropPlacer):
	var checkPointObject = propPlacer.getCheckPointObject()
	addCheckPointObject(checkPointObject, propPlacer.global_position, propPlacer.global_rotation)
	storeAddCheckPointObject(checkPointObject, propPlacer.global_position, propPlacer.global_rotation)

func addCheckPointObject(checkPointObject: Area3D, checkPointPos: Vector3, checkPointRotation: Vector3):
	checkPointSystem.add_child(checkPointObject)
	checkPointObject.global_position = checkPointPos
	checkPointObject.global_rotation = checkPointRotation

func storeAddCheckPointObject(checkPointObject: Area3D, checkPointPos: Vector3, checkPointRotation: Vector3):
	safeResizeStack()

	operationStack.append({
		"checkPointObject": checkPointObject,
		"position": checkPointPos,
		"rotation": checkPointRotation,
		"operation": PLACED_CP
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()


func addProp(propPlacer: PropPlacer):
	var propObject = propPlacer.getPropObject()
	addPropObject(propObject, propPlacer.global_position, propPlacer.global_rotation)
	storeAddPropObject(propObject, propPlacer.global_position, propPlacer.global_rotation)

func addPropObject(propObject: Node3D, propPos: Vector3, propRotation: Vector3):
	props.add_child(propObject)
	propObject.global_position = propPos
	propObject.global_rotation = propRotation

func storeAddPropObject(propObject: Node3D, propPos: Vector3, propRotation: Vector3):
	safeResizeStack()

	operationStack.append({
		"propObject": propObject,
		"position": propPos,
		"rotation": propRotation,
		"operation": PLACED_PROP
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()




# remove

func remove(prefab: PrefabProperties):
	removePrefab(prefab)
	storeRemovePrefab(prefab)

func removePrefab(prefab: PrefabProperties):
	for child in prefab.get_children(true):
		child.queue_free()
	trackPieces.remove_child(prefab)

	recalculateConnectionPoints()

func storeRemovePrefab(prefab: PrefabProperties):
	safeResizeStack()

	operationStack.append({
		"prefab": prefab,
		"operation": REMOVED
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()


func removeStart():
	var oldPosition = start.global_position
	var oldRotation = start.global_rotation

	updateStartPosition(START_MAGIC_VECTOR, Vector3.ZERO)
	storeAddStartObject(oldPosition, oldRotation, start.global_position, start.global_rotation)

func removeCheckPoint(checkPointObject: Area3D):
	storeRemoveCheckPointObject(checkPointObject, checkPointObject.global_position, checkPointObject.global_rotation)
	removeCheckPointObject(checkPointObject)

func removeCheckPointObject(checkPointObject: Area3D):
	checkPointSystem.remove_child(checkPointObject)

func storeRemoveCheckPointObject(checkPointObject: Area3D, checkPointPos: Vector3, checkPointRotation: Vector3):
	safeResizeStack()

	operationStack.append({
		"checkPointObject": checkPointObject,
		"position": checkPointPos,
		"rotation": checkPointRotation,
		"operation": REMOVED_CP
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()


func removeProp(propObject: Node3D):
	storeRemovePropObject(propObject, propObject.global_position, propObject.global_rotation)
	removePropObject(propObject)

func removePropObject(propObject: Node3D):
	props.remove_child(propObject)

func storeRemovePropObject(propObject: Node3D, propPos: Vector3, propRotation: Vector3):
	safeResizeStack()

	operationStack.append({
		"propObject": propObject,
		"position": propPos,
		"rotation": propRotation,
		"operation": REMOVED_PROP
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()




# update

func update(oldPrefab: PrefabProperties, prefabMesher: PrefabMesher):
	var prefab = prefabMesher.objectFromData()

	if oldPrefab.equals(prefab):
		return

	removePrefab(oldPrefab)
	addPrefab(prefab, prefabMesher.position, prefabMesher.rotation)

	storeUpdatePrefab(oldPrefab, prefab)

func storeUpdatePrefab(oldPrefab: PrefabProperties, newPrefab: PrefabProperties):
	safeResizeStack()

	operationStack.append({
		"oldPrefab": oldPrefab,
		"newPrefab": newPrefab,
		"operation": UPDATED
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()


func updateCheckPoint(oldCheckPointObject: Area3D, propPlacer: PropPlacer):
	# var checkPointObject = propPlacer.getCheckPointObject()
	# flipping order, because the old object is the one that is already in the scene
	storeUpdateCheckPointObject(oldCheckPointObject, propPlacer.global_position, propPlacer.global_rotation)
	updateCheckPointObject(oldCheckPointObject, propPlacer.global_position, propPlacer.global_rotation)

func updateCheckPointObject(checkPointObject: Area3D, checkPointPos: Vector3, checkPointRotation: Vector3):
	checkPointObject.global_position = checkPointPos
	checkPointObject.global_rotation = checkPointRotation

func storeUpdateCheckPointObject(checkPointObject: Area3D, checkPointPos: Vector3, checkPointRotation: Vector3):
	safeResizeStack()

	operationStack.append({
		"checkPointObject": checkPointObject,
		"oldPosition": checkPointObject.global_position,
		"oldRotation": checkPointObject.global_rotation,
		"newPosition": checkPointPos,
		"newRotation": checkPointRotation,
		"operation": UPDATED_CP
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()


func updateProp(oldPropObject: Node3D, propPlacer: PropPlacer):
	# var propObject = propPlacer.getPropObject()
	# flipping order, because the old object is the one that is already in the scene
	var index = propPlacer.currentBillboardTexture
	var texture = propPlacer.billboardTextures[max(0, index)]
	var url = propPlacer.currentImageUrl
	storeUpdatePropObject(oldPropObject, propPlacer.global_position, propPlacer.global_rotation, index, texture, url)
	updatePropObject(oldPropObject, propPlacer.global_position, propPlacer.global_rotation, index, texture, url)

func updatePropObject(propObject: Node3D, propPos: Vector3, propRotation: Vector3, index: int, texture: Texture, url: String):
	propObject.global_position = propPos
	propObject.global_rotation = propRotation
	propObject.setTexture(texture, index, url)

func storeUpdatePropObject(propObject: Node3D, propPos: Vector3, propRotation: Vector3, index: int, texture: Texture, url: String):
	safeResizeStack()

	operationStack.append({
		"propObject": propObject,
		"oldPosition": propObject.global_position,
		"oldRotation": propObject.global_rotation,
		"oldTextureIndex": propObject.billboardTextureIndex,
		"oldTexture": propObject.billboardTexture,
		"oldImageUrl": propObject.billboardTextureUrl,
		"newPosition": propPos,
		"newRotation": propRotation,
		"newTextureIndex": index,
		"newTexture": texture,
		"newImageUrl": url,
		"operation": UPDATED_PROP
	})
	lastOperationIndex += 1
	emitUndoRedoSignals()



# misc

func recalculateConnectionPoints():
	connectionPoints.clear()

	for child in trackPieces.get_children():
		var prefab = child
		tryAddingConnectionPoints(prefab.topLeft, prefab.topRight, prefab.bottomLeft, prefab.bottomRight)

# operatioin handler

func safeResizeStack():
	for i in range(lastOperationIndex + 1, operationStack.size()):
		var operation = operationStack[i]

		match operation["operation"]:
			# this prefab will be lost after resize
			PLACED:
				operation["prefab"].queue_free()

			# REMOVED: no need to do anything

			# new prefab will never be needed
			UPDATED:
				operation["newPrefab"].queue_free()
			
			# PLACED_START: no need to do anything

			# this checkpoint will be lost after resize
			PLACED_CP:
				operation["checkPointObject"].queue_free()
			
			# REMOVED_CP: no need to do anything

			# UPDATED_CP: no need to do anything

			PLACED_PROP:
				operation["propObject"].queue_free()
			
			# REMOVED_PROP: no need to do anything

			# UPDATED_PROP: no need to do anything


	if operationStack.size() > lastOperationIndex + 1:
		operationStack.resize(lastOperationIndex + 1)

func ableToUndo():
	return lastOperationIndex >= 0

func ableToRedo():
	return lastOperationIndex < operationStack.size() - 1

func undo():
	if !ableToUndo():
		emitUndoRedoSignals()
		noOperationToBeUndone.emit()
		return

	var lastOperation = operationStack[lastOperationIndex]

	if lastOperation["operation"] == PLACED:
		# for child in lastOperation["prefab"].get_children(true):
		# 	child.queue_free()
		# trackPieces.remove_child(lastOperation["prefab"])
		removePrefab(lastOperation["prefab"])
	elif lastOperation["operation"] == REMOVED:
		addPrefab(lastOperation["prefab"])
	elif lastOperation["operation"] == UPDATED:
		removePrefab(lastOperation["newPrefab"])
		addPrefab(lastOperation["oldPrefab"])
	elif lastOperation["operation"] == PLACED_START:
		updateStartPosition(lastOperation["oldPosition"], lastOperation["oldRotation"])
	elif lastOperation["operation"] == PLACED_CP:
		removeCheckPointObject(lastOperation["checkPointObject"])
	elif lastOperation["operation"] == REMOVED_CP:
		addCheckPointObject(lastOperation["checkPointObject"], lastOperation["position"], lastOperation["rotation"])
	elif lastOperation["operation"] == UPDATED_CP:
		updateCheckPointObject(lastOperation["checkPointObject"], lastOperation["oldPosition"], lastOperation["oldRotation"])
	elif lastOperation["operation"] == PLACED_PROP:
		removePropObject(lastOperation["propObject"])
	elif lastOperation["operation"] == REMOVED_PROP:
		addPropObject(lastOperation["propObject"], lastOperation["position"], lastOperation["rotation"])
	elif lastOperation["operation"] == UPDATED_PROP:
		updatePropObject(lastOperation["propObject"], lastOperation["oldPosition"], lastOperation["oldRotation"], lastOperation["oldTextureIndex"], lastOperation["oldTexture"], lastOperation["oldImageUrl"])

	else:
		return
	
	lastOperationIndex -= 1
	undidLastOperation.emit()
	emitUndoRedoSignals()

func redo():
	if !ableToRedo():
		emitUndoRedoSignals()
		noOperationToBeRedone.emit()
		return

	lastOperationIndex += 1
	var lastOperation = operationStack[lastOperationIndex]

	if lastOperation["operation"] == PLACED:
		addPrefab(lastOperation["prefab"])
	elif lastOperation["operation"] == REMOVED:
		removePrefab(lastOperation["prefab"])
	elif lastOperation["operation"] == UPDATED:
		removePrefab(lastOperation["oldPrefab"])
		addPrefab(lastOperation["newPrefab"])
	elif lastOperation["operation"] == PLACED_START:
		updateStartPosition(lastOperation["newPosition"], lastOperation["newRotation"])
	elif lastOperation["operation"] == PLACED_CP:
		addCheckPointObject(lastOperation["checkPointObject"], lastOperation["position"], lastOperation["rotation"])
	elif lastOperation["operation"] == REMOVED_CP:
		removeCheckPointObject(lastOperation["checkPointObject"])
	elif lastOperation["operation"] == UPDATED_CP:
		updateCheckPointObject(lastOperation["checkPointObject"], lastOperation["newPosition"], lastOperation["newRotation"])
	elif lastOperation["operation"] == PLACED_PROP:
		addPropObject(lastOperation["propObject"], lastOperation["position"], lastOperation["rotation"])
	elif lastOperation["operation"] == REMOVED_PROP:
		removePropObject(lastOperation["propObject"])
	elif lastOperation["operation"] == UPDATED_PROP:
		updatePropObject(lastOperation["propObject"], lastOperation["newPosition"], lastOperation["newRotation"], lastOperation["newTextureIndex"], lastOperation["newTexture"], lastOperation["newImageUrl"])

	else:
		lastOperationIndex -= 1
		return
	
	redidLastOperation.emit()
	emitUndoRedoSignals()

func clearMap():
	for child in trackPieces.get_children():
		child.queue_free()
	for child in checkPointSystem.get_children():
		child.queue_free()
	for child in props.get_children():
		child.queue_free()
	# trackPieces.get_child(0).queue_free()
	# checkPointSystem.get_child(0).queue_free()

	start.visible = false

	operationStack.clear()
	lastOperationIndex = -1

func save():
	saveToJSON()

func saveToJSON(autosave: bool = false):
	var trackData = {
		"format": CURRENT_FORMAT_VERSION,
		"trackName": trackName,
		"lapCount": lapCount,
		"trackPieces": [],
		"start": {
			# "position": start.global_position,
			# "rotation": start.global_rotation
			"positionX": start.global_position.x,
			"positionY": start.global_position.y,
			"positionZ": start.global_position.z,
			# "rotationX": start.global_rotation.x,
			# "rotationY": start.global_rotation.y,
			# "rotationZ": start.global_rotation.z
			"rotation": start.global_rotation.y
		},
		"checkPoints": [],
		"props": []
		# "author": Playerstats.PLAYER_NAME
	}

	for child in trackPieces.get_children():
		# var prefabData = child.prefabData
		trackData["trackPieces"].append(child.prefabData)
	
	for child in checkPointSystem.get_children():
		trackData["checkPoints"].append({
			# "position": child.global_position,
			# "rotation": child.global_rotation
			"positionX": child.global_position.x,
			"positionY": child.global_position.y,
			"positionZ": child.global_position.z,
			# "rotationX": child.global_rotation.x,
			# "rotationY": child.global_rotation.y,
			# "rotationZ": child.global_rotation.z
			"rotation": child.global_rotation.y
		})
	
	for child in props.get_children():
		trackData["props"].append({
			# "position": child.global_position,
			# "rotation": child.global_rotation
			"positionX": child.global_position.x,
			"positionY": child.global_position.y,
			"positionZ": child.global_position.z,
			# "rotationX": child.global_rotation.x,
			# "rotationY": child.global_rotation.y,
			# "rotationZ": child.global_rotation.z
			"rotation": child.global_rotation.y,
			"textureIndex": child.billboardTextureIndex,
			"imageUrl": child.billboardTextureUrl 
		})

	# var fileHandler = FileAccess.new()
	var path = "user://tracks/local/" + trackName + ".json"
	if autosave:
		path = "user://tracks/autosave/" + trackName + "_" + str(Time.get_datetime_string_from_system().replace(":", "-")) + ".json"
	var fileHandler = FileAccess.open(path, FileAccess.WRITE)

	if fileHandler == null:
		print("Error opening file to save into")
		return

	fileHandler.store_string(JSON.stringify(trackData, "\t"))

func loadMap(fileName: String):
	print(fileName.split(".")[-1])
	if fileName.split(".")[-1] == "json":
		loadFromJSON(fileName)

func loadFromJSON(fileName: String):
	var path = fileName
	if !fileName.begins_with("user://tracks/local/") && !fileName.begins_with("user://tracks/downloaded/"):
		path = "user://tracks/local/" + fileName
	
	if fileName.begins_with("user://tracks/downloaded/"):
		trackId = fileName.split("/")[-1].split(".")[0]
	else:
		trackId = ""

	var fileHandler = FileAccess.open(path, FileAccess.READ)

	if fileHandler == null:
		print("Error opening file to load from", path)
		return
	
	var trackData = JSON.parse_string(fileHandler.get_as_text())

	if trackData == null:
		print("Error parsing JSON when loading map")
		return
	
	if trackData.has("author"):
		author = trackData["author"]
	else:
		author = ""

	clearMap()

	trackName = trackData["trackName"]
	lapCount = trackData["lapCount"]

	if !trackData.has("trackPieces"):
		print("Error loading map: no trackPieces")
		return
	
	var prefabMesher = PrefabMesher.new()
	add_child(prefabMesher)


	for prefabData in trackData["trackPieces"]:
		var prefab = prefabMesher.objectFromData(prefabData)
		addPrefab(prefab)

	prefabMesher.queue_free()


	if !trackData.has("start"):
		print("Error loading map: no start")
		return
	
	var startPosData = trackData["start"]
	updateStartPosition(Vector3(startPosData["positionX"], startPosData["positionY"], startPosData["positionZ"]), Vector3(0, startPosData["rotation"], 0))

	if !trackData.has("checkPoints"):
		print("Error loading map: no checkPoints")
		return

	var propPlacer = PropPlacer.instantiate()
	add_child(propPlacer)

	var checkpointIndex = 0
	for checkPointData in trackData["checkPoints"]:
		var checkPointObject = propPlacer.getCheckPointObject()
		checkPointObject.index = checkpointIndex
		addCheckPointObject(checkPointObject, Vector3(checkPointData["positionX"], checkPointData["positionY"], checkPointData["positionZ"]), Vector3(0, checkPointData["rotation"], 0))
		checkpointIndex += 1


	if trackData.has("props"):
		for propData in trackData["props"]:
			var imageUrl = propData["imageUrl"] if propData.has("imageUrl") else ""
			var propObject = propPlacer.getPropObject(propData["textureIndex"], imageUrl)
			addPropObject(propObject, Vector3(propData["positionX"], propData["positionY"], propData["positionZ"]), Vector3(0, propData["rotation"], 0))
	else:
		print("No props on this track")

	propPlacer.queue_free()

	print("Loaded track: " + trackData["trackName"])

	mapLoaded.emit(trackData["trackName"], trackData["lapCount"])

func getCheckpoints():
	return checkPointSystem.get_children()

func getCheckpointCount():
	return checkPointSystem.get_child_count()

func getConnectionPoints() -> Array[Dictionary]:
	return connectionPoints

func setIngame():
	# %Scenery/%Proper.disabled = false
	# %Scenery/%Flat.disabled = true
	%Scenery.setIngameCollision()

func emitUndoRedoSignals():
	canUndo.emit(ableToUndo())
	canRedo.emit(ableToRedo())
