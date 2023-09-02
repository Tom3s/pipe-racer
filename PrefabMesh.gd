@tool
extends MeshInstance3D
class_name PrefabMesher

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
@export var curveForward: int = PrefabConstants.TRACK_WIDTH / PrefabConstants.GRID_SIZE:
	set(value):
		curveForward = max(value, PrefabConstants.TRACK_WIDTH / PrefabConstants.GRID_SIZE)
		refreshMesh()

@export var curveSideways: int = PrefabConstants.TRACK_WIDTH / PrefabConstants.GRID_SIZE:
	set(value):
		curveSideways = max(value, PrefabConstants.TRACK_WIDTH / PrefabConstants.GRID_SIZE)
		refreshMesh()


signal propertiesUpdated()

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
	
#	lengthDivisionPoints = [x / PrefabConstants.LENGTH_SEGMENTS for x in  range(PrefabConstants.LENGTH_SEGMENTS + 1)]
	

	
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

		heightArray.push_back(PrefabConstants.GRID_SIZE * remap(remappedIndex, 0, 1, startOffset, finalOffset))
	
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

		var xPos = lerp(xOffset, xOffset + endOffset * PrefabConstants.GRID_SIZE, lerpValue)
		positions.push_back(Vector2(xPos, lengthDivisionPoints[index] * PrefabConstants.TRACK_WIDTH * length))
	
	return positions

func remapCurveForward(value: float) -> float:
	return sin(value * PI / 2)

func remapCurveSideways(value: float) -> float:
	return sin(value * PI / 2 + PI / 2)

func generatePositionArrayCurveOutside() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	var top: float = curveForward * PrefabConstants.GRID_SIZE
	var right: float = curveSideways * PrefabConstants.GRID_SIZE
	
	for index in lengthDivisionPoints.size():
		var xLerp = remapCurveSideways(lengthDivisionPoints[index])
		var yLerp = remapCurveForward(lengthDivisionPoints[index])
		
		var xPos = lerp(0.0, right, xLerp)
		var yPos = lerp(0.0, top, yLerp)
		
		positions.push_back(Vector2(xPos, yPos))
	
	return positions

func generatePositionArrayCurveInside2() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	var top: float = curveForward * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH
	var right: float = curveSideways * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH
	
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
#		var insidePosition = point + ((bottomRight - point).normalized() * PrefabConstants.TRACK_WIDTH)
#
#		positions.push_back(insidePosition)
	# First point
	var point = outsidePositions[0]
	positions.push_back(point + ((bottomRight - point).normalized() * PrefabConstants.TRACK_WIDTH))
	
	for index in range(1, outsidePositions.size() - 1):
		var prevPoint = outsidePositions[index - 1]
		var nextPoint = outsidePositions[index + 1]
		var tangentVector = nextPoint - prevPoint
		var normalVector = Vector2(-tangentVector.y, tangentVector.x).normalized()
		
		var insidePoint = outsidePositions[index] + normalVector * PrefabConstants.TRACK_WIDTH
		
		if insidePoint.x < 0:
			point = outsidePositions[outsidePositions.size() - 1]
			insidePoint = point + ((bottomRight - point).normalized() * PrefabConstants.TRACK_WIDTH)
		
		positions.push_back(insidePoint)
		
	
	# Last Point
	point = outsidePositions[outsidePositions.size() - 1]
	positions.push_back(point + ((bottomRight - point).normalized() * PrefabConstants.TRACK_WIDTH))
	
		
	return positions

#def generate_face_list(self) -> list:
func getIndexArray() -> Array[int]:
	var indexList: Array[int] = []

	var actualLength = 2 if curve else length
	
	for y in PrefabConstants.LENGTH_SEGMENTS * actualLength:
		for x in PrefabConstants.WIDTH_SEGMENTS:
			var bottomRightIndex = x + y * (PrefabConstants.WIDTH_SEGMENTS + 1)
			var topRightIndex = x + (y + 1) * (PrefabConstants.WIDTH_SEGMENTS + 1)
			indexList.push_back(bottomRightIndex)
			indexList.push_back(bottomRightIndex + 1)
			indexList.push_back(topRightIndex)
			
			indexList.push_back(bottomRightIndex + 1)
			indexList.push_back(topRightIndex + 1)
			indexList.push_back(topRightIndex)

	return indexList

func getUVArray() -> Array[Vector2]:
	var uvArray: Array[Vector2] = []
	
	var actualLength = 2 if curve else length
	
	var multiplier = 1
	if curve:
		var larger = max(curveForward, curveSideways)
		multiplier = round(float(larger) / (PrefabConstants.TRACK_WIDTH / PrefabConstants.GRID_SIZE))
		
	for y in (PrefabConstants.LENGTH_SEGMENTS * actualLength + 1):
		for x in (PrefabConstants.WIDTH_SEGMENTS + 1):
			var u = 1.0 - (float(x) / PrefabConstants.WIDTH_SEGMENTS)
			
#			
			
			var v = 1.0 - (float(y * multiplier) / PrefabConstants.LENGTH_SEGMENTS)
			uvArray.push_back(Vector2(u, v))
	
	return uvArray

func getNormalArray(leftPositions: Array[Vector2], rightPositions: Array[Vector2], leftHeights: Array[float], rightHeights: Array[float]) -> Array[Vector3]:

	var normalArray: Array[Vector3] = []

	for index in (leftPositions.size() - 1):
		var a: Vector3 = Vector3(leftPositions[index].x, leftHeights[index], leftPositions[index].y)
		var b: Vector3 = Vector3(rightPositions[index].x, rightHeights[index], rightPositions[index].y)
		var c: Vector3 = Vector3(leftPositions[index + 1].x, leftHeights[index + 1], leftPositions[index + 1].y)
		
		var normal = ((b - a).cross(c - a)).normalized()
		for _x in (PrefabConstants.WIDTH_SEGMENTS + 1): 
			normalArray.push_back(normal)
		
	
	var index = leftPositions.size() - 1 
	
	var a: Vector3 = Vector3(leftPositions[index].x, leftHeights[index], leftPositions[index].y)
	var b: Vector3 = Vector3(rightPositions[index].x, rightHeights[index], rightPositions[index].y)
	var c: Vector3 = Vector3(leftPositions[index - 1].x, leftHeights[index - 1], leftPositions[index - 1].y)
	
	var normal = ((c - a).cross(b - a)).normalized()
	
	for _x in (PrefabConstants.WIDTH_SEGMENTS + 1): 
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
		for divIndex in range(1, PrefabConstants.WIDTH_SEGMENTS):
			vertices.push_back(lerp(rightMostVertex, leftMostVertex, float(divIndex) / PrefabConstants.WIDTH_SEGMENTS))
		
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
		for index in range(PrefabConstants.LENGTH_SEGMENTS * length + 1):
			lengthDivisionPoints.push_back(float(index) / (PrefabConstants.LENGTH_SEGMENTS * length))
		leftPositions = generatePositionArrayStraight(PrefabConstants.TRACK_WIDTH)
		rightPositions = generatePositionArrayStraight(0)
	else:
		for index in range(PrefabConstants.LENGTH_SEGMENTS * 2 + 1):
			lengthDivisionPoints.push_back(float(index) / (PrefabConstants.LENGTH_SEGMENTS * 2))
		leftPositions = generatePositionArrayCurveOutside()
#		rightPositions = generatePositionArrayCurveInside(leftPositions)
		rightPositions = generatePositionArrayCurveInside2()
		pass
		
	
	var leftHeights = generateHeightArray(leftStartHeight, leftEndHeight, leftSmoothTilt)
	var rightHeights = generateHeightArray(rightStartHeight, rightEndHeight, rightSmoothTilt) 
	
	
	var offsetVector = Vector3.RIGHT * endOffset * PrefabConstants.GRID_SIZE

	var bottomRight = Vector3(0, rightStartHeight * PrefabConstants.GRID_SIZE, 0)
	var bottomLeft = Vector3(PrefabConstants.TRACK_WIDTH, leftStartHeight * PrefabConstants.GRID_SIZE, 0)
	var topRight = Vector3(0, rightEndHeight * PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * length) + offsetVector
	var topLeft = Vector3(PrefabConstants.TRACK_WIDTH, leftEndHeight * PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * length) + offsetVector

	if curve:
		bottomRight = Vector3(curveSideways * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH, rightStartHeight * PrefabConstants.GRID_SIZE, 0)
		bottomLeft = Vector3(curveSideways * PrefabConstants.GRID_SIZE, leftStartHeight * PrefabConstants.GRID_SIZE, 0)
		topRight = Vector3(0, rightEndHeight * PrefabConstants.GRID_SIZE, curveForward * PrefabConstants.GRID_SIZE - PrefabConstants.TRACK_WIDTH)
		topLeft = Vector3(0, leftEndHeight * PrefabConstants.GRID_SIZE, curveForward * PrefabConstants.GRID_SIZE)

	if is_node_ready():
		%BottomRight.position = bottomRight
		%BottomLeft.position = bottomLeft
		%TopRight.position = topRight
		%TopLeft.position = topLeft



	generateMesh(leftHeights, rightHeights, leftPositions, rightPositions)


func getCenteringOffset() -> Vector3:
	var offset = Vector3.ZERO
	if curve:
		offset.z = curveForward * PrefabConstants.GRID_SIZE / 2
		offset.x = curveSideways * PrefabConstants.GRID_SIZE / 2
	else:
		offset.x = PrefabConstants.TRACK_WIDTH / 2
		offset.z = PrefabConstants.TRACK_WIDTH * length / 2

	offset = offset.rotated(Vector3.UP, global_rotation.y)

	return offset

func updatePosition(newPosition: Vector3, cameraPosition: Vector3, height: float, connectionPoints: Array[Dictionary] = []):
	
	newPosition += (cameraPosition - newPosition) * (PrefabConstants.GRID_SIZE * height / cameraPosition.y)

	newPosition -= getCenteringOffset()

	newPosition /= PrefabConstants.GRID_SIZE
	newPosition.x = round(newPosition.x)
	newPosition.y = height
	newPosition.z = round(newPosition.z)

	newPosition *= PrefabConstants.GRID_SIZE

	global_position = newPosition

	var connectionPoint = trySnappingToTile(connectionPoints)
	if connectionPoint != null:
		tryUpdatingProperties(connectionPoint)

func updatePositionExactCentered(newPosition: Vector3, newRotation: Vector3 = Vector3.INF):
	newPosition -= getCenteringOffset()
	global_position = newPosition
	if newRotation != Vector3.INF:
		global_rotation = newRotation

func updatePositionExact(newPosition: Vector3, newRotation: Vector3 = Vector3.INF):
	global_position = newPosition
	if newRotation != Vector3.INF:
		global_rotation = newRotation

func rotate90(direction: int = 1):
	global_position += getCenteringOffset()
	global_rotation_degrees.y += 90 * direction
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

	# data["position"] = global_position
	# data["rotation"] = global_rotation
	data["positionX"] = global_position.x
	data["positionY"] = global_position.y
	data["positionZ"] = global_position.z
	# data["rotationX"] = global_rotation.x
	# data["rotationY"] = global_rotation.y
	# data["rotationZ"] = global_rotation.z
	data["rotation"] = global_rotation.y
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

	# global_position = data["position"]
	# global_rotation = data["rotation"]
	global_position = Vector3(data["positionX"], data["positionY"], data["positionZ"])
	# global_rotation = Vector3(data["rotationX"], data["rotationY"], data["rotationZ"])
	global_rotation = Vector3(0, data["rotation"], 0)
	refreshMesh()

func objectFromData(data: Variant = null) -> PrefabProperties:
	if data != null:
		decodeData(data)
	
	refreshMesh()

	var object = PrefabProperties.new(encodeData())
	object.mesh = mesh

	return object

const MAX_CONNECTION_DISTANCE = 7

func canConnectOnFront(connectionPoint: Dictionary):

	var left = %TopLeft.global_position
	var right = %TopRight.global_position

	return canConnect(connectionPoint, left, right)

func canConnectOnBack(connectionPoint: Dictionary):

	var left = %BottomRight.global_position
	var right = %BottomLeft.global_position

	return canConnect(connectionPoint, left, right)

func canConnect(connectionPoint: Dictionary, left: Vector3, right: Vector3) -> bool:
	var leftCloseEnough = left.distance_to(connectionPoint["right"]) <= MAX_CONNECTION_DISTANCE * PrefabConstants.GRID_SIZE
	var rightCloseEnough = right.distance_to(connectionPoint["left"]) <= MAX_CONNECTION_DISTANCE * PrefabConstants.GRID_SIZE
	
	return leftCloseEnough && rightCloseEnough

func updateFrontParameters(connectionPoint: Dictionary):
	var left = %TopLeft.global_position
	var right = %TopRight.global_position

	var leftOffset = (connectionPoint["right"] - left).y / PrefabConstants.GRID_SIZE
	var rightOffset = (connectionPoint["left"] - right).y / PrefabConstants.GRID_SIZE

	leftEndHeight += leftOffset
	rightEndHeight += rightOffset

func updateBackParameters(connectionPoint: Dictionary):
	var left = %BottomRight.global_position
	var right = %BottomLeft.global_position

	var leftOffset = (connectionPoint["right"] - left).y / PrefabConstants.GRID_SIZE
	var rightOffset = (connectionPoint["left"] - right).y / PrefabConstants.GRID_SIZE

	leftStartHeight += rightOffset
	rightStartHeight += leftOffset

const MAX_HEIGHT = 10
func clampHeights():
	leftStartHeight = clamp(leftStartHeight, -MAX_HEIGHT, MAX_HEIGHT)
	leftEndHeight = clamp(leftEndHeight, -MAX_HEIGHT, MAX_HEIGHT)
	rightStartHeight = clamp(rightStartHeight, -MAX_HEIGHT, MAX_HEIGHT)
	rightEndHeight = clamp(rightEndHeight, -MAX_HEIGHT, MAX_HEIGHT) 

func trySnapOnEnd(connectionPoint: Dictionary, left: Vector3, right: Vector3) -> bool:

	if abs(connectionPoint["left"].y - right.y) > MAX_CONNECTION_DISTANCE * PrefabConstants.GRID_SIZE || abs(connectionPoint["right"].y - left.y) > MAX_CONNECTION_DISTANCE * PrefabConstants.GRID_SIZE:
		return false

	const twoDimensionalVector := Vector3(1, 0, 1)

	var leftDistance = (left * twoDimensionalVector) - (connectionPoint["right"] * twoDimensionalVector) # <= MAX_CONNECTION_DISTANCE * PrefabConstants.GRID_SIZE
	var rightDistance = (right * twoDimensionalVector) - (connectionPoint["left"] * twoDimensionalVector) # <= MAX_CONNECTION_DISTANCE * PrefabConstants.GRID_SIZE
	
	return leftDistance.is_equal_approx(rightDistance) && leftDistance.length() <= MAX_CONNECTION_DISTANCE * PrefabConstants.GRID_SIZE

func trySnapOnFront(connectionPoint: Dictionary) -> bool:
	var left = %TopLeft.global_position
	var right = %TopRight.global_position

	return trySnapOnEnd(connectionPoint, left, right)

func trySnapOnBack(connectionPoint: Dictionary) -> bool:
	var left = %BottomRight.global_position
	var right = %BottomLeft.global_position

	return trySnapOnEnd(connectionPoint, left, right)

func snap(connectionPoint: Dictionary, left: Vector3) -> void:
	var offset = connectionPoint["right"] - left
	offset.y = 0
	global_position += offset

func snapFront(connectionPoint: Dictionary):
	var left = %TopLeft.global_position
	snap(connectionPoint, left)

func snapBack(connectionPoint: Dictionary):
	var left = %BottomRight.global_position
	snap(connectionPoint, left)


func trySnappingToTile(connectionPoints: Array[Dictionary]):
	for connectionPoint in connectionPoints:
		if trySnapOnFront(connectionPoint):
			snapFront(connectionPoint)
			return connectionPoint
		elif trySnapOnBack(connectionPoint):
			snapBack(connectionPoint)
			return connectionPoint
	return null

func tryUpdatingProperties(connectionPoint: Dictionary):
	if canConnectOnFront(connectionPoint):
		updateFrontParameters(connectionPoint)

	elif canConnectOnBack(connectionPoint):
		updateBackParameters(connectionPoint)
	
	clampHeights()
	refreshMesh()
	propertiesUpdated.emit()
