extends Node3D
class_name Start

signal bodyEnteredStart(body: Node3D, start: Node3D)

func onBodyEntered(body):
	print("[Start.gd] Body entered start: ", body)
	bodyEnteredStart.emit(body, self)

func _ready():
	%StartLine.body_entered.connect(onBodyEntered)

const RAYCAST_MAX_DISTANCE = 100

var raycastPosition = null
var raycastNormal = null

# 10 units back
# 24 units sideways

func isStart():
	pass

func getStartPosition(playerIndex: int, nrPlayers: int) -> Dictionary:
	var localBackwards = -global_transform.basis.x

	var localRight = global_transform.basis.z

	var leftLimit = -localRight * 18
	var rightLimit = localRight * 18

	var playerFraction = remap(playerIndex, 0, nrPlayers - 1, 0, 1)

	if nrPlayers == 1:
		playerFraction = 0.5

	var raycastOrigin = global_position + Vector3.UP * 5 + leftLimit.lerp(rightLimit, playerFraction) + localBackwards * 8

	calculateRaycast(raycastOrigin)

	var spawnPosition = raycastPosition + raycastNormal * 0.35

	# print("Spawn position: ", spawnPosition)

	return {
		"position": spawnPosition,
		"rotation": getRotationVector(-localBackwards, (-localBackwards).cross(raycastNormal).normalized())
	}

func getRotationVector(localForward: Vector3, localRight: Vector3) -> Vector3:
	var localBasis = Basis(localRight, localForward.cross(localRight).normalized(), -localForward)
	var localQuaternion = Quaternion(localBasis.get_rotation_quaternion())

	print("Rotation: ", localQuaternion.get_euler())

	return localQuaternion.get_euler()

func calculateRaycast(origin: Vector3):
	var spaceState = get_world_3d().direct_space_state

	# var from = global_position
	var to = origin + Vector3.DOWN * RAYCAST_MAX_DISTANCE

	var result = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(origin, to))

	if result.has("position"):
		raycastPosition = result.position
		raycastNormal = result.normal
	else:
		raycastPosition = null
		raycastNormal = null
