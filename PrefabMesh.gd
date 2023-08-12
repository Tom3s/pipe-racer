@tool
extends MeshInstance3D

@export
var TRACK_WIDTH: float = 20.0:
	set(value):
		TRACK_WIDTH = value
		refreshMesh()

@export
var GRID_HEIGHT: float = 2.0:
	set(value):
		GRID_HEIGHT = value
		refreshMesh()

@export
var LENGTH_SEGMENTS: int = 32:
	set(value):
		LENGTH_SEGMENTS = value
		refreshMesh()

@export
var WIDTH_SEGMENTS: int = 8:
	set(value):
		WIDTH_SEGMENTS = value
		refreshMesh()

var lengthDivisionPoints: Array[float] = []

@export var leftStartHeight: int = 0:
	set(value):
		leftStartHeight = value
		refreshMesh()
@export var rightStartHeight: int = 0:
	set(value):
		rightStartHeight = value
		refreshMesh()

@export var leftEndHeight: int = 0:
	set(value):
		leftEndHeight = value
		refreshMesh()

@export var rightEndHeight: int = 0:
	set(value):
		rightEndHeight = value
		refreshMesh()

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

func generateHeightArray(startOffset: float, endOffset: float) -> Array[float]:
	var heightArray: Array[float] = []
	for index in range(LENGTH_SEGMENTS + 1):
		var remappedIndex = smoothRemap(lengthDivisionPoints[index])
		heightArray.push_back(GRID_HEIGHT * remap(remappedIndex, 0, 1, startOffset, endOffset))
	
	return heightArray

func generatePositionArrayStraight(xOffset: float) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	for index in range(LENGTH_SEGMENTS + 1):
		positions.push_back(Vector2(xOffset, lengthDivisionPoints[index] * TRACK_WIDTH))
	
	return positions

#def generate_face_list(self) -> list:
func getIndexArray() -> Array[int]:
	var indexList: Array[int] = []
	
	for y in LENGTH_SEGMENTS:
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
	
	for y in (LENGTH_SEGMENTS + 1):
		for x in (WIDTH_SEGMENTS + 1):
			var u = 1.0 - (float(x) / WIDTH_SEGMENTS)
			var v = 1.0 - (float(y) / LENGTH_SEGMENTS)
			uvArray.push_back(Vector2(u, v))
	
	return uvArray

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
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)


func refreshMesh():
	
	lengthDivisionPoints.clear()
	for index in range(LENGTH_SEGMENTS + 1):
		lengthDivisionPoints.push_back(float(index) / LENGTH_SEGMENTS)
	
	var leftPositions = generatePositionArrayStraight(TRACK_WIDTH)
	var rightPositions = generatePositionArrayStraight(0)
	
	var leftHeights = generateHeightArray(leftStartHeight, leftEndHeight)
	var rightHeights = generateHeightArray(rightStartHeight, rightEndHeight) 
	
	generateMesh(leftHeights, rightHeights, leftPositions, rightPositions)
