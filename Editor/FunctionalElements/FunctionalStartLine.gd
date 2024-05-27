@tool
extends Node3D
class_name FunctionalStartLine

@export_range(PrefabConstants.GRID_SIZE, PrefabConstants.TRACK_WIDTH * 4, PrefabConstants.GRID_SIZE)
var width: float = PrefabConstants.TRACK_WIDTH:
	set(newValue):
		width = newValue
		proceduralStartLine.width = newValue
		setCollisionShape()

@export_range(PrefabConstants.GRID_SIZE * 2, PrefabConstants.TRACK_WIDTH, PrefabConstants.GRID_SIZE)
var height: float = 24.0:
	set(newValue):
		height = newValue
		proceduralStartLine.height = newValue
		setCollisionShape()



@onready var proceduralStartLine: ProceduralStartLine = %ProceduralStartLine
@onready var areaCollisionShape: CollisionShape3D = %AreaCollisionShape
# @onready var arrow: Node3D = %Arrow

func setCollisionShape():
	var boxShape = areaCollisionShape.shape as BoxShape3D

	boxShape.size = Vector3(width, height + 4, 4)
	areaCollisionShape.position = Vector3(0, height / 2 - 2, 0)

signal bodyEnteredStart(body: Node3D, start: Node3D)

func onBodyEntered(body):
	print("[Start.gd] Body entered start: ", body)
	bodyEnteredStart.emit(body, self)

func _ready():
	%StartArea.body_entered.connect(onBodyEntered)
	setCollisionShape()


const RAYCAST_MAX_DISTANCE = PrefabConstants.TRACK_WIDTH * 4

var raycastPosition = null
var raycastNormal = null

func getStartPosition(playerIndex: int, nrPlayers: int) -> Dictionary:
	var localBackwards = global_transform.basis.z

	var localRight = global_transform.basis.x

	var extents: float = (width / 2) * 0.85

	var leftLimit = -localRight * extents
	var rightLimit = localRight * extents

	var playerFraction = remap(playerIndex, 0, nrPlayers - 1, 0, 1)

	if nrPlayers == 1:
		playerFraction = 0.5

	var raycastOrigin = global_position + Vector3.UP * 5 + leftLimit.lerp(rightLimit, playerFraction) + localBackwards * 8.0 # 7.99 magic number to avoid missing between faces

	calculateRaycast(raycastOrigin)

	var spawnPosition = raycastPosition + raycastNormal * 0.35

	return {
		"position": spawnPosition,
		"rotation": getRotationVector(-localBackwards, (-localBackwards).cross(raycastNormal).normalized())
	}

func getRotationVector(localForward: Vector3, localRight: Vector3) -> Vector3:
	var localBasis = Basis(localRight, localForward.cross(localRight).normalized(), -localForward)
	var localQuaternion = Quaternion(localBasis.get_rotation_quaternion())

	return localQuaternion.get_euler()

func calculateRaycast(origin: Vector3):
	var spaceState = get_world_3d().direct_space_state

	var to = origin - global_transform.basis.y * RAYCAST_MAX_DISTANCE

	var result = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(origin, to, 1))

	if result.has("position"):
		raycastPosition = result.position
		raycastNormal = result.normal
	else:
		raycastPosition = null
		raycastNormal = null

func setArrowVisibility(visible: bool):
	proceduralStartLine.arrow.visible = visible

func getProperties() -> Dictionary:
	return {
		"width": width,
		"height": height,

		"position": global_position,
		"rotation": global_rotation,
	}

func setProperties(properties: Dictionary, setTransform: bool = true) -> void:
	if properties.has("width"):
		width = properties["width"]
	if properties.has("height"):
		height = properties["height"]
		
	if setTransform:
		if properties.has("position"):
			global_position = properties["position"]
		if properties.has("rotation"):
			global_rotation = properties["rotation"]
	
func convertToPhysicsObject() -> void:
	proceduralStartLine.convertToPhysicsObject()

func getExportData() -> Dictionary:
	var data = {
		"position": var_to_str(global_position),
		"rotation": var_to_str(global_rotation),
	}

	if width != PrefabConstants.TRACK_WIDTH:
		data["width"] = width
	if height != 24.0:
		data["height"] = height

	return data