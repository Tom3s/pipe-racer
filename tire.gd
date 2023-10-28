extends RayCast3D
class_name Tire

var targetRotation: float = 0.0


var visualRotationNode = null
var tireModel = null
var smokeEmitter: GPUParticles3D  = null
var dirtEmitter: GPUParticles3D = null



@export
var tireMass: float = 20.0

@export
var tireIndex: int = 0

@export
var visualRotation: float = 3.0

func _ready():
	visualRotationNode = get_child(0)
	tireModel = get_child(0).get_child(0)
	smokeEmitter = get_child(1)
	smokeEmitter.emitting = false
	smokeEmitter.one_shot = false
	dirtEmitter = get_child(2)
	dirtEmitter.emitting = false
	dirtEmitter.one_shot = false
	set_physics_process(true)

func _physics_process(delta):
	visualRotationNode.rotation.y = rotation.y * visualRotation
