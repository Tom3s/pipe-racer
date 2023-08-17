@tool
extends MeshInstance3D
class_name PrefabMesher

@export_group("Global Constants")
@export
var TRACK_WIDTH: float = 20.0:
	set(value):
		TRACK_WIDTH = value
		refreshMesh()

@export
var GRID_SIZE: float = 2.0:
	set(value):
		GRID_SIZE = value
		refreshMesh()

@export
var LENGTH_SEGMENTS: int = 16:
	set(value):
		LENGTH_SEGMENTS = value
		refreshMesh()

@export
var WIDTH_SEGMENTS: int = 8:
	set(value):
		WIDTH_SEGMENTS = value
		refreshMesh()

var lengthDivisionPoints: Array[float] = []

const NON_SMOOTH = 0
const SMOOTH_START = 1
const SMOOTH_END = 2
const SMOOTH_BOTH = 3


@export_group("General Properties")
@export var leftStartHeight: int = 0:
	set(value):
		leftStartHeight = value
		refreshMesh()

@export var leftEndHeight: int = 0:
	set(value):
		leftEndHeight = value
		refreshMesh()

@export var leftSmoothTilt: int = 0:
	set(value):
		leftSmoothTilt = (value + 4) % 4
		refreshMesh()



@export var rightStartHeight: int = 0:
	set(value):
		rightStartHeight = value
		refreshMesh()


@export var rightEndHeight: int = 0:
	set(value):
		rightEndHeight = value
		refreshMesh()

@export var rightSmoothTilt: int = 0:
	set(value):
		rightSmoothTilt = (value + 4) % 4
		refreshMesh()

@export_group("Prefab Type")

@export var curve: bool = false:
	set(value):
		curve = value
		refreshMesh()

@export_group("Straight Prefab Properties")
@export var endOffset: int = 0:
	set(value):
		endOffset = value
		refreshMesh()

@export var smoothOffset: int = 0:
	set(value):
		smoothOffset = (value + 4) % 4
		refreshMesh()

@export var length: int = 1:
	set(value):
		length = value
		refreshMesh()

@export_group("Curved Prefab Properties")
@export var curveForward: int = TRACK_WIDTH / GRID_SIZE:
	set(value):
		curveForward = max(value, TRACK_WIDTH / GRID_SIZE)
		refreshMesh()

@export var curveSideways: int = TRACK_WIDTH / GRID_SIZE:
	set(value):
		curveSideways = max(value, TRACK_WIDTH / GRID_SIZE)
		refreshMesh()


const ROAD_TYPE_TARMAC = 0
const ROAD_TYPE_GRASS = 1

@export 
var roadType: int = ROAD_TYPE_TARMAC

#@export
#var refresher: bool:
#	set(value):
#		refreshMesh()
#		refresher = value

func setRefresh(value):
	refreshMesh()
	return value

func _ready():
	
#	lengthDivisionPoints = [x / LENGTH_SEGMENTS for x in  range(LENGTH_SEGMENTS + 1)]
	

	
	refreshMesh()

func smoothRemap(value: float) -> float:
	return (cos(value * PI + PI) + 1) / 2

func smoothStartRemamp(value: float) -> float:
	return sin(value * PI / 2)

func smoothEndRemamp(value: float) -> float:
	return cos(value * PI / 2 + PI) + 1


func generateHeightArray(startOffset: float, finalOffset: float, smooth: int) -> Array[float]:
	var heightArray: Array[float] = []
	for index in lengthDivisionPoints.size():
		# var remappedIndex = smoothRemap(lengthDivisionPoints[index]) if smooth else lengthDivisionPoints
		var remappedIndex = lengthDivisionPoints[index]

		if smooth == SMOOTH_START:
			remappedIndex = smoothStartRemamp(remappedIndex)
		elif smooth == SMOOTH_END:
			remappedIndex = smoothEndRemamp(remappedIndex)
		elif smooth == SMOOTH_BOTH:
			remappedIndex = smoothRemap(remappedIndex)

		heightArray.push_back(GRID_SIZE * remap(remappedIndex, 0, 1, startOffset, finalOffset))
	
	return heightArray

func generatePositionArrayStraight(xOffset: float) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	for index in lengthDivisionPoints.size():
		# var lerpValue = smoothRemap(lengthDivisionPoints[index]) if smoothOffset else lengthDivisionPoints[index]

		var lerpValue = lengthDivisionPoints[index]

		if smoothOffset == SMOOTH_START:
			lerpValue = smoothStartRemamp(lerpValue)
		elif smoothOffset == SMOOTH_END:
			lerpValue = smoothEndRemamp(lerpValue)
		elif smoothOffset == SMOOTH_BOTH:
			lerpValue = smoothRemap(lerpValue)

		var xPos = lerp(xOffset, xOffset + endOffset * GRID_SIZE, lerpValue)
		positions.push_back(Vector2(xPos, lengthDivisionPoints[index] * TRACK_WIDTH * length))
	
	return positions

func remapCurveForward(value: float) -> float:
	return sin(value * PI / 2)

func remapCurveSideways(value: float) -> float:
	return sin(value * PI / 2 + PI / 2)

func generatePositionArrayCurveOutside() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	var top: float = curveForward * GRID_SIZE
	var right: float = curveSideways * GRID_SIZE
	
	for index in lengthDivisionPoints.size():
		var xLerp = remapCurveSideways(lengthDivisionPoints[index])
		var yLerp = remapCurveForward(lengthDivisionPoints[index])
		
		var xPos = lerp(0.0, right, xLerp)
		var yPos = lerp(0.0, top, yLerp)
		
		positions.push_back(Vector2(xPos, yPos))
	
	return positions

func generatePositionArrayCurveInside2() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	var top: float = curveForward * GRID_SIZE - TRACK_WIDTH
	var right: float = curveSideways * GRID_SIZE - TRACK_WIDTH
	
	for index in lengthDivisionPoints.size():
		var xLerp = remapCurveSideways(lengthDivisionPoints[index])
		var yLerp = remapCurveForward(lengthDivisionPoints[index])
		
		var xPos = lerp(0.0, right, xLerp)
		var yPos = lerp(0.0, top, yLerp)
		
		positions.push_back(Vector2(xPos, yPos))
	
	return positions

func generatePositionArrayCurveInside(outsidePositions: Array[Vector2]) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	var bottomRight = Vector2(0, 0)
	
#	for point in outsidePositions:
#		var insidePosition = point + ((bottomRight - point).normalized() * TRACK_WIDTH)
#
#		positions.push_back(insidePosition)
	# First point
	var point = outsidePositions[0]
	positions.push_back(point + ((bottomRight - point).normalized() * TRACK_WIDTH))
	
	for index in range(1, outsidePositions.size() - 1):
		var prevPoint = outsidePositions[index - 1]
		var nextPoint = outsidePositions[index + 1]
		var tangentVector = nextPoint - prevPoint
		var normalVector = Vector2(-tangentVector.y, tangentVector.x).normalized()
		
		var insidePoint = outsidePositions[index] + normalVector * TRACK_WIDTH
		
		if insidePoint.x < 0:
			point = outsidePositions[outsidePositions.size() - 1]
			insidePoint = point + ((bottomRight - point).normalized() * TRACK_WIDTH)
		
		positions.push_back(insidePoint)
		
	
	# Last Point
	point = outsidePositions[outsidePositions.size() - 1]
	positions.push_back(point + ((bottomRight - point).normalized() * TRACK_WIDTH))
	
		
	return positions

#def generate_face_list(self) -> list:
func getIndexArray() -> Array[int]:
	var indexList: Array[int] = []

	var actualLength = 1 if curve else length
	
	for y in LENGTH_SEGMENTS * actualLength:
		for x in WIDTH_SEGMENTS:
			var bottomRightIndex = x + y * (WIDTH_SEGMENTS + 1)
			var topRightIndex = x + (y + 1) * (WIDTH_SEGMENTS + 1)
			indexList.push_back(bottomRightIndex)
			indexList.push_back(bottomRightIndex + 1)
			indexList.push_back(topRightIndex)
			
			indexList.push_back(bottomRightIndex + 1)
			indexList.push_back(topRightIndex + 1)
			indexList.push_back(topRightIndex)

	return indexList

func getUVArray() -> Array[Vector2]:
	var uvArray: Array[Vector2] = []
	
	var actualLength = 1 if curve else length
	
	var multiplier = 1
	if curve:
		var larger = max(curveForward, curveSideways)
		multiplier = round(float(larger) / (TRACK_WIDTH / GRID_SIZE))
		
	for y in (LENGTH_SEGMENTS * actualLength + 1):
		for x in (WIDTH_SEGMENTS + 1):
			var u = 1.0 - (float(x) / WIDTH_SEGMENTS)
			
#			
			
			var v = 1.0 - (float(y * multiplier) / LENGTH_SEGMENTS)
			uvArray.push_back(Vector2(u, v))
	
	return uvArray

func getNormalArray(leftPositions: Array[Vector2], rightPositions: Array[Vector2], leftHeights: Array[float], rightHeights: Array[float]) -> Array[Vector3]:

	var normalArray: Array[Vector3] = []

	for index in (leftPositions.size() - 1):
		var a: Vector3 = Vector3(leftPositions[index].x, leftHeights[index], leftPositions[index].y)
		var b: Vector3 = Vector3(rightPositions[index].x, rightHeights[index], rightPositions[index].y)
		var c: Vector3 = Vector3(leftPositions[index + 1].x, leftHeights[index + 1], leftPositions[index + 1].y)
		
		var normal = ((b - a).cross(c - a)).normalized()
		for _x in (WIDTH_SEGMENTS + 1): 
			normalArray.push_back(normal)
		
	
	var index = leftPositions.size() - 1 
	
	var a: Vector3 = Vector3(leftPositions[index].x, leftHeights[index], leftPositions[index].y)
	var b: Vector3 = Vector3(rightPositions[index].x, rightHeights[index], rightPositions[index].y)
	var c: Vector3 = Vector3(leftPositions[index - 1].x, leftHeights[index - 1], leftPositions[index - 1].y)
	
	var normal = ((c - a).cross(b - a)).normalized()
	
	for _x in (WIDTH_SEGMENTS + 1): 
		normalArray.push_back(normal)
	
	
	return normalArray

func generateMesh(leftHeights: Array[float], rightHeights: Array[float], leftPositions: Array[Vector2], rightPositions: Array[Vector2]):
	var meshData = []
	meshData.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices = []
#	for index in rightHeights.size():
#		vertices.push_back(Vector3(rightPositions[index].x, rightHeights[index], rightPositions[index].y))
#
#	for index in leftHeights.size():
#		vertices.push_back(Vector3(leftPositions[index].x, leftHeights[index], leftPositions[index].y))
	for index in rightPositions.size():
		var rightMostVertex = Vector3(rightPositions[index].x, rightHeights[index], rightPositions[index].y)
		var leftMostVertex = Vector3(leftPositions[index].x, leftHeights[index], leftPositions[index].y)
		
		vertices.push_back(rightMostVertex)
		for divIndex in range(1, WIDTH_SEGMENTS):
			vertices.push_back(lerp(rightMostVertex, leftMostVertex, float(divIndex) / WIDTH_SEGMENTS))
		
		vertices.push_back(leftMostVertex)

	
	meshData[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	
	meshData[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(getIndexArray())
	
	meshData[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array(getUVArray())
	
	meshData[ArrayMesh.ARRAY_NORMAL] = PackedVector3Array(getNormalArray(leftPositions, rightPositions, leftHeights, rightHeights))
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)


func refreshMesh():
	
	lengthDivisionPoints.clear()
	
	var leftPositions = []
	var rightPositions = []
	
	if !curve:
		for index in range(LENGTH_SEGMENTS * length + 1):
			lengthDivisionPoints.push_back(float(index) / (LENGTH_SEGMENTS * length))
		leftPositions = generatePositionArrayStraight(TRACK_WIDTH)
		rightPositions = generatePositionArrayStraight(0)
	else:
		for index in range(LENGTH_SEGMENTS + 1):
			lengthDivisionPoints.push_back(float(index) / (LENGTH_SEGMENTS))
		leftPositions = generatePositionArrayCurveOutside()
#		rightPositions = generatePositionArrayCurveInside(leftPositions)
		rightPositions = generatePositionArrayCurveInside2()
		pass
		
	
	var leftHeights = generateHeightArray(leftStartHeight, leftEndHeight, leftSmoothTilt)
	var rightHeights = generateHeightArray(rightStartHeight, rightEndHeight, rightSmoothTilt) 
	
	generateMesh(leftHeights, rightHeights, leftPositions, rightPositions)


func getCenteringOffset() -> Vector3:
	var offset = Vector3.ZERO
	if curve:
		offset.z = curveForward * GRID_SIZE / 2
		offset.x = curveSideways * GRID_SIZE / 2
	else:
		offset.x = TRACK_WIDTH / 2
		offset.z = TRACK_WIDTH * length / 2

	offset = offset.rotated(Vector3.UP, global_rotation.y)

	return offset

func updatePosition(newPosition: Vector3, cameraPosition: Vector3, height: float):
	
	newPosition += (cameraPosition - newPosition) * (GRID_SIZE * height / cameraPosition.y)

	newPosition -= getCenteringOffset()

	newPosition /= GRID_SIZE
	newPosition.x = round(newPosition.x)
	newPosition.y = height
	newPosition.z = round(newPosition.z)

	newPosition *= GRID_SIZE

	global_position = newPosition

func updatePositionExactCentered(newPosition: Vector3, newRotation: Vector3 = Vector3.INF):
	newPosition -= getCenteringOffset()
	global_position = newPosition
	if newRotation != Vector3.INF:
		global_rotation = newRotation

func updatePositionExact(newPosition: Vector3, newRotation: Vector3 = Vector3.INF):
	global_position = newPosition
	if newRotation != Vector3.INF:
		global_rotation = newRotation

func rotate90():
	global_position += getCenteringOffset()
	global_rotation_degrees.y += 90
	global_position -= getCenteringOffset()

func encodeData():
	var data = {}
	data["leftStartHeight"] = leftStartHeight
	data["leftEndHeight"] = leftEndHeight
	data["leftSmoothTilt"] = leftSmoothTilt
	data["rightStartHeight"] = rightStartHeight
	data["rightEndHeight"] = rightEndHeight
	data["rightSmoothTilt"] = rightSmoothTilt
	data["curve"] = curve
	data["endOffset"] = endOffset
	data["smoothOffset"] = smoothOffset
	data["length"] = length
	data["curveForward"] = curveForward
	data["curveSideways"] = curveSideways

	data["roadType"] = roadType

	data["global_position"] = global_position
	data["global_rotation"] = global_rotation
	return data

func decodeData(data: Variant):
	leftStartHeight = data["leftStartHeight"]
	leftEndHeight = data["leftEndHeight"]
	leftSmoothTilt = data["leftSmoothTilt"]
	rightStartHeight = data["rightStartHeight"]
	rightEndHeight = data["rightEndHeight"]
	rightSmoothTilt = data["rightSmoothTilt"]
	curve = data["curve"]
	endOffset = data["endOffset"]
	smoothOffset = data["smoothOffset"]
	length = data["length"]
	curveForward = data["curveForward"]
	curveSideways = data["curveSideways"]

	roadType = data["roadType"]

	global_position = data["global_position"]
	global_rotation = data["global_rotation"]
	refreshMesh()

func objectFromData(data: Variant = null):
	if data != null:
		decodeData(data)
	
	refreshMesh()

	var object = PrefabProperties.new(encodeData())
	object.mesh = mesh

	return object
