extends MeshInstance3D
class_name PrefabProperties

var prefabData: Dictionary = {}
# var friction: float = 1.0

var selected: bool = false:
	set(value):
		selected = selectionChanged(value)

@onready
var selectedMaterial = preload("res://Tracks/trackPrefabSelected.tres")

var bottomRight: Vector3
var bottomLeft: Vector3
var topRight: Vector3
var topLeft: Vector3

func _init(data):
	prefabData = data

# func _ready():
# 	calculateCorners()

func selectionChanged(value):
	if value:
		set_surface_override_material(0, selectedMaterial)
	else:
		set_surface_override_material(0, null)

	return value

func select():
	selected = true
	print(name, "selected")

func deselect():
	selected = false
	print(name, "deselected")

func equals(other) -> bool:
	for key in prefabData.keys():
		if prefabData[key] != other.prefabData[key]:
			return false
	return true


# var offsetVector = Vector3.RIGHT * endOffset * PrefabConstants.GRID_SIZE

# var bottomRight = Vector3(0, rightStartHeight * PrefabConstants.GRID_SIZE, 0)
# var bottomLeft = Vector3(PrefabConstants.TRACK_WIDTH, leftStartHeight * PrefabConstants.GRID_SIZE, 0)
# var topRight = Vector3(0, rightEndHeight * PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * length) + offsetVector
# var topLeft = Vector3(PrefabConstants.TRACK_WIDTH, leftEndHeight * PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * length) + offsetVector

# if curve:
# 	bottomRight = Vector3(curveSideways * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH, rightStartHeight * PrefabConstants.GRID_SIZE, 0)
# 	bottomLeft = Vector3(curveSideways * PrefabConstants.GRID_SIZE, leftStartHeight * PrefabConstants.GRID_SIZE, 0)
# 	topRight = Vector3(0, rightEndHeight * PrefabConstants.GRID_SIZE, curveForward * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH)
# 	topLeft = Vector3(0, leftEndHeight * PrefabConstants.GRID_SIZE, curveForward * PrefabConstants.GRID_SIZE)

func rotateCorner(corner: Vector3, rotation: float) -> Vector3:
	var rotatedCorner = corner.rotated(Vector3.UP, rotation)
	return rotatedCorner

func calculateCorners():
	var offsetVector = Vector3.RIGHT * prefabData["endOffset"] * PrefabConstants.GRID_SIZE

	bottomRight = Vector3(0, prefabData["rightStartHeight"] * PrefabConstants.GRID_SIZE, 0)
	bottomLeft = Vector3(PrefabConstants.TRACK_WIDTH, prefabData["leftStartHeight"] * PrefabConstants.GRID_SIZE, 0)
	topRight = Vector3(0, prefabData["rightEndHeight"] * PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * prefabData["length"]) + offsetVector
	topLeft = Vector3(PrefabConstants.TRACK_WIDTH, prefabData["leftEndHeight"] * PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * prefabData["length"]) + offsetVector

	if prefabData["curve"]:
		bottomRight = Vector3(prefabData["curveSideways"] * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH, prefabData["rightStartHeight"] * PrefabConstants.GRID_SIZE, 0)
		bottomLeft = Vector3(prefabData["curveSideways"] * PrefabConstants.GRID_SIZE, prefabData["leftStartHeight"] * PrefabConstants.GRID_SIZE, 0)
		topRight = Vector3(0, prefabData["rightEndHeight"] * PrefabConstants.GRID_SIZE, prefabData["curveForward"] * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH)
		topLeft = Vector3(0, prefabData["leftEndHeight"] * PrefabConstants.GRID_SIZE, prefabData["curveForward"] * PrefabConstants.GRID_SIZE)

	bottomRight = rotateCorner(bottomRight, global_rotation.y)
	bottomLeft = rotateCorner(bottomLeft, global_rotation.y)
	topRight = rotateCorner(topRight, global_rotation.y)
	topLeft = rotateCorner(topLeft, global_rotation.y)

	bottomRight += global_position
	bottomLeft += global_position
	topRight += global_position
	topLeft += global_position

	