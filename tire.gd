extends RayCast3D
class_name Tire

var targetRotation: float = 0.0


var tireModel = null
var smokeEmitter: GPUParticles3D  = null
var dirtEmitter: GPUParticles3D = null



@export
var tireMass: float = 20.0

@export
var tireIndex: int = 0

@export
var visualRotation: float = 2.0

func _ready():
	tireModel = get_child(0)
	smokeEmitter = get_child(1)
	smokeEmitter.emitting = false
	smokeEmitter.one_shot = false
	dirtEmitter = get_child(2)
	dirtEmitter.emitting = false
	dirtEmitter.one_shot = false
	set_physics_process(true)
