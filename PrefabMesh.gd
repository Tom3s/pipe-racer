@tool
extends MeshInstance3D

@export
var TRACK_WIDTH: float = 20.0

@export
var GRID_HEIGHT: float = 2.0

@export
var SEGMENTS: int = 32

var divisionPoints: Array[float] = []

@export var leftStartHeight: int = 0
@export var rightStartHeight: int = 0

@export var leftEndHeight: int = 0
@export var rightEndHeight: int = 0

@export
var refresher: bool:
	set(value):
		refresher = setRefresh(value)

func setRefresh(value):
	refreshMesh()
	return value

func _ready():
	
#	divisionPoints = [x / SEGMENTS for x in  range(SEGMENTS + 1)]
	

	
	refreshMesh()

func smoothRemap(value: float) -> float:
	return (cos(value * PI + PI) + 1) / 2

func generateHeightArray(startOffset: float, endOffset: float) -> Array[float]:
	var heightArray: Array[float] = []
	for index in range(SEGMENTS + 1):
		var remappedIndex = smoothRemap(divisionPoints[index])
		heightArray.push_back(GRID_HEIGHT * remap(remappedIndex, 0, 1, startOffset, endOffset))
	
	return heightArray

func generatePositionArrayStraight(xOffset: float) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	for index in range(SEGMENTS + 1):
		positions.push_back(Vector2(xOffset, divisionPoints[index] * TRACK_WIDTH))
	
	return positions

#def generate_face_list(self) -> list:
func getIndexArray() -> Array[int]:
#	face_list: list[Vector3i] = []
	var indexList: Array[int] = []
#
#	for i in range(1, parameters.OBJ_RESOLUTION + 1):
	for index in range(SEGMENTS):
#		face_list.append(Vector3i(i, i + 1, i + parameters.OBJ_RESOLUTION + 1))
		indexList.append(index)
		indexList.append(index + SEGMENTS + 1)
		indexList.append(index + 1)
#		face_list.append(Vector3i(i + parameters.OBJ_RESOLUTION + 1, i + 1, i + parameters.OBJ_RESOLUTION + 1 + 1))
		indexList.append(index + 1)
		indexList.append(index + SEGMENTS + 1)
		indexList.append(index + SEGMENTS + 2)
	
	return indexList

func getUVArray() -> Array[Vector2]:
	var uvArray: Array[Vector2] = []
	
	for point in divisionPoints:
		uvArray.push_back(Vector2(1, 1.0 - point))
	
	for point in divisionPoints:
		uvArray.push_back(Vector2(0, 1.0 - point))
	
	return uvArray

func generateMesh(leftHeights: Array[float], rightHeights: Array[float], leftPositions: Array[Vector2], rightPositions: Array[Vector2]):
	var meshData = []
	meshData.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices = []
	for index in rightHeights.size():
		vertices.push_back(Vector3(rightPositions[index].x, rightHeights[index], rightPositions[index].y))
	
	for index in leftHeights.size():
		vertices.push_back(Vector3(leftPositions[index].x, leftHeights[index], leftPositions[index].y))
	
	meshData[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	
	meshData[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(getIndexArray())
	
	meshData[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array(getUVArray())
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)


func refreshMesh():
	
	divisionPoints.clear()
	for index in range(SEGMENTS + 1):
		divisionPoints.push_back(float(index) / SEGMENTS)
	
	var leftPositions = generatePositionArrayStraight(TRACK_WIDTH)
	var rightPositions = generatePositionArrayStraight(0)
	
	var leftHeights = generateHeightArray(leftStartHeight, leftEndHeight)
	var rightHeights = generateHeightArray(rightStartHeight, rightEndHeight) 
	
	generateMesh(leftHeights, rightHeights, leftPositions, rightPositions)
