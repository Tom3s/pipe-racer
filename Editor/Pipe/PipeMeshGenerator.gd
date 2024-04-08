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

			# vertex3D = vertex3D * currentBasis
			vertex3D = currentBasis * vertex3D

			# vertex3D = vertex3D.rotated(Vector3.UP, PI / 4)

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
				uvList.push_back(Vector2(float(i) / (PrefabConstants.PIPE_WIDTH_SEGMENTS - 1), float(j) / (PrefabConstants.PIPE_LENGTH_SEGMENTS - 1)))
		
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

	for i in PrefabConstants.PIPE_LENGTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.PIPE_LENGTH_SEGMENTS - 1)
		
		var interpolatedVertices = vertexCollection.getInterpolation(
			t, 
			getCircleLerp(
				startNode.global_position,
				endNode.global_position,
				# Vector3(0, 0, 1),
				# Vector3(1, 0, 0),
				startNode.basis.z,
				endNode.basis.z,
				t
			)
		)

		vertexList.append_array(interpolatedVertices)
	
	var mesh = ProceduralMesh.new()
	mesh.vertices = vertexList
	mesh.addMeshTo(%Mesh)

		

func getCircleLerp(
	start: Vector3, 
	end: Vector3, 
	startTangent: Vector3, 
	endTangent: Vector3,
	t: float
) -> Vector3:
	var start2D = Vector2(start.x, start.z)
	var end2D = Vector2(end.x, end.z)
	var startTangent2D = Vector2(startTangent.x, startTangent.z).normalized()
	var endTangent2D = Vector2(endTangent.x, endTangent.z).normalized()

	# Calculate the center of the circle
	var perpendicularStart = Vector2(-startTangent2D.y, startTangent2D.x)
	var perpendicularEnd = Vector2(-endTangent2D.y, endTangent2D.x)
	var center2D = Geometry2D.line_intersects_line(
		start2D, 
		perpendicularStart, 
		end2D,
		perpendicularEnd
	)
	if center2D == null:
		print("No intersection found")
		return Vector3.ZERO
	# Calculate the radius of the circle
	var radius = center2D.distance_to(start2D)

	# Calculate the angles for the start, end and the interpolated point
	var startAngle = (start2D - center2D).angle()
	var endAngle = (end2D - center2D).angle()
	var lerpAngle = lerp_angle(startAngle, endAngle, t)
	print("T: ", t, " - lerpAngle: ", lerpAngle)


	# Calculate the x and y (in this case z) coordinates of the interpolated point
	var lerpPoint = Vector2(cos(lerpAngle), sin(lerpAngle)) * radius + center2D

	print("T: ", t, " - lerpPoint: ", lerpPoint)

	return Vector3(lerpPoint.x, 0, lerpPoint.y)



