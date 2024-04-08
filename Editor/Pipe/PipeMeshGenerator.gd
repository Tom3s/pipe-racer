@tool
extends Node3D
class_name PipeMeshGenerator

class VertexCollection:
	var startVertices: PackedVector2Array = []
	var endVertices: PackedVector2Array = []

	var startBasis: Basis = Basis()
	var endBasis: Basis = Basis()


	func withStart(
		vertices: PackedVector2Array,
		basis: Basis
	) -> VertexCollection:
		startVertices = []
		startVertices.append_array(vertices)
		startBasis = basis
		return self
	
	func withEnd(
		vertices: PackedVector2Array,
		basis: Basis
	) -> VertexCollection:
		endVertices = []
		endVertices.append_array(vertices)
		endBasis = basis
		return self
	
	func getInterpolation(t: float, offset: Vector3 = Vector3.ZERO) -> PackedVector3Array:
		var result: PackedVector3Array = []

		for i in startVertices.size():
			var start: Vector2 = startVertices[i]
			var end: Vector2 = endVertices[i]

			# var vertex = lerp(start, end, t) # * lerp(start.length(), end.length(), t)

			var angle = lerp_angle(start.angle(), end.angle(), t)
			var vertex = Vector2.RIGHT.rotated(angle) * lerp(start.length(), end.length(), t)



			var vertex3D = Vector3(vertex.x, vertex.y, 0)
			# var vertex3D = Vector3(0, vertex.y, vertex.x)
			
			var currentBasis = lerp(startBasis, endBasis, t)

			vertex3D = vertex3D.rotated(Vector3.BACK, currentBasis.get_euler().z)

			vertex3D = currentBasis * vertex3D

			result.push_back(vertex3D + offset)

		return result

class ProceduralMesh:
	var meshData = []
	var vertices: PackedVector3Array = []

	func _init():
		meshData.resize(ArrayMesh.ARRAY_MAX)
	
	func addMeshTo(node: MeshInstance3D):
		meshData[ArrayMesh.ARRAY_VERTEX] = vertices
		var indices := getVertexIndexArray()
		meshData[ArrayMesh.ARRAY_INDEX] = indices
		meshData[ArrayMesh.ARRAY_TEX_UV] = getUVArray()
		meshData[ArrayMesh.ARRAY_NORMAL] = getNormalArray(indices, vertices)

		node.mesh = ArrayMesh.new()
		node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)

	func getVertexIndexArray() -> PackedInt32Array:
		var indexList: PackedInt32Array = []
		for i in PrefabConstants.PIPE_LENGTH_SEGMENTS - 1:
			for j in PrefabConstants.PIPE_WIDTH_SEGMENTS - 1:
				var index = i * PrefabConstants.PIPE_WIDTH_SEGMENTS + j
				indexList.push_back(index)
				indexList.push_back(index + PrefabConstants.PIPE_LENGTH_SEGMENTS)
				indexList.push_back(index + 1)

				indexList.push_back(index + 1)
				indexList.push_back(index + PrefabConstants.PIPE_LENGTH_SEGMENTS) 
				indexList.push_back(index + PrefabConstants.PIPE_LENGTH_SEGMENTS + 1)
		
		return indexList

	func getUVArray() -> PackedVector2Array:
		var uvList: PackedVector2Array = []
		for i in PrefabConstants.PIPE_WIDTH_SEGMENTS:
			for j in PrefabConstants.PIPE_LENGTH_SEGMENTS:
				uvList.push_back(Vector2(float(j) / (PrefabConstants.PIPE_WIDTH_SEGMENTS - 1), float(i) / (PrefabConstants.PIPE_LENGTH_SEGMENTS - 1)))
		
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



func refreshMesh() -> void:
	var vertexCollection = VertexCollection.new()\
		.withStart(startNode.getCircleVertices(), startNode.basis)\
		.withEnd(endNode.getCircleVertices(), endNode.basis)
		# .withStart(startNode.getCircleVertices(), Basis(Vector3(1,0,0), Vector3.UP, Vector3(0,0,1)))\
		# .withEnd(endNode.getCircleVertices(), Basis(Vector3(0,0,1), Vector3.UP, Vector3(-1,0,0)))
	
	var vertexList: PackedVector3Array = []

	var curveOffsets: PackedVector3Array = []
	var curveLength: float = 0

	for i in PrefabConstants.PIPE_LENGTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.PIPE_LENGTH_SEGMENTS - 1)

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

	for i in PrefabConstants.PIPE_LENGTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.PIPE_LENGTH_SEGMENTS - 1)
		
		var interpolatedVertices = vertexCollection.getInterpolation(
			t, 
			curveOffsets[i] + 
			getHeightLerp(
				curveLength,
				startNode.global_position.y,
				startNode.global_rotation.x,
				endNode.global_position.y,
				endNode.global_rotation.x,
				t
			)
		)

		vertexList.append_array(interpolatedVertices)
	
	var mesh = ProceduralMesh.new()
	mesh.vertices = vertexList
	mesh.addMeshTo(%Mesh)

		
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
		# print("No intersection found")

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
		print("No intersection found")
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
			print("Intersection out of bounds")
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

		print("Height: ", p3)
		return Vector3(0, p3.y, 0)


