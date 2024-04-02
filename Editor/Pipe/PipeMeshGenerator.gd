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
			
			var currentBasis = lerp(startBasis, endBasis, t)

			vertex3D = vertex3D * currentBasis

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
		for i in PIPE_LENGTH_SEGMENTS - 1:
			for j in PIPE_WIDTH_SEGMENTS - 1:
				var index = i * PIPE_WIDTH_SEGMENTS + j
				indexList.push_back(index)
				indexList.push_back(index + PIPE_LENGTH_SEGMENTS)
				indexList.push_back(index + 1)

				indexList.push_back(index + 1)
				indexList.push_back(index + PIPE_LENGTH_SEGMENTS) 
				indexList.push_back(index + PIPE_LENGTH_SEGMENTS + 1)
		
		return indexList

	func getUVArray() -> PackedVector2Array:
		var uvList: PackedVector2Array = []
		for i in PIPE_WIDTH_SEGMENTS:
			for j in PIPE_LENGTH_SEGMENTS:
				uvList.push_back(Vector2(float(i) / (PIPE_WIDTH_SEGMENTS - 1), float(j) / (PIPE_LENGTH_SEGMENTS - 1)))
		
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

const PIPE_WIDTH_SEGMENTS = 17
const PIPE_LENGTH_SEGMENTS = 17

func _ready():
	var circleVertices: PackedVector2Array = []

	for i in PIPE_WIDTH_SEGMENTS:
		var angle = i * 2 * PI / (PIPE_WIDTH_SEGMENTS - 1)
		var x = cos(angle)
		var y = sin(angle)
		circleVertices.push_back(Vector2(x, y))
	
	var circleVertices2: PackedVector2Array = []

	for i in PIPE_WIDTH_SEGMENTS:
		var angle = (i * PI / 2 / (PIPE_WIDTH_SEGMENTS - 1)) + (PI * 0.99)
		var x = cos(angle)
		var y = sin(angle)
		circleVertices2.push_back(Vector2(x, y))

	var vertexCollection = VertexCollection.new()\
		.withStart(circleVertices, Basis(Vector3(1,0,0), Vector3.UP, Vector3(0,0,1)))\
		.withEnd(circleVertices2, Basis(Vector3(0,0,1), Vector3.UP, Vector3(-1,0,0)))

	var vertexList: PackedVector3Array = []

	for i in PIPE_LENGTH_SEGMENTS:
		var t = float(i) / (PIPE_LENGTH_SEGMENTS - 1)
		
		var interpolatedVertices = vertexCollection.getInterpolation(
			t, 
			getCircleLerp(
				Vector3(0, 0, 0),
				Vector3(5, 0, 5),
				Vector3(0, 0, 1),
				Vector3(1, 0, 0),
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

