extends Node3D
class_name PropPlacer

var TRACK_WIDTH: float = 64.0
var GRID_SIZE: float = 4.0
var length: float = 5.1

const FINE_ROTATION_DEGREES = 5

const MODE_START_LINE = 0
const MODE_CHECKPOINT = 1
const MODE_PROP = 2

var mode: int = MODE_START_LINE:
	set(value):
		mode = onModeChange(value)
	get:
		return mode

@onready
var checkPointObject: PackedScene = preload("res://CheckPoint.tscn")

var billboardObject: PackedScene = preload("res://Track Props/Sign.tscn")

@export
var billboardTextures: Array[Texture] = []

const BILLBOARD_TEXTURE_BUMPY_ROAD = 0
const BILLBOARD_TEXTURE_CHICANE_LEFT = 1
const BILLBOARD_TEXTURE_CHICANE_RIGHT = 2
const BILLBOARD_TEXTURE_SHARP_LEFT = 3
const BILLBOARD_TEXTURE_SHARP_RIGHT = 4

var currentBillboardTexture: int = BILLBOARD_TEXTURE_BUMPY_ROAD

func onModeChange(value: int) -> int:

	startLinePreview.visible = false
	propPreview.visible = false
	checkpointPreview.visible = false

	if value == MODE_START_LINE:
		startLinePreview.visible = true
	elif value == MODE_PROP:
		propPreview.visible = true
	elif value == MODE_CHECKPOINT:
		checkpointPreview.visible = true

	return mode

var startLinePreview: Node3D
var propPreview: Node3D
var checkpointPreview: Node3D

func _ready():
	startLinePreview = %StartLinePreview
	propPreview = %PropPreview
	checkpointPreview = %CheckPointPreview
	startLinePreview.visible = false
	propPreview.visible = false
	checkpointPreview.visible = false

	mode = MODE_START_LINE

# func getCenteringOffset() -> Vector3:
# 	var offset = Vector3.ZERO
	
# 	offset.x = TRACK_WIDTH / 2
# 	offset.z = length / 2

# 	offset = offset.rotated(Vector3.UP, global_rotation.y)

# 	return offset

func updatePosition(newPosition: Vector3, cameraPosition: Vector3, height: float, _sink):
	
	newPosition += (cameraPosition - newPosition) * (GRID_SIZE * height / cameraPosition.y)

	# newPosition -= getCenteringOffset()

	newPosition /= GRID_SIZE
	newPosition.x = round(newPosition.x)
	newPosition.y = height
	newPosition.z = round(newPosition.z)

	newPosition *= GRID_SIZE

	global_position = newPosition

func updatePositionExactCentered(newPosition: Vector3, newRotation: Vector3 = Vector3.INF):
	# newPosition -= getCenteringOffset()
	global_position = newPosition
	if newRotation != Vector3.INF:
		global_rotation = newRotation

func updatePositionExact(newPosition: Vector3, newRotation: Vector3 = Vector3.INF):
	global_position = newPosition
	if newRotation != Vector3.INF:
		global_rotation = newRotation

func rotate90():
	# global_position += getCenteringOffset()

	global_rotation_degrees.y = floor(global_rotation_degrees.y / 90) * 90

	global_rotation_degrees.y += 90
	# global_position -= getCenteringOffset()

func rotateFine(amount: int):
	global_rotation_degrees.y += amount * FINE_ROTATION_DEGREES

func getCheckPointObject() -> Area3D:
	return checkPointObject.instantiate()

func getPropObject(textureIndex: int = -1) -> Node3D:
	if textureIndex == -1:
		textureIndex = currentBillboardTexture
	var prop = billboardObject.instantiate()
	# prop.billboardTexture = billboardTextures[textureIndex]
	# prop.billboardTextureIndex = textureIndex
	prop.setTexture(billboardTextures[textureIndex], textureIndex)
	# prop.scale = Vector3.ONE * 8.5
	return prop
