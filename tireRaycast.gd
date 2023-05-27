extends RayCast3D

var targetRotation: Vector3

const ROTATION_SPEED = 0.1


func _ready():
	targetRotation = rotation

func _process(delta):
	rotation = lerp(rotation, targetRotation, ROTATION_SPEED)
