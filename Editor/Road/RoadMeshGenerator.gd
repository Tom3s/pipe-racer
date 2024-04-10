@tool
extends Node3D
class_name RoadMeshGenerator

class RoadVertexCollection:
	var startVertices: PackedVector2Array = []
	var endVertices: PackedVector2Array = []

	var startBasis: Basis = Basis()
	var endBasis: Basis = Basis()


	func withStart(
		vertices: PackedVector2Array,
		basis: Basis
	) -> RoadVertexCollection:
		startVertices = vertices
		startBasis = basis
		return self
	
	func withEnd(
		vertices: PackedVector2Array,
		basis: Basis
	) -> RoadVertexCollection:
		endVertices = vertices
		endBasis = basis
		return self
	
	func getInterpolation(t: float, offset: Vector3 = Vector3.ZERO) -> PackedVector3Array:

		var result: PackedVector3Array = []

		var currentBasis = startBasis.slerp(endBasis, t)

		for i in startVertices.size():
			var startVertex = startVertices[i]
			var endVertex = endVertices[i]

			var y = lerp(startVertex.y, endVertex.y, t)
			var x = lerp(startVertex.x, endVertex.x, ease(t, -1.5))

			var vertex3D = RoadVertexCollection.getRotatedVertex(Vector2(x, y), currentBasis)

			result.push_back(vertex3D + offset)

		return result

	static func getRotatedVertex(
		vertex: Vector2,
		basis: Basis
	) -> Vector3:
		var vertex3D = Vector3(vertex.x, vertex.y, 0)

		# vertex3D = vertex3D.rotated(Vector3.BACK, basis.get_euler().z)

		vertex3D = basis * vertex3D

		return vertex3D

@onready var startNode: RoadNode = %Start
@onready var endNode: RoadNode = %End

@onready var roadMesh: MeshInstance3D = %RoadMesh
@onready var runoffMesh: MeshInstance3D = %RunoffMesh

enum SurfaceType {
	ROAD,
	GRASS,
	DIRT,
	BOOSTER,
	REVERSE_BOOSTER,
	CONCRETE
}

var materials = [
	preload("res://Tracks/AsphaltMaterial.tres"), # ROAD
	preload("res://Track Props/GrassMaterial.tres"), # GRASS
	preload("res://Track Props/DirtMaterial.tres"), # DIRT
	preload("res://Track Props/BoosterMaterial.tres"), # BOOSTER	
	preload("res://Track Props/BoosterMaterialReversed.tres"), # REVERSE BOOSTER	
	preload("res://Tracks/RacetrackMaterial.tres") # CONCRETE
]

@export
var surfaceType: SurfaceType = SurfaceType.ROAD:
	set(newValue):
		surfaceType = setSurfaceMaterial(newValue)

func setSurfaceMaterial(type: SurfaceType) -> SurfaceType:
	if roadMesh == null:
		return type

	roadMesh.set_surface_override_material(0, materials[type])
	roadMesh.set_surface_override_material(1, materials[SurfaceType.CONCRETE])
	if startNode.cap || endNode.cap:
		roadMesh.set_surface_override_material(2, materials[SurfaceType.CONCRETE])
	if startNode.cap && endNode.cap:
		roadMesh.set_surface_override_material(3, materials[SurfaceType.CONCRETE])

	return type

@export
var swapStartEnd: bool = false:
	set(newValue):
		if startNode == null or endNode == null:
			return
		var tempProps = startNode.getProperties()
		startNode.setProperties(endNode.getProperties())
		endNode.setProperties(tempProps)

		swapStartEnd = false

func _ready():

	startNode.dataChanged.connect(refreshMesh)
	endNode.dataChanged.connect(refreshMesh)

	refreshMesh()

var lengthMultiplier: float = 1

func refreshMesh() -> void:
	var vertexCollection = RoadVertexCollection.new()\
		.withStart(startNode.getStartVertices(), startNode.basis)\
		.withEnd(endNode.getStartVertices(), endNode.basis)
	
	var vertexList: PackedVector3Array = []

	var curveOffsets: PackedVector3Array = []

	var heights: PackedVector3Array = []

	var distance = startNode.global_position.distance_to(endNode.global_position)
	# if distance > PrefabConstants.TRACK_WIDTH:
	lengthMultiplier = ceilf(distance / PrefabConstants.TRACK_WIDTH)

	var curveLength: float = 0
	var curveSteps: PackedFloat32Array = [0.0]

	for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)

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

	for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
		var oldT = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
		var t = curveSteps[i] / curveLength

		# print("[roadMeshGenerator.gd] T difference: ", oldT - t)

		# print("[roadMeshGenerator.gd] Current height t: ", t, " - ", curveSteps[i], " / ", curveLength)
		
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

	for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
		
		var interpolatedVertices = vertexCollection.getInterpolation(
			t, 
			curveOffsets[i] + 
			heights[i]
		)
		vertexList.append_array(interpolatedVertices)
	
	var mesh: ProceduralMesh = ProceduralMesh.new()

	mesh.addMeshTo(
		roadMesh,
		vertexList,
		PrefabConstants.ROAD_WIDTH_SEGMENTS,
		PrefabConstants.ROAD_LENGTH_SEGMENTS,
		lengthMultiplier,
		false
	) 

	# Outside part

	vertexList = PackedVector3Array()

	vertexCollection.startVertices = startNode.getOutsideVertices()
	vertexCollection.endVertices = endNode.getOutsideVertices()

	for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
		var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
		
		var interpolatedVertices = vertexCollection.getInterpolation(
			t, 
			curveOffsets[i] + 
			heights[i] 
		)
		vertexList.append_array(interpolatedVertices)

	mesh.addMeshTo(
		roadMesh,
		vertexList,
		6,
		PrefabConstants.ROAD_LENGTH_SEGMENTS,
		lengthMultiplier,
		true,
		false
	)

	if startNode.cap:
		var startCapVertices = startNode.getCapVertices()
		var vertices3D: PackedVector3Array = []

		for vertex in startCapVertices:
			vertices3D.push_back(RoadVertexCollection.getRotatedVertex(vertex, startNode.basis) + startNode.global_position)

		mesh.addMeshTo(
			roadMesh,
			vertices3D,
			PrefabConstants.ROAD_WIDTH_SEGMENTS,
			2,
			1,
			true,
			false
		)
	
	if endNode.cap:
		var endCapVertices = endNode.getCapVertices()
		var vertices3D: PackedVector3Array = []

		for vertex in endCapVertices:
			vertices3D.push_back(RoadVertexCollection.getRotatedVertex(vertex, endNode.basis) + endNode.global_position)

		mesh.addMeshTo(
			roadMesh,
			vertices3D,
			PrefabConstants.ROAD_WIDTH_SEGMENTS,
			2,
			1,
			false,
			false
		)
	
	setSurfaceMaterial(surfaceType)

	runoffMesh.mesh = ArrayMesh.new()

	if startNode.leftRunoff != 0 || endNode.leftRunoff != 0:
		vertexList = PackedVector3Array()

		vertexCollection.startVertices = startNode.getLeftRunoffVertices()
		vertexCollection.endVertices = endNode.getLeftRunoffVertices()

		for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
			var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
			
			var interpolatedVertices = vertexCollection.getInterpolation(
				t, 
				curveOffsets[i] + 
				heights[i] 
			)
			vertexList.append_array(interpolatedVertices)
		
		mesh.addMeshTo(
			runoffMesh,
			vertexList,
			PrefabConstants.ROAD_WIDTH_SEGMENTS + 4,
			PrefabConstants.ROAD_LENGTH_SEGMENTS,
			lengthMultiplier,
			false,
			false
		)
	
	if startNode.rightRunoff != 0 || endNode.rightRunoff != 0:
		vertexList = PackedVector3Array()

		vertexCollection.startVertices = startNode.getRightRunoffVertices()
		vertexCollection.endVertices = endNode.getRightRunoffVertices()

		for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
			var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
			
			var interpolatedVertices = vertexCollection.getInterpolation(
				t, 
				curveOffsets[i] + 
				heights[i] 
			)
			vertexList.append_array(interpolatedVertices)
		
		mesh.addMeshTo(
			runoffMesh,
			vertexList,
			PrefabConstants.ROAD_WIDTH_SEGMENTS + 4,
			PrefabConstants.ROAD_LENGTH_SEGMENTS,
			lengthMultiplier,
			true,
			false
		)