@tool
extends Node3D
class_name RoadNode

# signal positionChanged(position: Vector3)
# signal rotationChanged(rotation: Vector3)
signal dataChanged()

var oldPos: Vector3 = Vector3.ZERO
var oldRot: Vector3 = Vector3.ZERO

@export
var profile: Curve = Curve.new():
	set(newValue):
		profile = newValue
		# profile.bake()
		dataChanged.emit()

@export_range(0, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var profileHeight: float = PrefabConstants.GRID_SIZE:
	set(newValue):
		profileHeight = newValue
		dataChanged.emit()

@export_range(PrefabConstants.GRID_SIZE, 3 * PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var width: float = PrefabConstants.TRACK_WIDTH:
	set(newValue):
		width = newValue
		dataChanged.emit()


@export
var cap: bool = false:
	set(newValue):
		cap = newValue
		dataChanged.emit()


@export_range(0, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var leftRunoff: float = 0.0:
	set(newValue):
		leftRunoff = newValue
		dataChanged.emit()

@export_range(0, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var rightRunoff: float = 0.0:
	set(newValue):
		rightRunoff = newValue
		dataChanged.emit()


# func _ready():
	# profile.texture_mode = CurveTexture.TEXTURE_MODE_RED
	# profile.width = 256


func _physics_process(_delta):
	if oldPos != global_position:
		dataChanged.emit()
	oldPos = global_position

	if oldRot != global_rotation:
		dataChanged.emit()
	oldRot = global_rotation

func getStartVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	for i in PrefabConstants.ROAD_WIDTH_SEGMENTS:
		var t = float(i) / (PrefabConstants.ROAD_WIDTH_SEGMENTS - 1)
		var x = lerp(-width / 2, width / 2, t)

		var y = profile.sample(t) * profileHeight

		vertices.push_back(Vector2(x, y))

	return vertices

func getOutsideVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	vertices.push_back(
		Vector2(-width / 2, profile.sample(0) * profileHeight)
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
		Vector2(width / 2, profile.sample(1) * profileHeight)
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

		var y = profile.sample(0) * profileHeight

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

		var y = profile.sample(1) * profileHeight

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

func getProperties() -> Dictionary:
	return {
		"profile": profile,
		"profileHeight": profileHeight,
		"width": width,
		"cap": cap,

		"position": global_position,
		"rotation": global_rotation,
	}

func setProperties(properties: Dictionary):
	profile = properties["profile"]
	profileHeight = properties["profileHeight"]
	width = properties["width"]
	cap = properties["cap"]

	global_position = properties["position"]
	global_rotation = properties["rotation"]

	dataChanged.emit()