@tool
extends Node3D
class_name LedBoard

var boardMaterial: Material = preload("res://Track Props/SignMaterial.tres")
var metalMaterial: Material = preload("res://Track Props/SimpleBlackMetal.tres")

@onready var boardMesh: MeshInstance3D = %BoardMesh
@onready var supportMesh: MeshInstance3D = %SupportMesh

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE * 512, PrefabConstants.GRID_SIZE)
var width: float = 80:
	set(newValue):
		width = newValue
		refreshAll()

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE * 512, PrefabConstants.GRID_SIZE)
var height: float = 48:
	set(newValue):
		height = newValue 
		refreshAll()

@export
var support: bool = true:
	set(newValue):
		support = newValue
		refreshSupportMesh()

@export_range(PrefabConstants.GRID_SIZE * -256, 0, PrefabConstants.GRID_SIZE)
var supportBottomHeight: float = -PrefabConstants.GRID_SIZE * 4:
	set(newValue):
		supportBottomHeight = newValue
		if supportMesh == null:
			return

		refreshSupportMesh()



func _ready():
	refreshAll()

func refreshAll() -> void:
	refreshBoardMesh()
	refreshBackMesh()

	refreshSupportMesh()

var proceduralMesh: ProceduralMesh = ProceduralMesh.new()

func refreshBoardMesh() -> void:
	var centeringOffset: Vector3 = Vector3(-width / 2, -height / 2, 0)
	var vertices: PackedVector3Array = PackedVector3Array()

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)

	proceduralMesh.addMeshTo(
		boardMesh,
		vertices,
		2,
		2, 
		1,
		false
	)

	setBoardMaterial()

func refreshBackMesh() -> void:
	var centeringOffset: Vector3 = Vector3(-width / 2, -height / 2, 0)
	var vertices: PackedVector3Array = PackedVector3Array()

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, height, -PrefabConstants.GRID_SIZE) + centeringOffset)
	
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, -PrefabConstants.GRID_SIZE) + centeringOffset)
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, -PrefabConstants.GRID_SIZE) + centeringOffset)

	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)
	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)

	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)
	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, -PrefabConstants.GRID_SIZE) + centeringOffset)

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, height, -PrefabConstants.GRID_SIZE) + centeringOffset)

	proceduralMesh.addMeshTo(
		boardMesh,
		vertices,
		2,
		8, 
		1,
		false,
		false
	)

	centeringOffset = Vector3(-width / 2, -height / 2, -PrefabConstants.GRID_SIZE)
	vertices = PackedVector3Array()

	vertices.push_back(Vector3(0, height, 0) + centeringOffset)
	vertices.push_back(Vector3(width, height, 0) + centeringOffset)
	vertices.push_back(Vector3(0, 0, 0) + centeringOffset)
	vertices.push_back(Vector3(width, 0, 0) + centeringOffset)

	proceduralMesh.addMeshTo(
		boardMesh,
		vertices,
		2,
		2, 
		1,
		true,
		false
	)

	setBackMaterial()

func setBoardMaterial() -> void:
	var newMaterial: ShaderMaterial = boardMaterial.duplicate()
	newMaterial.set_shader_parameter("width", width)
	newMaterial.set_shader_parameter("height", height)
	newMaterial.set_shader_parameter("Pixel_Amount", 14)
	boardMesh.set_surface_override_material(0, newMaterial)


func setBackMaterial() -> void:
	boardMesh.set_surface_override_material(1, metalMaterial)
	boardMesh.set_surface_override_material(2, metalMaterial)


func refreshSupportMesh() -> void:
	supportMesh.mesh = ArrayMesh.new()
	if !support:
		return

	var centeringOffset: Vector3 = Vector3(-width / 2, -height / 2, 0)
	var vertices: PackedVector3Array = PackedVector3Array()

	var pipeVertices: PackedVector3Array = PackedVector3Array()

	# leftSupport
	var leftTop := Vector3(PrefabConstants.GRID_SIZE * 2, height - PrefabConstants.GRID_SIZE * 2, -PrefabConstants.GRID_SIZE * 2) + centeringOffset
	var leftBottom := Vector3(PrefabConstants.GRID_SIZE * 2, supportBottomHeight, -PrefabConstants.GRID_SIZE * 2) + centeringOffset
	pipeVertices = getPipeVertices(
		leftTop,
		leftBottom,
		PrefabConstants.GRID_SIZE / 2
	)

	proceduralMesh.addMeshTo(
		supportMesh,
		pipeVertices,
		pipeVertices.size() / 2, 
		2,
		1,
		false,
		true
	)

	var leftCapVertices: PackedVector3Array = pipeVertices.slice(0, pipeVertices.size() / 2)
	var extraVertices: PackedVector3Array = leftCapVertices.slice(leftCapVertices.size() / 2, leftCapVertices.size() - 1)
	extraVertices.reverse()
	leftCapVertices = leftCapVertices.slice(0, leftCapVertices.size() / 2)
	leftCapVertices.append_array(extraVertices)

	proceduralMesh.addMeshTo(
		supportMesh,
		leftCapVertices,
		leftCapVertices.size() / 2, 
		2,
		1,
		true,
		false
	)


	# rightSupport
	var rightTop := Vector3(width - PrefabConstants.GRID_SIZE * 2, height - PrefabConstants.GRID_SIZE * 2, -PrefabConstants.GRID_SIZE * 2) + centeringOffset
	var rightBottom := Vector3(width - PrefabConstants.GRID_SIZE * 2, supportBottomHeight, -PrefabConstants.GRID_SIZE * 2) + centeringOffset
	
	pipeVertices = getPipeVertices(
		rightTop,
		rightBottom,
		PrefabConstants.GRID_SIZE / 2
	)

	proceduralMesh.addMeshTo(
		supportMesh,
		pipeVertices,
		pipeVertices.size() / 2, 
		2,
		1,
		false,
		false
	)

	var rightCapVertices: PackedVector3Array = pipeVertices.slice(0, pipeVertices.size() / 2)
	extraVertices = rightCapVertices.slice(rightCapVertices.size() / 2, rightCapVertices.size() - 1)
	extraVertices.reverse()
	rightCapVertices = rightCapVertices.slice(0, rightCapVertices.size() / 2)
	rightCapVertices.append_array(extraVertices)

	proceduralMesh.addMeshTo(
		supportMesh,
		rightCapVertices,
		rightCapVertices.size() / 2, 
		2,
		1,
		true,
		false
	)

	# beams
	var beamVertices: PackedVector3Array = PackedVector3Array()

	for i in range(0, 3):
		var beamStart: Vector3 = lerp(rightTop, Vector3(rightTop.x, -height / 2, rightTop.z), float(i) / 3)

		var beamOffset1: Vector3 = Vector3(PrefabConstants.GRID_SIZE * 1.5, -1.5, PrefabConstants.GRID_SIZE * 1.5)
		var beamOffset2: Vector3 = Vector3(-PrefabConstants.GRID_SIZE * 1.5, -1.5, PrefabConstants.GRID_SIZE * 1.5)

		beamVertices = getPipeVertices(
			beamStart + Vector3(0, -1.5, 0),
			beamStart + beamOffset1,
			PrefabConstants.GRID_SIZE / 4
		)

		proceduralMesh.addMeshTo(
			supportMesh,
			beamVertices,
			beamVertices.size() / 2, 
			2,
			1,
			false,
			false
		)
		
		beamVertices = getPipeVertices(
			beamStart + Vector3(0, -1.5, 0),
			beamStart + beamOffset2,
			PrefabConstants.GRID_SIZE / 4
		)

		proceduralMesh.addMeshTo(
			supportMesh,
			beamVertices,
			beamVertices.size() / 2, 
			2,
			1,
			false,
			false
		)
	
	for i in range(0, 3):
		var beamStart: Vector3 = lerp(leftTop, Vector3(leftTop.x, -height / 2, leftTop.z), float(i) / 3)

		var beamOffset1: Vector3 = Vector3(PrefabConstants.GRID_SIZE * 1.5, -1.5, PrefabConstants.GRID_SIZE * 1.5)
		var beamOffset2: Vector3 = Vector3(-PrefabConstants.GRID_SIZE * 1.5, -1.5, PrefabConstants.GRID_SIZE * 1.5)

		beamVertices = getPipeVertices(
			beamStart + Vector3(0, -1.5, 0),
			beamStart + beamOffset1,
			PrefabConstants.GRID_SIZE / 4
		)

		proceduralMesh.addMeshTo(
			supportMesh,
			beamVertices,
			beamVertices.size() / 2, 
			2,
			1,
			false,
			false
		)
		
		beamVertices = getPipeVertices(
			beamStart + Vector3(0, -1.5, 0),
			beamStart + beamOffset2,
			PrefabConstants.GRID_SIZE / 4
		)

		proceduralMesh.addMeshTo(
			supportMesh,
			beamVertices,
			beamVertices.size() / 2, 
			2,
			1,
			false,
			false
		)

	var currentHeight: float = leftTop.y

	var crossBeamHeight: float = height * 0.64

	while currentHeight - crossBeamHeight >= supportBottomHeight:
		var offset: Vector3 = Vector3(0, -2, 0)

		var beamStart1: Vector3 = Vector3(leftTop.x, currentHeight, leftTop.z) + offset
		var beamStart2: Vector3 = Vector3(rightTop.x, currentHeight, rightTop.z) + offset

		var beamEnd1: Vector3 = Vector3(rightTop.x, currentHeight - crossBeamHeight, rightTop.z) + offset
		var beamEnd2: Vector3 = Vector3(leftTop.x, currentHeight - crossBeamHeight, leftTop.z) + offset

		beamVertices = getPipeVertices(
			beamStart1,
			beamEnd1,
			PrefabConstants.GRID_SIZE / 4
		)

		proceduralMesh.addMeshTo(
			supportMesh,
			beamVertices,
			beamVertices.size() / 2, 
			2,
			1,
			false,
			false
		)

		beamVertices = getPipeVertices(
			beamStart2,
			beamEnd2,
			PrefabConstants.GRID_SIZE / 4
		)

		proceduralMesh.addMeshTo(
			supportMesh,
			beamVertices,
			beamVertices.size() / 2, 
			2,
			1,
			false,
			false
		)

		currentHeight -= crossBeamHeight * 1.12

	setSupportMaterial()

func setSupportMaterial() -> void:
	for i in range(0, supportMesh.mesh.get_surface_count()):
		supportMesh.set_surface_override_material(i, metalMaterial)


func getPipeVertices(
	a: Vector3,
	b: Vector3,
	radius: float,
) -> PackedVector3Array:
	var segments: int = 8
	var vertices: PackedVector3Array = PackedVector3Array()

	var profile: PackedVector3Array = PackedVector3Array()

	for i in segments + 1:
		var angle: float = i * 2 * PI / segments
		profile.push_back(Vector3(cos(angle) * radius, sin(angle) * radius, 0))

	var forward: Vector3 = (b - a).normalized()
	var tangent: Vector3 = Vector3(-forward.z, 0, forward.x).normalized() 
	if tangent.length() == 0:
		tangent = Vector3(0, 0, 1)


	var rotationBasis: Basis = Basis(
		tangent,
		tangent.cross(forward),
		forward
	)

	for i in segments + 1:
		var vertex: Vector3 = profile[i]

		vertex = rotationBasis * vertex + a

		vertices.push_back(vertex)

	for i in segments + 1:
		var vertex: Vector3 = profile[i]

		vertex = rotationBasis * vertex + b

		vertices.push_back(vertex) 

	return vertices

