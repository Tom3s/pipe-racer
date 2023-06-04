extends RayCast3D

var targetRotation: Vector3

const ROTATION_SPEED = 0.08

var remoteTransform: RemoteTransform3D


func _ready():
	targetRotation = rotation
	if get_child_count() > 0:
		remoteTransform = get_child(0)
	else:
		remoteTransform = null
	set_physics_process(true)

func _physics_process(delta):
	rotation = lerp(rotation, targetRotation, ROTATION_SPEED)
	if remoteTransform != null:
		remoteTransform.rotation = rotation
