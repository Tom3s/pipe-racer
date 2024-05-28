@tool
extends Node3D
class_name FunctionalCheckpoint



@export_range(PrefabConstants.GRID_SIZE / 2, 16.0, PrefabConstants.GRID_SIZE / 2)
var ringWidth: float = 4.0:
	set(newValue):
		ringWidth = newValue
		# if proceduralCheckpoint != null:
		proceduralCheckpoint.ringWidth = ringWidth
		setCollisionShape()


@export_range(16.0, 128.0, PrefabConstants.GRID_SIZE)
var ringRadius: float = 32.0:
	set(newValue):
		ringRadius = newValue
		# if proceduralCheckpoint != null:
		proceduralCheckpoint.ringRadius = ringRadius
		setCollisionShape()

@export
var isPreview: bool = false:
	set(newValue):
		isPreview = newValue
		if proceduralCheckpoint != null:
			proceduralCheckpoint.collider.use_collision = !isPreview


@onready var proceduralCheckpoint: ProceduralCheckpoint = %ProceduralCheckpoint
@onready var areaCollisionShape: CollisionShape3D = %AreaCollisionShape

func setCollisionShape():
	var cylinderShape = areaCollisionShape.shape as CylinderShape3D

	cylinderShape.radius = ringRadius + 1
	areaCollisionShape.position = Vector3.ZERO
	areaCollisionShape.rotation = Vector3(deg_to_rad(90), 0, 0)

signal bodyEnteredCheckpoint(body: Node3D, checkpoint: Node3D)

func _ready():
	%CheckpointArea.body_entered.connect(onBodyEntered)
	isPreview = isPreview	

	proceduralCheckpoint.ringWidth = ringWidth
	proceduralCheckpoint.ringRadius = ringRadius

	setCollisionShape()

func onBodyEntered(body):
	print("[Checkpoint.gd] Body entered checkpoint: ", body)
	bodyEnteredCheckpoint.emit(body, self)

var index: int = -1

var placements: Array = []

func getPlacement(lapNumber: int) -> int:
	if placements.size() <= lapNumber:
		placements.push_back(0)
	
	placements[lapNumber] += 1
	return placements[lapNumber]

const RAYCAST_MAX_DISTANCE = 140

var raycastPosition = null
var raycastNormal = null


func getRespawnPosition(playerIndex: int, nrPlayers: int) -> Dictionary:
	var localBackwards = global_transform.basis.z

	var localRight = global_transform.basis.x

	var extents: float = (ringRadius) * 0.85

	var leftLimit = -localRight * extents
	var rightLimit = localRight * extents

	var playerFraction = remap(playerIndex, 0, nrPlayers - 1, 0, 1)

	if nrPlayers == 1:
		playerFraction = 0.5

	var raycastOrigin = global_position + (localBackwards.normalized() * 0.001) + Vector3.UP * 24 + leftLimit.lerp(rightLimit, playerFraction)

	calculateRaycast(raycastOrigin)

	var spawnPosition = raycastPosition + raycastNormal * 0.35

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

	var to = origin + Vector3.DOWN * RAYCAST_MAX_DISTANCE

	var result = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(origin, to, 1 + 32))

	if result.has("position"):
		raycastPosition = result.position
		raycastNormal = result.normal
	else:
		raycastPosition = null
		raycastNormal = null


func collect():
	setCollected()

func setCollected():
	proceduralCheckpoint.setCollected()

func setUncollected():
	proceduralCheckpoint.setUncollected()

func reset():
	setUncollected()
	placements.clear()

@onready var arrow: Node3D = %Arrow
@onready var centerPoint: MeshInstance3D = %CenterPoint

func setArrowVisibility(visible: bool):
	arrow.visible = visible
	centerPoint.visible = visible

func getProperties() -> Dictionary:
	return {
		"ringWidth": ringWidth,
		"ringRadius": ringRadius,

		"position": global_position,
		"rotation": global_rotation,
	}

func setProperties(properties: Dictionary, setTransform: bool = true) -> void:
	if properties.has("ringWidth"):
		ringWidth = properties["ringWidth"]
	if properties.has("ringRadius"):
		ringRadius = properties["ringRadius"]
		
	if setTransform:
		if properties.has("position"):
			global_position = properties["position"]
		if properties.has("rotation"):
			global_rotation = properties["rotation"]

@onready var checkpointScene: PackedScene = preload("res://Editor/FunctionalElements/FunctionalCheckpoint.tscn")

func getCopy() -> FunctionalCheckpoint:
	var newNode: FunctionalCheckpoint = checkpointScene.instantiate()
	# newNode.setProperties(getProperties())

	return newNode

func getExportData() -> Dictionary:
	var data = {
		"position": var_to_str(global_position),
		"rotation": var_to_str(global_rotation),
	}

	if ringRadius != 32.0:
		data["ringRadius"] = ringRadius
	if ringWidth != 4.0:
		data["ringWidth"] = ringWidth
	
	return data
	
