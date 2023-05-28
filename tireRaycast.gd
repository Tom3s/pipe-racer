extends RayCast3D

var targetRotation: Vector3

const ROTATION_SPEED = 0.1


func _ready():
	targetRotation = rotation

	set_physics_process(true)

func _physics_process(delta):
	rotation = lerp(rotation, targetRotation, ROTATION_SPEED)
