@tool
extends Node3D
class_name ProceduralStartLine

@onready var checkeredLine: MeshInstance3D = %CheckeredLine
@onready var poles: MeshInstance3D = %Poles
@onready var flag: MeshInstance3D = %Flag

@onready var arrow: Node3D = %Arrow

var poleMaterial: Material = preload("res://Track Props/StartLinePoleMaterial.tres")
var flagMaterial: Material = preload("res://Track Props/StartLineFlagMaterial.tres")

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * 4, PrefabConstants.GRID_SIZE)
var width: float = PrefabConstants.TRACK_WIDTH:
	set(newValue):
		width = newValue
		refreshAllMesh()

@export_range(PrefabConstants.GRID_SIZE * 2, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var height: float = 24.0:
	set(newValue):
		height = newValue
		refreshAllMesh()


const LINE_HEIGHT: float = 0.5
const LINE_THICKNESS: float = 4

func _ready():
	refreshAllMesh()

func refreshAllMesh():
	refreshCheckeredLine()
	refreshPoles()
	refreshFlag()

func refreshCheckeredLine():
	if checkeredLine == null:
		return
	var checkeredMesh: BoxMesh = checkeredLine.mesh 

	checkeredMesh.size = Vector3(width, LINE_HEIGHT, LINE_THICKNESS)
	checkeredLine.position = Vector3(0, LINE_HEIGHT / 2, 0)

	var checkeredMaterial: ShaderMaterial = checkeredLine.get_surface_override_material(0)

	checkeredMaterial.set_shader_parameter("FrequencyY", 4)
	checkeredMaterial.set_shader_parameter("FrequencyX", width / (LINE_THICKNESS / 4) * 1.5)

var proceduralMesh: ProceduralMesh = ProceduralMesh.new()

const POLE_SUPPORT_FREQUENCY: float = PrefabConstants.GRID_SIZE

func refreshPoles():
	if poles == null:
		return
	
	poles.mesh = ArrayMesh.new()

	# left side
	var leftTop: Vector3 = Vector3(-width / 2, height, 0)
	var leftBottom: Vector3 = Vector3(-width / 2, 0, 0)

	addPole(leftTop, leftBottom, PrefabConstants.GRID_SIZE / 12, true)

	var leftOffset1: Vector3 = Vector3(-PrefabConstants.GRID_SIZE / 1.5, 0, 0)
	var leftOffset2: Vector3 = Vector3(-PrefabConstants.GRID_SIZE / 3, 0, PrefabConstants.GRID_SIZE / 2.25)  

	addPole(
		leftTop + leftOffset1 + Vector3.DOWN * POLE_SUPPORT_FREQUENCY,
		leftBottom + leftOffset1,
		PrefabConstants.GRID_SIZE / 12,
		true
	)

	addPole(
		leftTop + leftOffset2 + Vector3.DOWN * POLE_SUPPORT_FREQUENCY,
		leftBottom + leftOffset2,
		PrefabConstants.GRID_SIZE / 12,
		true
	)

	# add crossbeams
	addCrossbeams(leftTop, leftOffset1, leftOffset2)


	# right side
	var rightTop: Vector3 = Vector3(width / 2, height, 0)
	var rightBottom: Vector3 = Vector3(width / 2, 0, 0)

	addPole(rightTop, rightBottom, PrefabConstants.GRID_SIZE / 12, true)

	var rightOffset1: Vector3 = Vector3(PrefabConstants.GRID_SIZE / 1.5, 0, 0)
	var rightOffset2: Vector3 = Vector3(PrefabConstants.GRID_SIZE / 3, 0, PrefabConstants.GRID_SIZE / 2.25)

	addPole(
		rightTop + rightOffset1 + Vector3.DOWN * POLE_SUPPORT_FREQUENCY,
		rightBottom + rightOffset1,
		PrefabConstants.GRID_SIZE / 12,
		true
	)

	addPole(
		rightTop + rightOffset2 + Vector3.DOWN * POLE_SUPPORT_FREQUENCY,
		rightBottom + rightOffset2,
		PrefabConstants.GRID_SIZE / 12,
		true
	)

	# add crossbeams
	addCrossbeams(rightTop, rightOffset1, rightOffset2)

	# set Material
	for i in poles.mesh.get_surface_count():
		poles.set_surface_override_material(i, poleMaterial)

func addCrossbeams(
	mainPole: Vector3,
	offset1: Vector3,
	offset2: Vector3,
) -> void:
	var currentHeight: float = height - POLE_SUPPORT_FREQUENCY / 8 - POLE_SUPPORT_FREQUENCY
	var crossbeamWidth: float = PrefabConstants.GRID_SIZE / 24

	mainPole.y = 0

	addPole(
		mainPole + Vector3.UP * (currentHeight + POLE_SUPPORT_FREQUENCY),
		mainPole + Vector3.UP * currentHeight + offset1,
		crossbeamWidth,
	)
	
	addPole(
		mainPole + Vector3.UP * (currentHeight + POLE_SUPPORT_FREQUENCY),
		mainPole + Vector3.UP * currentHeight + offset2,
		crossbeamWidth,
	)

	while currentHeight > POLE_SUPPORT_FREQUENCY:
		addPole(
			mainPole + Vector3.UP * currentHeight,
			mainPole + Vector3.UP * currentHeight + offset1,
			crossbeamWidth,
		)

		addPole(
			mainPole + Vector3.UP * currentHeight + offset2,
			mainPole + Vector3.UP * currentHeight,
			crossbeamWidth,
		)

		addPole(
			mainPole + Vector3.UP * currentHeight + offset1,
			mainPole + Vector3.UP * currentHeight + offset2,
			crossbeamWidth,
		)
		
		addPole(
			mainPole + Vector3.UP * currentHeight,
			mainPole + Vector3.UP * (currentHeight - POLE_SUPPORT_FREQUENCY) + offset1,
			crossbeamWidth,
		)

		addPole(
			mainPole + Vector3.UP * currentHeight + offset2,
			mainPole + Vector3.UP * (currentHeight - POLE_SUPPORT_FREQUENCY),
			crossbeamWidth,
		)

		addPole(
			mainPole + Vector3.UP * currentHeight + offset1,
			mainPole + Vector3.UP * (currentHeight - POLE_SUPPORT_FREQUENCY) + offset2,
			crossbeamWidth,
		)


		currentHeight -= POLE_SUPPORT_FREQUENCY


	addPole(
			mainPole + Vector3.UP * currentHeight,
			mainPole + Vector3.UP * currentHeight + offset1,
			crossbeamWidth,
		)

	addPole(
		mainPole + Vector3.UP * currentHeight + offset2,
		mainPole + Vector3.UP * currentHeight,
		crossbeamWidth,
	)

	addPole(
		mainPole + Vector3.UP * currentHeight + offset1,
		mainPole + Vector3.UP * currentHeight + offset2,
		crossbeamWidth,
	)
	
	addPole(
		mainPole + Vector3.UP * currentHeight,
		mainPole + Vector3.UP * POLE_SUPPORT_FREQUENCY / 8 + offset1,
		crossbeamWidth,
	)

	addPole(
		mainPole + Vector3.UP * currentHeight + offset2,
		mainPole + Vector3.UP * POLE_SUPPORT_FREQUENCY / 8,
		crossbeamWidth,
	)

	addPole(
		mainPole + Vector3.UP * currentHeight + offset1,
		mainPole + Vector3.UP * POLE_SUPPORT_FREQUENCY / 8 + offset2,
		crossbeamWidth,
	)

func addPole(
	from: Vector3,
	to: Vector3,
	radius: float,
	caps: bool = false
) -> void:
	var pipeVertices: PackedVector3Array = ProceduralMesh.getPipeVertices(
		from,
		to,
		radius
	)

	proceduralMesh.addMeshTo(
		poles,
		pipeVertices,
		pipeVertices.size() / 2,
		2,
		1,
		false,
		false
	)

	if !caps:
		return
		
	var capVertices: PackedVector3Array = ProceduralMesh.getPipeCapVertices(
		pipeVertices
	)

	proceduralMesh.addMeshTo(
		poles,
		capVertices,
		capVertices.size() / 2,
		2,
		1,
		true,
		false
	)

const FLAG_WIDTH: float = PrefabConstants.GRID_SIZE * 1.25
const FLAG_THICKNESS: float = PrefabConstants.GRID_SIZE / 24
const FLAG_DENT: float = PrefabConstants.GRID_SIZE / 2

const FLAG_SEGMENTS: int = 20

func refreshFlag():
	if flag == null:
		return

	var vertices: PackedVector3Array = PackedVector3Array()
	for i in FLAG_SEGMENTS:
		var t: float = float(i) / (FLAG_SEGMENTS - 1)

		var x: float = lerp(-width / 2, width / 2, t)
		var y: float = height - lerp(0.0, FLAG_DENT, sqrt(t))
		if t > 0.5:
			y = height - lerp(0.0, FLAG_DENT, sqrt(1 - t))
		
		vertices.push_back(Vector3(x, y, -FLAG_THICKNESS / 2))
		vertices.push_back(Vector3(x, y, FLAG_THICKNESS / 2))
		vertices.push_back(Vector3(x, y, FLAG_THICKNESS / 2))
		vertices.push_back(Vector3(x, y - FLAG_WIDTH, FLAG_THICKNESS / 2))
		vertices.push_back(Vector3(x, y - FLAG_WIDTH, FLAG_THICKNESS / 2))
		vertices.push_back(Vector3(x, y - FLAG_WIDTH, -FLAG_THICKNESS / 2))
		vertices.push_back(Vector3(x, y - FLAG_WIDTH, -FLAG_THICKNESS / 2))
		vertices.push_back(Vector3(x, y, -FLAG_THICKNESS / 2))
	
	proceduralMesh.addMeshTo(
		flag,
		vertices,
		8,
		vertices.size() / 8,
		1,
		true
	)

	flag.mesh.surface_set_material(0, flagMaterial)

func getProperties() -> Dictionary:
	return {
		"width": width,
		"height": height,

		"position": global_position,
		"rotation": global_rotation,
	}

func setProperties(properties: Dictionary) -> void:
	if properties.has("width"):
		width = properties["width"]
	if properties.has("height"):
		height = properties["height"]
	
	if properties.has("position"):
		global_position = properties["position"]
	if properties.has("rotation"):
		global_rotation = properties["rotation"]

func convertToPhysicsObject() -> void:
	# if checkeredLine.get_child_count() > 0:
	# 	for child in checkeredLine.get_children():
	# 		child.queue_free()
	# checkeredLine.create_trimesh_collision()
	# checkeredLine.setPhysicsMaterial(PhysicsSurface.SurfaceType.ROAD)

	if poles.get_child_count() > 0:
		for child in poles.get_children():
			child.queue_free()
	poles.create_trimesh_collision()
	poles.setPhysicsMaterial(PhysicsSurface.SurfaceType.ROAD)

	if flag.get_child_count() > 0:
		for child in flag.get_children():
			child.queue_free()
	flag.create_trimesh_collision()
	flag.setPhysicsMaterial(PhysicsSurface.SurfaceType.ROAD)
