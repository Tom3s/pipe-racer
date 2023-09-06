extends Area3D
class_name Checkpoint

var collectedMaterial := preload("res://Track Props/CheckPointGreen.tres")
var uncollectedMaterial := preload("res://Track Props/CheckPointRed.tres")

signal bodyEnteredCheckpoint(body, checkpoint: Node3D)

var index: int = -1

var checkpointModel: MeshInstance3D

func _ready():
	body_entered.connect(onBodyEntered)
	checkpointModel = %CheckpointModel
	
	setUncollected()

func onBodyEntered(body):
	print("[Checkpoint.gd] Body entered checkpoint: ", body)
	bodyEnteredCheckpoint.emit(body, self)

var placements: Array = []

func getPlacement(lapNumber: int) -> int:
	if placements.size() <= lapNumber:
		placements.push_back(0)
	
	placements[lapNumber] += 1
	return placements[lapNumber]

func isCheckPoint():
	pass

const RAYCAST_MAX_DISTANCE = 100

var raycastPosition = null
var raycastNormal = null

# 10 units back
# 24 units sideways

func getRespawnPosition(playerIndex: int, nrPlayers: int) -> Dictionary:
	# if raycastPosition == null || raycastNormal == null:
	# 	calculateRaycast()

	# var localBackwards = -global_transform.basis.z

	# var localRight = (-localBackwards).cross(raycastNormal).normalized()

	# var baseSpawnPosition = raycastPosition + raycastNormal * 0.35 # + localBackwards * 8

	# var leftLimit = -localRight * 18
	# var rightLimit = localRight * 18

	# var playerFraction = remap(playerIndex, 0, nrPlayers - 1, 0, 1)

	# if nrPlayers == 1:
	# 	playerFraction = 0.5

	# var spawnPosition = baseSpawnPosition + leftLimit.lerp(rightLimit, playerFraction)

	# print("Spawn position: ", spawnPosition)

	# return {
	# 	"position": spawnPosition,
	# 	"rotation": getRotationVector(-localBackwards, localRight)
	# }

	var localBackwards = -global_transform.basis.z

	var localRight = -global_transform.basis.x

	var leftLimit = -localRight * 18
	var rightLimit = localRight * 18

	var playerFraction = remap(playerIndex, 0, nrPlayers - 1, 0, 1)

	if nrPlayers == 1:
		playerFraction = 0.5

	var raycastOrigin = global_position + Vector3.UP * 24 + leftLimit.lerp(rightLimit, playerFraction)

	calculateRaycast(raycastOrigin)

	var spawnPosition = raycastPosition + raycastNormal * 0.35

	# print("Spawn position: ", spawnPosition)

	return {
		"position": spawnPosition,
		"rotation": getRotationVector(-localBackwards, localRight)
	}

func getRotationVector(localForward: Vector3, localRight: Vector3) -> Vector3:
	var localBasis = Basis(localRight, localForward.cross(localRight).normalized(), -localForward)
	var localQuaternion = Quaternion(localBasis.get_rotation_quaternion())

	print("Rotation: ", localQuaternion.get_euler())

	return localQuaternion.get_euler()

func calculateRaycast(origin: Vector3):
	var spaceState = get_world_3d().direct_space_state

	var to = origin + Vector3.DOWN * RAYCAST_MAX_DISTANCE

	var result = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(origin, to))

	if result.has("position"):
		raycastPosition = result.position
		raycastNormal = result.normal
	else:
		raycastPosition = null
		raycastNormal = null

func collect():
	setCollected()

func setCollected():
	checkpointModel.set_surface_override_material(0, collectedMaterial)

func setUncollected():
	checkpointModel.set_surface_override_material(0, uncollectedMaterial)

func reset():
	setUncollected()
	placements.clear()