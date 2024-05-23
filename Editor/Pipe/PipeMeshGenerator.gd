@tool
extends Node3D
class_name PipeMeshGenerator


class PipeVertexCollection:
	var startNode: PipeNode = null
	var endNode: PipeNode = null

	var startBasis: Basis = Basis()
	var endBasis: Basis = Basis()


	func withStart(
		node: PipeNode,
		basis: Basis
	) -> PipeVertexCollection:
		startNode = node
		startBasis = basis
		return self
	
	func withEnd(
		node: PipeNode,
		basis: Basis
	) -> PipeVertexCollection:
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
			# lerp(startNode.radius, endNode.radius, ease(t, -1.5))
			lerp(startNode.radius, endNode.radius, smoothstep(0, 1, t)),
			lerp(float(startNode.flat), float(endNode.flat), t)
		)

		for i in vertices.size():
			var vertex = vertices[i]

			var vertex3D = PipeVertexCollection.getRotatedVertex(vertex, currentBasis)

			result.push_back(vertex3D + offset)

		return result
	
	func getOutsideInterpolation(t: float, offset: Vector3 = Vector3.ZERO) -> PackedVector3Array:

		var result: PackedVector3Array = []

		var currentBasis = startBasis.slerp(endBasis, t)

		var vertices := PipeNode.getCircleVertices(
			# lerp(startBasis.get_euler().z, endBasis.get_euler().z, t),
			currentBasis.get_euler().z,
			lerp(startNode.profile, endNode.profile, t),
			# lerp(startNode.radius, endNode.radius, ease(t, -1.5))
			lerp(startNode.radius, endNode.radius, smoothstep(0, 1, t)),
			lerp(float(startNode.flat), float(endNode.flat), t)
		)

		var firstVertex = vertices[vertices.size() - 1]
		var firstVertex3D = PipeVertexCollection.getRotatedVertex(firstVertex, currentBasis)

		result.push_back(firstVertex3D + offset)

		for i in vertices.size():
			var vertex = vertices[vertices.size() - i - 1]

			vertex = vertex.normalized() * (vertex.length() + PrefabConstants.GRID_SIZE)

			var vertex3D = PipeVertexCollection.getRotatedVertex(vertex, currentBasis)

			result.push_back(vertex3D + offset)
			if i == 0 || i == vertices.size() - 1:
				result.push_back(vertex3D + offset)
		
		var lastVertex = vertices[0]
		var lastVertex3D = PipeVertexCollection.getRotatedVertex(lastVertex, currentBasis)

		result.push_back(lastVertex3D + offset)

		return result

	static func getRotatedVertex(
		vertex: Vector2,
		basis: Basis
	) -> Vector3:
		var vertex3D = Vector3(vertex.x, vertex.y, 0)

		vertex3D = vertex3D.rotated(Vector3.BACK, basis.get_euler().z)

		vertex3D = basis * vertex3D

		return vertex3D



@onready var startNode: PipeNode = %Start:
	set(newNode):
		startNode.dataChanged.disconnect(refreshMesh)

		if get_node("Start") != null:
			%Start.queue_free()

		startNode = newNode

		startNode.dataChanged.connect(refreshMesh)

@onready var endNode: PipeNode = %End:
	set(newNode):
		endNode.dataChanged.disconnect(refreshMesh)

		if get_node("End") != null:
			%End.queue_free() 

		endNode = newNode

		endNode.dataChanged.connect(refreshMesh)

@onready var pipeMesh: PhysicsSurface = %Mesh

@export
var surfaceType: PhysicsSurface.SurfaceType = PhysicsSurface.SurfaceType.ROAD:
	set(newValue):
		surfaceType = setSurfaceMaterial(newValue)

		# refreshMesh()

@export
var swapStartEnd: bool = false:
	set(newValue):
		if startNode == null or endNode == null:
			return
		var tempProps = startNode.getProperties()
		startNode.setProperties(endNode.getProperties())
		endNode.setProperties(tempProps)

		swapStartEnd = false

func setSurfaceMaterial(type: PhysicsSurface.SurfaceType) -> PhysicsSurface.SurfaceType:
	if pipeMesh == null:
		return type

	pipeMesh.set_surface_override_material(0, PhysicsSurface.materials[type])
	pipeMesh.set_surface_override_material(1, PhysicsSurface.materials[PhysicsSurface.SurfaceType.CONCRETE])
	if startNode.cap || endNode.cap:
		pipeMesh.set_surface_override_material(2, PhysicsSurface.materials[PhysicsSurface.SurfaceType.CONCRETE])
	if startNode.cap && endNode.cap:
		pipeMesh.set_surface_override_material(3, PhysicsSurface.materials[PhysicsSurface.SurfaceType.CONCRETE])

	return type

func _ready():

	startNode.dataChanged.connect(refreshMesh)
	endNode.dataChanged.connect(refreshMesh)

	refreshMesh()

var lengthMultiplier: float = 1

func refreshMesh() -> void:
	var vertexCollection = PipeVertexCollection.new()\
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
	var curveSteps: PackedFloat32Array = [0.0]

	for i in (PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1)

		curveOffsets.push_back(
			EditorMath.getCurveLerp(
				startNode.global_position,
				startNode.basis.z,
				endNode.global_position,
				endNode.basis.z,
				t
			)
		)

		if i != 0:
			var distanceStep = curveOffsets[i].distance_to(curveOffsets[i - 1])
			curveLength += distanceStep
			curveSteps.push_back(curveLength)

	for i in (PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier):
		var oldT = float(i) / ((PrefabConstants.PIPE_LENGTH_SEGMENTS * lengthMultiplier) - 1)
		var t = curveSteps[i] / curveLength

		heights.push_back(
			EditorMath.getHeightLerp(
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
	
	var mesh: ProceduralMesh = ProceduralMesh.new()

	mesh.addMeshTo(
		pipeMesh,
		vertexList,
		PrefabConstants.PIPE_WIDTH_SEGMENTS,
		PrefabConstants.PIPE_LENGTH_SEGMENTS,
		lengthMultiplier
	) 

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

	mesh.addMeshTo(
		pipeMesh,
		vertexList,
		PrefabConstants.PIPE_WIDTH_SEGMENTS + 4,
		PrefabConstants.PIPE_LENGTH_SEGMENTS,
		lengthMultiplier,
		true,
		false
	)

	if startNode.cap:
		var startCapVertices = startNode.getCapVertices()
		var vertices3D: PackedVector3Array = []

		for vertex in startCapVertices:
			vertices3D.push_back(PipeVertexCollection.getRotatedVertex(vertex, startNode.basis) + startNode.global_position)

		mesh.addMeshTo(
			pipeMesh,
			vertices3D,
			PrefabConstants.PIPE_WIDTH_SEGMENTS,
			2,
			1,
			false,
			false
		)
	
	if endNode.cap:
		var endCapVertices = endNode.getCapVertices()
		var vertices3D: PackedVector3Array = []

		for vertex in endCapVertices:
			vertices3D.push_back(PipeVertexCollection.getRotatedVertex(vertex, endNode.basis) + endNode.global_position)

		mesh.addMeshTo(
			pipeMesh,
			vertices3D,
			PrefabConstants.PIPE_WIDTH_SEGMENTS,
			2,
			1,
			true,
			false
		)
	
	setSurfaceMaterial(surfaceType)



func convertToPhysicsObject(clearNodes: bool = false) -> void:
	if clearNodes:
		remove_child(startNode)
		startNode.queue_free()
		remove_child(endNode)
		endNode.queue_free()

	pipeMesh.create_trimesh_collision()
	pipeMesh.setPhysicsMaterial(surfaceType)

func getProperties() -> Dictionary:
	return {
		"surfaceType": surfaceType
	}

func setProperties(properties: Dictionary) -> void:
	if properties.has("surfaceType"):
		surfaceType = properties["surfaceType"] as PhysicsSurface.SurfaceType