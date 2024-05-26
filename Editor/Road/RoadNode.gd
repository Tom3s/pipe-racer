@tool
extends Node3D
class_name RoadNode

# var meshGenerator_s: RoadMeshGenerator
# var meshGenerator_e: RoadMeshGenerator
var meshGeneratorRefs: Array[RoadMeshGenerator] = []

signal transformChanged()
signal roadDataChanged()
signal runoffDataChanged()

var oldPos: Vector3 = Vector3.ZERO
var oldRot: Vector3 = Vector3.ZERO

enum RoadProfile {
	FLAT,
	BOWL,
	SAUSAGE,
	DOUBLE_BOWL,
	DOUBLE_BUMP,
	SHARP_BOWL,
	SHARP_SAUSAGE,
	VERY_BUMPY,
	WHEEL_PATH
}
const profiles = [
	preload("res://Editor/Road/Profiles/Flat.tres"),
	preload("res://Editor/Road/Profiles/Bowl.tres"),
	preload("res://Editor/Road/Profiles/Sausage.tres"),
	preload("res://Editor/Road/Profiles/DoubleBowl.tres"),
	preload("res://Editor/Road/Profiles/DoubleBump.tres"),
	preload("res://Editor/Road/Profiles/SharpBowl.tres"),
	preload("res://Editor/Road/Profiles/SharpSausage.tres"),
	preload("res://Editor/Road/Profiles/VeryBumpy.tres"),
	preload("res://Editor/Road/Profiles/WheelPath.tres")
]

var profileCurve: Curve = Curve.new()

@export
var profileType: RoadProfile = RoadProfile.FLAT:
	set(newValue):
		profileType = newValue
		profileCurve = profiles[profileType]
		roadDataChanged.emit()

@export_range(0, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var profileHeight: float = PrefabConstants.GRID_SIZE:
	set(newValue):
		profileHeight = newValue
		roadDataChanged.emit()

@export_range(PrefabConstants.GRID_SIZE, 3 * PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var width: float = PrefabConstants.TRACK_WIDTH:
	set(newValue):
		width = newValue
		roadDataChanged.emit()


@export
var cap: bool = false:
	set(newValue):
		cap = newValue
		roadDataChanged.emit()


@export_range(0, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var leftRunoff: float = 0.0:
	set(newValue):
		leftRunoff = newValue
		runoffDataChanged.emit()

@export_range(0, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var rightRunoff: float = 0.0:
	set(newValue):
		rightRunoff = newValue
		runoffDataChanged.emit()


func _ready():
	profileCurve = profiles[profileType]

@export
var isPreviewNode: bool = false:
	set(newValue):
		isPreviewNode = newValue
		%Collider.use_collision = !isPreviewNode

func _physics_process(_delta):
	if oldPos != global_position:
		transformChanged.emit()
	oldPos = global_position

	if oldRot != global_rotation:
		transformChanged.emit()
	oldRot = global_rotation

func getStartVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	for i in PrefabConstants.ROAD_WIDTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.ROAD_WIDTH_SEGMENTS - 1)
		var x = lerp(-width / 2, width / 2, t)

		var y = profileCurve.sample(t) * profileHeight

		vertices.push_back(Vector2(x, y))

	return vertices

func getOutsideVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	vertices.push_back(
		Vector2(-width / 2, profileCurve.sample(0) * profileHeight)
	)
	
	vertices.push_back(
		Vector2(-width / 2, -PrefabConstants.GRID_SIZE)
	)
	vertices.push_back(
		Vector2(-width / 2, -PrefabConstants.GRID_SIZE)
	)

	vertices.push_back(
		Vector2(width / 2, -PrefabConstants.GRID_SIZE)
	)
	vertices.push_back(
		Vector2(width / 2, -PrefabConstants.GRID_SIZE)
	)

	vertices.push_back(
		Vector2(width / 2, profileCurve.sample(1) * profileHeight)
	)

	return vertices


func getCapVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	vertices.append_array(getStartVertices())
	
	for i in PrefabConstants.ROAD_WIDTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.ROAD_WIDTH_SEGMENTS - 1)
		var x = lerp(-width / 2, width / 2, t)

		var y = -PrefabConstants.GRID_SIZE

		vertices.push_back(Vector2(x, y))

	return vertices


func getRightRunoffVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	for i in PrefabConstants.ROAD_WIDTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.ROAD_WIDTH_SEGMENTS - 1)
		var x = lerp(-width / 2, -width / 2 - rightRunoff, t)

		var y = profileCurve.sample(0) * profileHeight

		vertices.push_back(Vector2(x, y))
		if i == PrefabConstants.ROAD_WIDTH_SEGMENTS - 1:
			vertices.push_back(Vector2(x, y))

	vertices.push_back(
		Vector2(-width / 2 - rightRunoff, -PrefabConstants.GRID_SIZE)
	)
	vertices.push_back(
		Vector2(-width / 2 - rightRunoff, -PrefabConstants.GRID_SIZE)
	)

	vertices.push_back(
		Vector2(-width / 2, -PrefabConstants.GRID_SIZE)
	)

	return vertices		

func getLeftRunoffVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	for i in PrefabConstants.ROAD_WIDTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.ROAD_WIDTH_SEGMENTS - 1)
		var x = lerp(width / 2, width / 2 + leftRunoff, t)

		var y = profileCurve.sample(1) * profileHeight

		vertices.push_back(Vector2(x, y))
		if i == PrefabConstants.ROAD_WIDTH_SEGMENTS - 1:
			vertices.push_back(Vector2(x, y))

	vertices.push_back(
		Vector2(width / 2 + leftRunoff, -PrefabConstants.GRID_SIZE)
	)
	vertices.push_back(
		Vector2(width / 2 + leftRunoff, -PrefabConstants.GRID_SIZE)
	)

	vertices.push_back(
		Vector2(width / 2, -PrefabConstants.GRID_SIZE)
	)

	return vertices

func getRightWallVertices(wallProfile: PackedVector2Array, height: float) -> PackedVector2Array:
	var vertices: PackedVector2Array = []
	for i in wallProfile.size():
		var vertex = wallProfile[i]
		
		var p1 = profileCurve.sample(0) * profileHeight
		var p2 = profileCurve.sample(PrefabConstants.GRID_SIZE / width) * profileHeight

		var angle = atan2(p2 - p1, PrefabConstants.GRID_SIZE)

		vertex = vertex.rotated(angle)
		
		vertex.x -= width / 2 - PrefabConstants.GRID_SIZE / 2
		vertex.y *= height 


		var height1 = (p1 + p2) / 2
		var height2 = profileCurve.sample(PrefabConstants.GRID_SIZE / width/ 2) * profileHeight
		vertex.y += min(height1, height2)

		vertices.push_back(vertex)

	return vertices

func getLeftWallVertices(wallProfile: PackedVector2Array, height: float) -> PackedVector2Array:
	var vertices: PackedVector2Array = []
	for i in wallProfile.size():
		var vertex = wallProfile[i]
		# flip profile
		vertex.x = -vertex.x
		
		var p1 = profileCurve.sample(1) * profileHeight
		var p2 = profileCurve.sample(1 - PrefabConstants.GRID_SIZE / width) * profileHeight

		var angle = atan2(p1 - p2, PrefabConstants.GRID_SIZE)

		vertex = vertex.rotated(angle)

		vertex.x += width / 2 - PrefabConstants.GRID_SIZE / 2
		vertex.y *= height


		var height1 = (p1 + p2) / 2
		var height2 = profileCurve.sample(1 - PrefabConstants.GRID_SIZE / width/ 2) * profileHeight
		vertex.y += min(height1, height2)

		
		vertices.push_back(vertex)

	return vertices

func getProperties() -> Dictionary:
	return {
		"profileType": profileType,
		"profileHeight": profileHeight,
		"width": width,
		"cap": cap,

		"leftRunoff": leftRunoff,
		"rightRunoff": rightRunoff,

		"position": global_position,
		"rotation": global_rotation,
	}

func setProperties(properties: Dictionary):
	if properties.has("profileType"):
		profileType = properties["profileType"]
	if properties.has("profileHeight"):
		profileHeight = properties["profileHeight"]
	if properties.has("width"):
		width = properties["width"]
	if properties.has("cap"):
		cap = properties["cap"]

	if properties.has("leftRunoff"):
		leftRunoff = properties["leftRunoff"]
	if properties.has("rightRunoff"):
		rightRunoff = properties["rightRunoff"]

	if properties.has("position"):
		global_position = properties["position"]
	if properties.has("rotation"):
		global_rotation = properties["rotation"]

	roadDataChanged.emit()

@onready var roadNodeScene: PackedScene = preload("res://Editor/Road/RoadNode.tscn")

func getCopy() -> RoadNode:
	var newNode: RoadNode = roadNodeScene.instantiate()
	newNode.setProperties(getProperties())

	return newNode
