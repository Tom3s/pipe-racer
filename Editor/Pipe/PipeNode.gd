@tool
extends Node3D
class_name PipeNode

signal dataChanged()

var oldPos: Vector3 = Vector3.ZERO
var oldRot: Vector3 = Vector3.ZERO

@export_range(0, 2 * PI, 2 * PI / 360.0)
var profile: float = PI:
	set(newValue):
		profile = newValue
		dataChanged.emit()

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE * 64, PrefabConstants.GRID_SIZE)
var radius: int = PrefabConstants.GRID_SIZE * 6:
	set(newValue):
		radius = newValue
		dataChanged.emit()

@export
var flat: bool = false:
	set(newValue):
		flat = newValue
		dataChanged.emit()

@export
var cap: bool = true:
	set(newValue):
		cap = newValue
		dataChanged.emit()


@export
var isPreviewNode: bool = false:
	set(newValue):
		isPreviewNode = newValue
		%Collider.use_collision = !isPreviewNode


func _physics_process(_delta):
	if oldPos != global_position:
		dataChanged.emit()
	oldPos = global_position

	if oldRot != global_rotation:
		dataChanged.emit()
	oldRot = global_rotation

func getStartCircleVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	for i in PrefabConstants.PIPE_WIDTH_SEGMENTS:
		var angle = (PrefabConstants.PIPE_WIDTH_SEGMENTS - i - 1) \
			* profile \
			/ (PrefabConstants.PIPE_WIDTH_SEGMENTS - 1) \
			- global_rotation.z \
			- PI / 2 \
			- profile / 2
		var x = cos(angle) * radius
		var y = sin(angle) * radius

		if flat:
			y = -radius

		vertices.push_back(Vector2(x, y))

	return vertices

func getCapVertices() -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	vertices.append_array(getStartCircleVertices())
	vertices.append_array(
		getCircleVertices(
			global_rotation.z,
			profile,
			radius + PrefabConstants.GRID_SIZE,
			float(flat)
		)
	)


	return vertices

static func getCircleVertices(
	rotation: float,
	profile: float,
	radius: float,
	flat: float = 0.0
) -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	for i in PrefabConstants.PIPE_WIDTH_SEGMENTS:
		var angle = (PrefabConstants.PIPE_WIDTH_SEGMENTS - i - 1) \
			* profile \
			/ (PrefabConstants.PIPE_WIDTH_SEGMENTS - 1) \
			- rotation \
			- PI / 2 \
			- profile / 2
		var x = cos(angle) * radius
		var y = sin(angle) * radius

		y = lerp(y, -radius, flat)

		vertices.push_back(Vector2(x, y))

	return vertices

func getProperties() -> Dictionary:
	return {
		"radius": radius,
		"profile": profile,
		"flat": flat,

		"cap": cap,

		"position": global_position,
		"rotation": global_rotation,
	}

func setProperties(properties: Dictionary):
	if properties.has("radius"):
		radius = properties["radius"]
	if properties.has("profile"):
		profile = properties["profile"]
	if properties.has("flat"):
		flat = properties["flat"]

	if properties.has("cap"):
		cap = properties["cap"]

	if properties.has("position"):
		global_position = properties["position"]
	if properties.has("rotation"):
		global_rotation = properties["rotation"]

	dataChanged.emit()

@onready var pipeNodeScene: PackedScene = preload("res://Editor/Pipe/PipeNode.tscn")

func getCopy() -> PipeNode:
	var newNode: PipeNode = pipeNodeScene.instantiate()
	newNode.setProperties(getProperties())

	return newNode