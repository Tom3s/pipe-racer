@tool
extends Node3D
class_name PipeMeshGenerator

class VertexCollection:
	# var startVertices: PackedVector2Array = []
	# var endVertices: PackedVector2Array = []

	var startNode: PipeNode = null
	var endNode: PipeNode = null

	var startBasis: Basis = Basis()
	var endBasis: Basis = Basis()


	func withStart(
		node: PipeNode,
		basis: Basis
	) -> VertexCollection:
		startNode = node
		startBasis = basis
		return self
	
	func withEnd(
		node: PipeNode,
		basis: Basis
	) -> VertexCollection:
		endNode = node
		endBasis = basis
		return self
	
	func getInterpolation(t: float, offset: Vector3 = Vector3.ZERO) -> PackedVector3Array:

		var result: PackedVector3Array = []

		var currentBasis = startBasis.slerp(endBasis, t)

		var vertices := PipeNode.getCircleVertices(
			# lerp(startBasis.get_euler().z, endBasis.get_euler().z, t),
			currentBasis.get_euler().z,
			lerp(startNode.profile, endNode.profile, t),
			lerp(startNode.radius, endNode.radius, t)
		)

		for i in vertices.size():
			var vertex = vertices[i]

			var vertex3D = Vector3(vertex.x, vertex.y, 0)

			# var currentBasis = lerp(startBasis, endBasis, t)

			vertex3D = vertex3D.rotated(Vector3.BACK, currentBasis.get_euler().z)

			vertex3D = currentBasis * vertex3D

			result.push_back(vertex3D + offset)

		return result
	
	func getOutsideInterpolation(t: float, offset: Vector3 = Vector3.ZERO) -> PackedVector3Array:

		var result: PackedVector3Array = []

		var currentBasis = startBasis.slerp(endBasis, t)

		var vertices := PipeNode.getCircleVertices(
			# lerp(startBasis.get_euler().z, endBasis.get_euler().z, t),
			currentBasis.get_euler().z,
			lerp(startNode.profile, endNode.profile, t),
			lerp(startNode.radius, endNode.radius, t)
		)

		var firstVertex = vertices[vertices.size() - 1]
		var firstVertex3D = Vector3(firstVertex.x, firstVertex.y, 0)
		
		firstVertex3D = firstVertex3D.rotated(Vector3.BACK, currentBasis.get_euler().z)
		firstVertex3D = currentBasis * firstVertex3D

		result.push_back(firstVertex3D + offset)

		for i in vertices.size():
			var vertex = vertices[vertices.size() - i - 1]

			vertex = vertex.normalized() * (vertex.length() + PrefabConstants.GRID_SIZE)

			var vertex3D = Vector3(vertex.x, vertex.y, 0)

			# var currentBasis = lerp(startBasis, endBasis, t)

			vertex3D = vertex3D.rotated(Vector3.BACK, currentBasis.get_euler().z)

			vertex3D = currentBasis * vertex3D

			result.push_back(vertex3D + offset)
			if i == 0 || i == vertices.size() - 1:
				result.push_back(vertex3D + offset)
		
		var lastVertex = vertices[0]
		var lastVertex3D = Vector3(lastVertex.x, lastVertex.y, 0)

		lastVertex3D = lastVertex3D.rotated(Vector3.BACK, currentBasis.get_euler().z)
		lastVertex3D = currentBasis * lastVertex3D

		result.push_back(lastVertex3D + offset)

		return result

class ProceduralMesh:
	var meshData = []
	var vertices: PackedVector3Array = []

	func _init():
		meshData.resize(ArrayMesh.ARRAY_MAX)
	
	func addMeshTo(node: MeshInstance3D, lengthMultiplier: float = 1):
		meshData[ArrayMesh.ARRAY_VERTEX] = vertices
		var indices := getVertexIndexArray(lengthMultiplier)
		meshData[ArrayMesh.ARRAY_INDEX] = indices
		meshData[ArrayMesh.ARRAY_TEX_UV] = getUVArray(lengthMultiplier)
		meshData[ArrayMesh.ARRAY_NORMAL] = getNormalArray(indices, vertices)

		node.mesh = ArrayMesh.new()
		node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)

	func addOutsideMeshTo(node: MeshInstance3D, lengthMultiplier: float = 1):
		meshData[ArrayMesh.ARRAY_VERTEX] = vertices
		var indices := getVertexIndexArray(lengthMultiplier, 4)
		meshData[ArrayMesh.ARRAY_INDEX] = indices
		meshData[ArrayMesh.ARRAY_TEX_UV] = getUVArray(lengthMultiplier, 4)
		meshData[ArrayMesh.ARRAY_NORMAL] = getNormalArray(indices, vertices)

		node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)

	func getVertexIndexArray(lengthMultiplier: float = 1, extraWidth: int = 0) -> PackedInt32Array:
		var indexList: PackedInt32Array = []
		for i in (PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1:
			for j in (PrefabConstants.PIPE_WIDTH_SEGMENTS + extraWidth) - 1:
				var index = i * (PrefabConstants.PIPE_WIDTH_SEGMENTS + extraWidth) + j
				indexList.push_back(index)
				indexList.push_back(index + ((PrefabConstants.PIPE_WIDTH_SEGMENTS + extraWidth)))
				indexList.push_back(index + 1)

				indexList.push_back(index + 1)
				indexList.push_back(index + ((PrefabConstants.PIPE_WIDTH_SEGMENTS + extraWidth))) 
				indexList.push_back(index + ((PrefabConstants.PIPE_WIDTH_SEGMENTS + extraWidth)) + 1)
		
		return indexList

	func getUVArray(lengthMultiplier: float = 1, extraWidth: int = 0) -> PackedVector2Array:
		var uvList: PackedVector2Array = []
		for j in PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier:
			for i in (PrefabConstants.PIPE_WIDTH_SEGMENTS + extraWidth):
				var v = float(i) / ((PrefabConstants.PIPE_WIDTH_SEGMENTS + extraWidth) - 1)
				var u = float(j) / ((PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1) * lengthMultiplier

				uvList.push_back(Vector2(v, u))

		return uvList

	func getNormalArray(indices: PackedInt32Array, vertices: PackedVector3Array) -> PackedVector3Array:
		var normalArray: PackedVector3Array = []
		normalArray.resize(vertices.size())

		for index in range(0, indices.size(), 3):
			var a: Vector3 = vertices[indices[index]]
			var b: Vector3 = vertices[indices[index + 2]]
			var c: Vector3 = vertices[indices[index + 1]]
			
			var normal = ((b - a).cross(c - a)).normalized()
			normalArray[indices[index]] = normal
			normalArray[indices[index + 1]] = normal
			normalArray[indices[index + 2]] = normal

		return normalArray

@onready var startNode: PipeNode = %Start
@onready var endNode: PipeNode = %End

func _ready():

	# startNode.positionChanged.connect(refreshMesh)
	# endNode.positionChanged.connect(refreshMesh)
	# startNode.rotationChanged.connect(refreshMesh)
	# endNode.rotationChanged.connect(refreshMesh)
	startNode.dataChanged.connect(refreshMesh)
	endNode.dataChanged.connect(refreshMesh)

var lengthMultiplier: float = 1

func refreshMesh() -> void:
	var vertexCollection = VertexCollection.new()\
		.withStart(startNode, startNode.basis)\
		.withEnd(endNode, endNode.basis)
		# .withStart(startNode.getCircleVertices(), Basis(Vector3(1,0,0), Vector3.UP, Vector3(0,0,1)))\
		# .withEnd(endNode.getCircleVertices(), Basis(Vector3(0,0,1), Vector3.UP, Vector3(-1,0,0)))
	
	var vertexList: PackedVector3Array = []

	var curveOffsets: PackedVector3Array = []

	var heights: PackedVector3Array = []

	var distance = startNode.global_position.distance_to(endNode.global_position)
	# if distance > PrefabConstants.TRACK_WIDTH:
	lengthMultiplier = ceilf(distance / PrefabConstants.TRACK_WIDTH)

	var curveLength: float = 0

	for i in (PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1)

		curveOffsets.push_back(
			getCurveLerp(
				startNode.global_position,
				startNode.basis.z,
				endNode.global_position,
				endNode.basis.z,
				t
			)
		)

		if i != 0:
			curveLength += curveOffsets[i].distance_to(curveOffsets[i - 1])

	for i in (PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1)
		
		heights.push_back(
			getHeightLerp(
				curveLength,
				startNode.global_position.y,
				startNode.global_rotation.x,
				endNode.global_position.y,
				endNode.global_rotation.x,
				t
			)
		)

	for i in (PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1)
		
		var interpolatedVertices = vertexCollection.getInterpolation(
			t, 
			curveOffsets[i] + 
			heights[i]
		)
		vertexList.append_array(interpolatedVertices)
	
	var mesh = ProceduralMesh.new()
	mesh.vertices = vertexList
	mesh.addMeshTo(%Mesh, lengthMultiplier)

	# Outside part

	vertexList = PackedVector3Array()

	for i in (PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1)
		
		var interpolatedVertices = vertexCollection.getOutsideInterpolation(
			t, 
			curveOffsets[i] + 
			heights[i] 
		)
		vertexList.append_array(interpolatedVertices)

	mesh.vertices = vertexList
	mesh.addOutsideMeshTo(%Mesh, lengthMultiplier)

		
func getCurveLerp(
	start: Vector3, 
	startTangent: Vector3, 
	end: Vector3,
	endTangent: Vector3,
	t: float
) -> Vector3:
	var start2D: Vector2 = Vector2(start.x, start.z)
	var end2D: Vector2 = Vector2(end.x, end.z)
	var startTangent2D: Vector2 = Vector2(startTangent.x, startTangent.z).normalized()
	var endTangent2D: Vector2 = Vector2(endTangent.x, endTangent.z).normalized()

	var intersection = Geometry2D.line_intersects_line(
		start2D, 
		startTangent2D, 
		end2D,
		endTangent2D
	)

	if intersection == null:

		var endPerpenicular = Vector2(-endTangent2D.y, endTangent2D.x)
		intersection = Geometry2D.line_intersects_line(
			start2D, 
			startTangent2D, 
			end2D,
			endPerpenicular
		)
		var node1 = lerp(start2D, intersection, 0.5)
		var node2 = (start2D - node1) + end2D

		var p1: Vector2 = lerp(start2D, node1, t)
		var p2: Vector2 = lerp(node1, node2, t)
		var p3: Vector2 = lerp(node2, end2D, t)

		var p4: Vector2 = lerp(p1, p2, t)
		var p5: Vector2 = lerp(p2, p3, t)

		var p6: Vector2 = lerp(p4, p5, t)

		return Vector3(p6.x, 0, p6.y)
	else:
		# bezier curve
		var p1: Vector2 = lerp(start2D, intersection, t)
		var p2: Vector2 = lerp(intersection, end2D, t)
		var p3: Vector2 = lerp(p1, p2, t)

		return Vector3(p3.x, 0, p3.y)


const HAX_HEIGHT_ERROR: float = 0.001

func getHeightLerp(
	length: float,
	startHeight: float,
	startAngle: float,
	endHeight: float,
	endAngle: float,
	t: float
) -> Vector3:
	var startPos: Vector2 = Vector2(0, startHeight)
	var endPos: Vector2 = Vector2(length, endHeight)

	var startTangent: Vector2 = Vector2.RIGHT.rotated(-startAngle)
	var endTangent: Vector2 = Vector2.RIGHT.rotated(-endAngle)

	var intersection = Geometry2D.line_intersects_line(
		startPos, 
		startTangent, 
		endPos,
		endTangent
	)

	if intersection == null:
		var endPerpenicular = Vector2(-endTangent.y, endTangent.x)
		intersection = Geometry2D.line_intersects_line(
			startPos, 
			startTangent, 
			endPos,
			endPerpenicular
		)
		var node1 = lerp(startPos, intersection, 0.5)
		var node2 = (startPos - node1) + endPos

		var p1: Vector2 = lerp(startPos, node1, t)
		var p2: Vector2 = lerp(node1, node2, t)
		var p3: Vector2 = lerp(node2, endPos, t)

		var p4: Vector2 = lerp(p1, p2, t)
		var p5: Vector2 = lerp(p2, p3, t)

		var p6: Vector2 = lerp(p4, p5, t)

		return Vector3(0, p6.y, 0)
	else:
		# bezier curve
		var p1: Vector2 = lerp(startPos, intersection, t)
		var p2: Vector2 = lerp(intersection, endPos, t)
		var p3: Vector2 = lerp(p1, p2, t)

		if intersection.x < 0 or intersection.x > length:
			return Vector3(0, p3.y, 0)
		
		var expectedPoint: float = length * t
		var heightError: float = abs(p3.x - expectedPoint)
		
		var iter: int = 0
		while heightError > HAX_HEIGHT_ERROR || iter < 100:
			var newT = t + (expectedPoint - p3.x) / length
			p1 = lerp(startPos, intersection, newT)
			p2 = lerp(intersection, endPos, newT)
			p3 = lerp(p1, p2, newT)
			t = newT
			heightError = abs(p3.x - expectedPoint)
			iter += 1

		return Vector3(0, p3.y, 0)


