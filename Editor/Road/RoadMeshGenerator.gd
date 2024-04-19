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
			# var x = lerp(startVertex.x, endVertex.x, ease(t, -1.5))
			var x = lerp(startVertex.x, endVertex.x, smoothstep(0, 1, t))

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

@onready var roadMesh: PhysicsSurface = %RoadMesh
@onready var runoffMesh: PhysicsSurface = %RunoffMesh
@onready var wallMesh: PhysicsSurface = %WallMesh
@onready var supportMesh: PhysicsSurface = %SupportMesh



# var materials = [
# 	preload("res://Tracks/AsphaltMaterial.tres"), # ROAD
# 	preload("res://Track Props/GrassMaterial.tres"), # GRASS
# 	preload("res://Track Props/DirtMaterial.tres"), # DIRT
# 	preload("res://Track Props/BoosterMaterial.tres"), # BOOSTER	
# 	preload("res://Track Props/BoosterMaterialReversed.tres"), # REVERSE BOOSTER	
# 	preload("res://Tracks/RacetrackMaterial.tres") # CONCRETE
# ]

@export
var surfaceType: PhysicsSurface.SurfaceType = PhysicsSurface.SurfaceType.ROAD:
	set(newValue):
		surfaceType = setSurfaceMaterial(newValue)

func setSurfaceMaterial(type: PhysicsSurface.SurfaceType) -> PhysicsSurface.SurfaceType:
	if roadMesh == null:
		return type

	roadMesh.set_surface_override_material(0, PhysicsSurface.materials[type])
	roadMesh.set_surface_override_material(1, PhysicsSurface.materials[PhysicsSurface.SurfaceType.CONCRETE])
	if startNode.cap || endNode.cap:
		roadMesh.set_surface_override_material(2, PhysicsSurface.materials[PhysicsSurface.SurfaceType.CONCRETE])
	if startNode.cap && endNode.cap:
		roadMesh.set_surface_override_material(3, PhysicsSurface.materials[PhysicsSurface.SurfaceType.CONCRETE])

	return type

enum WallTypes {
	NONE,
	NORMAL,
	GUARDRAIL,
	ROUND,
	FENCE,
}

var wallProfiles = [
	[],
	_getNormalWallProfile(),
	_getGuardrailProfile(),
	_getRockWallProfile(),
	_getFenceWallProfile()
]


# Wall Profiles
# region Wall Profiles
func _getNormalWallProfile() -> PackedVector2Array:
	var wallProfile: PackedVector2Array = []

	var wallWidth = PrefabConstants.GRID_SIZE / 2

	wallProfile.push_back(Vector2(-wallWidth, 0))
	wallProfile.push_back(Vector2(-wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(-wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(wallWidth, 0))	

	return wallProfile

func _getGuardrailProfile() -> PackedVector2Array:
	var wallProfile: PackedVector2Array = []

	var wallWidth = PrefabConstants.GRID_SIZE / 8

	wallProfile.push_back(Vector2(-wallWidth, 0))
	wallProfile.push_back(Vector2(-wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(-wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(wallWidth, PrefabConstants.GRID_SIZE))
	wallProfile.push_back(Vector2(wallWidth, 0))	

	return wallProfile

func _getRockWallProfile() -> PackedVector2Array:
	var wallProfile: PackedVector2Array = []

	var wallWidth = PrefabConstants.GRID_SIZE / 2

	var segments = 6

	for i in segments:
		var angle = (segments - i - 1) * (PI / (segments - 1))
		var x = cos(angle) * wallWidth
		var y = sin(angle) * wallWidth

		wallProfile.push_back(Vector2(x, y))
	
	return wallProfile

func _getFenceWallProfile() -> PackedVector2Array:
	var wallProfile: PackedVector2Array = []

	var wallWidth = PrefabConstants.GRID_SIZE / 8
	var topOffset = PrefabConstants.GRID_SIZE / 2

	wallProfile.push_back(Vector2(-wallWidth, 0))
	wallProfile.push_back(Vector2(-wallWidth, PrefabConstants.GRID_SIZE * 2))
	wallProfile.push_back(Vector2(-wallWidth + topOffset, PrefabConstants.GRID_SIZE * 2 + topOffset))
	wallProfile.push_back(Vector2(wallWidth + topOffset, PrefabConstants.GRID_SIZE * 2 + topOffset))
	wallProfile.push_back(Vector2(wallWidth, PrefabConstants.GRID_SIZE * 2))
	wallProfile.push_back(Vector2(wallWidth, 0))

	return wallProfile

# endregion

@export
var wallSurfaceType: PhysicsSurface.SurfaceType = PhysicsSurface.SurfaceType.FENCE:
	set(newValue):
		wallSurfaceType = setWallMaterial(newValue)

func setWallMaterial(type: PhysicsSurface.SurfaceType) -> PhysicsSurface.SurfaceType:
	if wallMesh == null:
		return type

	var surface = 0

	if leftWallType != WallTypes.NONE || rightWallType != WallTypes.NONE:
		wallMesh.set_surface_override_material(surface, PhysicsSurface.materials[type])
		surface += 1
	if leftWallType != WallTypes.NONE && rightWallType != WallTypes.NONE:
		wallMesh.set_surface_override_material(surface, PhysicsSurface.materials[type])
		surface += 1
	
	for i in wallCapCount:
		wallMesh.set_surface_override_material(surface, PhysicsSurface.materials[type])
		surface += 1

	return type

@export
var startWallCap: bool = true:
	set(newValue):
		startWallCap = newValue
		if wallMesh == null:
			return

		refreshWallMesh()

@export
var endWallCap: bool = true:
	set(newValue):
		endWallCap = newValue
		if wallMesh == null:
			return

		refreshWallMesh()

@export
var leftWallType: WallTypes = WallTypes.NONE:
	set(newValue):
		leftWallType = newValue
		if wallMesh == null:
			return

		refreshWallMesh()

@export_range(0.0, 3, 0.1)
var leftWallStartHeight: float = 1.0:
	set(newValue):
		leftWallStartHeight = newValue
		if wallMesh == null:
			return

		refreshWallMesh()

@export_range(0.0, 3, 0.1)
var leftWallEndHeight: float = 1.0:
	set(newValue):
		leftWallEndHeight = newValue
		if wallMesh == null:
			return

		refreshWallMesh()

@export
var rightWallType: WallTypes = WallTypes.NONE:
	set(newValue):
		rightWallType = newValue
		if wallMesh == null:
			return

		refreshWallMesh()

@export_range(0.0, 3, 0.1)
var rightWallStartHeight: float = 1.0:
	set(newValue):
		rightWallStartHeight = newValue
		if wallMesh == null:
			return

		refreshWallMesh()

@export_range(0.0, 3, 0.1)
var rightWallEndHeight: float = 1.0:
	set(newValue):
		rightWallEndHeight = newValue
		if wallMesh == null:
			return

		refreshWallMesh()


enum SupportType {
	NONE,
	SOLID,
	RECT_PILLAR,
	ROUND_PILLAR,
	SCAFFOLDING,
}

@export
var supportType: SupportType = SupportType.NONE:
	set(newValue):
		supportType = newValue
		if wallMesh == null:
			return

		refreshSupportMesh()

@export_range(PrefabConstants.GRID_SIZE * -256, PrefabConstants.GRID_SIZE * 256, PrefabConstants.GRID_SIZE)
var supportBottomHeight: float = 0.0:
	set(newValue):
		supportBottomHeight = newValue
		if wallMesh == null:
			return

		refreshSupportMesh()

@export
var supportMaterial: PhysicsSurface.SurfaceType = PhysicsSurface.SurfaceType.CONCRETE:
	set(newValue):
		supportMaterial = newValue
		if wallMesh == null:
			return

		refreshSupportMesh()

func setSupportMaterial(type: PhysicsSurface.SurfaceType) -> PhysicsSurface.SurfaceType:
	if supportMesh == null:
		return type

	supportMesh.set_surface_override_material(0, PhysicsSurface.materials[type])

	return type


@export
var leftRunoffSurfaceType: PhysicsSurface.SurfaceType = PhysicsSurface.SurfaceType.GRASS:
	set(newValue):
		leftRunoffSurfaceType = setLeftRunoffMaterial(newValue)

func setLeftRunoffMaterial(type: PhysicsSurface.SurfaceType) -> PhysicsSurface.SurfaceType:
	if runoffMesh == null:
		return type

	if startNode.leftRunoff != 0 || endNode.leftRunoff != 0:
		runoffMesh.set_surface_override_material(0, PhysicsSurface.materials[type])
		
	
	return type

@export
var rightRunoffSurfaceType: PhysicsSurface.SurfaceType = PhysicsSurface.SurfaceType.GRASS:
	set(newValue):
		rightRunoffSurfaceType = setRightRunoffMaterial(newValue)

func setRightRunoffMaterial(type: PhysicsSurface.SurfaceType, ) -> PhysicsSurface.SurfaceType:
	if runoffMesh == null:
		return type

	# runoffMesh.set_surface_override_material(0, PhysicsSurface.materials[type])
	var surface = 0
	if startNode.leftRunoff != 0 || endNode.leftRunoff != 0:
		surface = 1
	
	if startNode.rightRunoff != 0 || endNode.rightRunoff != 0:
		runoffMesh.set_surface_override_material(surface, PhysicsSurface.materials[type])
	
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

	startNode.transformChanged.connect(refreshAll)
	endNode.transformChanged.connect(refreshAll)



	startNode.roadDataChanged.connect(refreshAll)
	endNode.roadDataChanged.connect(refreshAll)

	startNode.runoffDataChanged.connect(refreshRunoffMesh)
	endNode.runoffDataChanged.connect(refreshRunoffMesh)

	refreshAll()

var lengthMultiplier: float = 1
var vertexList: PackedVector3Array = []
var curveOffsets: PackedVector3Array = []
var heights: PackedVector3Array = []
var vertexCollection = RoadVertexCollection.new()
var mesh: ProceduralMesh = ProceduralMesh.new()

func refreshAll() -> void:
	refreshRoadMesh()
	refreshRunoffMesh()
	refreshWallMesh()
	refreshSupportMesh()

func refreshRoadMesh() -> void:
	vertexCollection\
		.withStart(startNode.getStartVertices(), startNode.basis)\
		.withEnd(endNode.getStartVertices(), endNode.basis)
	
	vertexList = []

	curveOffsets = []

	heights = []

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

func refreshRunoffMesh() -> void:
	# vertexCollection\
	# 	.withStart(startNode.getStartVertices(), startNode.basis)\
	# 	.withEnd(endNode.getStartVertices(), endNode.basis)

	runoffMesh.mesh = ArrayMesh.new()

	if startNode.leftRunoff != 0 || endNode.leftRunoff != 0:
		vertexList = PackedVector3Array()

		# vertexCollection.startVertices = startNode.getLeftRunoffVertices()
		# vertexCollection.endVertices = endNode.getLeftRunoffVertices()
		vertexCollection\
			.withStart(startNode.getLeftRunoffVertices(), startNode.basis)\
			.withEnd(endNode.getLeftRunoffVertices(), endNode.basis)

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

		# vertexCollection.startVertices = startNode.getRightRunoffVertices()
		# vertexCollection.endVertices = endNode.getRightRunoffVertices()
		vertexCollection\
			.withStart(startNode.getRightRunoffVertices(), startNode.basis)\
			.withEnd(endNode.getRightRunoffVertices(), endNode.basis)

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
	
	setLeftRunoffMaterial(leftRunoffSurfaceType)
	setRightRunoffMaterial(rightRunoffSurfaceType)

var wallCapCount: int = 0

func refreshWallMesh() -> void:
	wallMesh.mesh = ArrayMesh.new()

	if leftWallType != WallTypes.NONE:
		vertexList = PackedVector3Array()

		# vertexCollection.startVertices = startNode.getLeftWallVertices(wallProfiles[leftWallType], leftWallStartHeight)
		# vertexCollection.endVertices = endNode.getLeftWallVertices(wallProfiles[leftWallType], leftWallEndHeight)
		vertexCollection\
			.withStart(startNode.getLeftWallVertices(wallProfiles[leftWallType], leftWallStartHeight), startNode.basis)\
			.withEnd(endNode.getLeftWallVertices(wallProfiles[leftWallType], leftWallEndHeight), endNode.basis)

		for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
			var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
			
			var interpolatedVertices = vertexCollection.getInterpolation(
				t, 
				curveOffsets[i] + 
				heights[i] 
			)
			vertexList.append_array(interpolatedVertices)
		
		mesh.addMeshTo(
			wallMesh,
			vertexList,
			wallProfiles[leftWallType].size(),
			PrefabConstants.ROAD_LENGTH_SEGMENTS,
			lengthMultiplier,
			true,
			false,
		)
	
	if rightWallType != WallTypes.NONE:
		vertexList = PackedVector3Array()

		# vertexCollection.startVertices = startNode.getRightWallVertices(wallProfiles[rightWallType], rightWallStartHeight)
		# vertexCollection.endVertices = endNode.getRightWallVertices(wallProfiles[rightWallType], rightWallEndHeight)
		vertexCollection\
			.withStart(startNode.getRightWallVertices(wallProfiles[rightWallType], rightWallStartHeight), startNode.basis)\
			.withEnd(endNode.getRightWallVertices(wallProfiles[rightWallType], rightWallEndHeight), endNode.basis)

		for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
			var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
			
			var interpolatedVertices = vertexCollection.getInterpolation(
				t, 
				curveOffsets[i] + 
				heights[i] 
			)
			vertexList.append_array(interpolatedVertices)
		
		mesh.addMeshTo(
			wallMesh,
			vertexList,
			wallProfiles[rightWallType].size(),
			PrefabConstants.ROAD_LENGTH_SEGMENTS,
			lengthMultiplier,
			false,
			false,
		)

	wallCapCount = 0

	if startWallCap:
		if rightWallType != WallTypes.NONE && rightWallStartHeight != 0:
			var startCapVertices = startNode.getRightWallVertices(wallProfiles[rightWallType], rightWallStartHeight)
			wallCapCount += 1
			addWallCap(startCapVertices, startNode, true)
		if leftWallType != WallTypes.NONE && leftWallStartHeight != 0:
			var startCapVertices = startNode.getLeftWallVertices(wallProfiles[leftWallType], leftWallStartHeight)
			wallCapCount += 1
			addWallCap(startCapVertices, startNode, false)
	
	if endWallCap:
		if rightWallType != WallTypes.NONE && rightWallEndHeight != 0:
			var endCapVertices = endNode.getRightWallVertices(wallProfiles[rightWallType], rightWallEndHeight)
			wallCapCount += 1
			addWallCap(endCapVertices, endNode, false)
		if leftWallType != WallTypes.NONE && leftWallEndHeight != 0:
			var endCapVertices = endNode.getLeftWallVertices(wallProfiles[leftWallType], leftWallEndHeight)
			wallCapCount += 1
			addWallCap(endCapVertices, endNode, true)
			
	
	setWallMaterial(wallSurfaceType)

func refreshSupportMesh() -> void:
	supportMesh.mesh = ArrayMesh.new()

	if supportType == SupportType.NONE:
		return
	
	if supportType == SupportType.SOLID:
		vertexList = PackedVector3Array()

		var startLeft: Vector2 = Vector2(-startNode.width / 2, -PrefabConstants.GRID_SIZE)
		var endLeft: Vector2 = Vector2(-endNode.width / 2, -PrefabConstants.GRID_SIZE)
		
		vertexCollection\
			.withStart([startLeft], startNode.basis)\
			.withEnd([endLeft], endNode.basis)
		
		for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
			var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
			
			var interpolatedVertices = vertexCollection.getInterpolation(
				t, 
				curveOffsets[i] + 
				heights[i] 
			)
			vertexList.append_array(interpolatedVertices)
		
		var endRight: Vector2 = Vector2(endNode.width / 2, -PrefabConstants.GRID_SIZE)
		var startRight: Vector2 = Vector2(startNode.width / 2, -PrefabConstants.GRID_SIZE)

		vertexCollection\
			.withStart([startRight], startNode.basis)\
			.withEnd([endRight], endNode.basis)
		
		for i in (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier):
			var t = float(i) / ((PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - 1)
			
			t = 1 - t
			i = (PrefabConstants.ROAD_LENGTH_SEGMENTS * lengthMultiplier) - i - 1

			var interpolatedVertices = vertexCollection.getInterpolation(
				t, 
				curveOffsets[i] + 
				heights[i] 
			)
			vertexList.append_array(interpolatedVertices)
		
		vertexList.push_back(vertexList[0])

		var bottomVertexList: PackedVector3Array = []

		for vertex in vertexList:
			bottomVertexList.push_back(Vector3(vertex.x, supportBottomHeight, vertex.z))
		
		vertexList.append_array(bottomVertexList)

		mesh.addMeshTo(
			supportMesh,
			vertexList,
			(PrefabConstants.ROAD_LENGTH_SEGMENTS * 2 * lengthMultiplier) + 1,
			2,
			1,
			false,
			true
		)

		setSupportMaterial(supportMaterial)

		return


func addWallCap(vertices: PackedVector2Array, node: Node3D, clockwise: bool) -> void:
	var vertices3D: PackedVector3Array = []

	for i in vertices.size():
		var vertex: Vector2 = vertices[i]
		if i >= vertices.size() / 2:
			vertex = vertices[vertices.size() - i - 1 - vertices.size() / 2]
		
		vertices3D.push_back(RoadVertexCollection.getRotatedVertex(vertex, node.basis) + node.global_position)
	
	mesh.addMeshTo(
		wallMesh,
		vertices3D,
		vertices.size() / 2,
		2,
		1,
		clockwise,
		false
	)

func convertToPhysicsObject() -> void:
	startNode.visible = false
	endNode.visible = false

	roadMesh.create_trimesh_collision()
	roadMesh.setPhysicsMaterial(surfaceType)

	wallMesh.create_trimesh_collision()
	wallMesh.setPhysicsMaterial(wallSurfaceType)

	runoffMesh.create_trimesh_collision()
	runoffMesh.setPhysicsMaterial(leftRunoffSurfaceType)