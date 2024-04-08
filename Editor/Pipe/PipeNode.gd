@tool
extends Node3D
class_name PipeNode

# signal positionChanged(position: Vector3)
# signal rotationChanged(rotation: Vector3)
signal dataChanged()

var oldPos: Vector3 = Vector3.ZERO
var oldRot: Vector3 = Vector3.ZERO

@export_range(0, 2 * PI, 2 * PI / 360.0)
var profile: float = PI:
	set(newValue):
		profile = newValue
		dataChanged.emit()

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.GRID_SIZE * 64, PrefabConstants.GRID_SIZE)
var radius: float = PrefabConstants.GRID_SIZE:
	set(newValue):
		radius = newValue
		dataChanged.emit()

func _physics_process(_delta):
	if oldPos != global_position:
		# positionChanged.emit(global_position)
		dataChanged.emit()
	oldPos = global_position

	if oldRot != global_rotation:
		# rotationChanged.emit(global_rotation)
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
		var x = cos(angle) #* radius
		var y = sin(angle) #* radius
		vertices.push_back(Vector2(x, y) * radius)

	return vertices
		
static func getCircleVertices(
	rotation: float,
	profile: float,
	radius: float
) -> PackedVector2Array:
	var vertices: PackedVector2Array = []

	for i in PrefabConstants.PIPE_WIDTH_SEGMENTS:
		var angle = (PrefabConstants.PIPE_WIDTH_SEGMENTS - i - 1) \
			* profile \
			/ (PrefabConstants.PIPE_WIDTH_SEGMENTS - 1) \
			- rotation \
			- PI / 2 \
			- profile / 2
		var x = cos(angle) #* radius
		var y = sin(angle) #* radius
		vertices.push_back(Vector2(x, y) * radius)

	return vertices