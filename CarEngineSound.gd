extends AudioStreamPlayer3D

@export
var GEAR_STAGE: float = 1
@export
var GEAR_SHIFT_PULLBACK: float = 0.2
@export
var GEAR_SHIFT_SPEED: float = 0.75
@export
var GEAR_SHIFT_NEXT_STAGE: float = 0.2

var prevGearStage = 0
var targetPitchScale: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# playing = true
	play()
	set_physics_process(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if playing:
		pitch_scale = lerp(pitch_scale, targetPitchScale, GEAR_SHIFT_SPEED / max(1, prevGearStage))
		pass

	if floor(targetPitchScale / GEAR_STAGE) > prevGearStage:
		# var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		# tween.tween_property(self, "pitch_scale", pitch_scale + GEAR_SHIFT_NEXT_STAGE, GEAR_SHIFT_TIME_FACTOR).from(pitch_scale * 0.5)
		pitch_scale *= GEAR_SHIFT_PULLBACK
	elif floor(targetPitchScale / GEAR_STAGE) < prevGearStage:
		pitch_scale += (1 - GEAR_SHIFT_PULLBACK) * pitch_scale / 2
	
	volume_db = -8 + clamp(remap(pitch_scale, 1, 2, 0, 1), 0, 1) * 12

	prevGearStage = floor(targetPitchScale / GEAR_STAGE)
	pass
