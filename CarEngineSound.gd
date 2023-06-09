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
var playingIdle = false

var gearPlayers: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	# playing = true
	# play()
	set_physics_process(true)
	gearPlayers = [GEAR2, GEAR3, GEAR4, GEAR5, GEAR6]
	# GEAR2.play()
	pass # Replace with function body.

@onready
var IDLE = %Idle

@onready
var GEAR1 = %Gear1

@onready
var GEAR2 = %Gear2

@onready
var GEAR3 = %Gear3

@onready
var GEAR4 = %Gear4

@onready
var GEAR5 = %Gear5

@onready
var GEAR6 = %Gear6

var currentGearStage: int
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# if playing:
	# pitch_scale = lerp(pitch_scale, targetPitchScale, GEAR_SHIFT_SPEED / max(1, prevGearStage))

	# currentGearStage = floor(targetPitchScale / GEAR_STAGE)
	currentGearStage = min(floor(targetPitchScale), 4)
	for gear in gearPlayers:
		# gear.stop()
		gear.pitch_scale = targetPitchScale - int(targetPitchScale) + 1
		# gear.volume_db = volume_db

	# if currentGearStage > prevGearStage && currentGearStage >= 2:
	# 	# var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	# 	# tween.tween_property(self, "pitch_scale", pitch_scale + GEAR_SHIFT_NEXT_STAGE, GEAR_SHIFT_TIME_FACTOR).from(pitch_scale * 0.5)
	# 	# currentGearStage = prevGearStage + 1 // currentGearStage : 1 - 7 => prevGearStage : 0 - 6
	# 	pitch_scale *= GEAR_SHIFT_PULLBACK
	# 	gearPlayers[currentGearStage - 2].stop()
	# 	gearPlayers[currentGearStage - 1].play() 

	# elif currentGearStage < prevGearStage && currentGearStage >= 1:
	# 	pitch_scale += (1 - GEAR_SHIFT_PULLBACK) * pitch_scale / 2
	# 	# currentGearStage = prevGearStage - 1
	# 	gearPlayers[currentGearStage].stop()
	# 	gearPlayers[currentGearStage - 1].play()
	
	# volume_db = -8 + clamp(remap(pitch_scale, 1, 2, 0, 1), 0, 1) * 12
	
	# if targetPitchScale <= 0.75:
	# 	for gear in gearPlayers:
	# 		gear.stop()
	# 	IDLE.play()
	# elif IDLE.playing:
	# 	IDLE.stop()
	# 	GEAR1.play()
	if playingIdle:
		if !IDLE.playing:
			IDLE.play()
			for gear in gearPlayers:
				gear.stop()
	elif !playingIdle && IDLE.playing:
		IDLE.stop()
		gearPlayers[0].play()
	else:
		if currentGearStage > prevGearStage:
			# gearPlayers[currentGearStage - 2].stop()
			# gearPlayers[currentGearStage - 1].play() 
			for i in gearPlayers.size():
				if i == currentGearStage - 1:
					gearPlayers[i].play()
				else:
					gearPlayers[i].stop()
		elif currentGearStage < prevGearStage:
			# gearPlayers[currentGearStage].stop()
			# gearPlayers[currentGearStage - 1].play()
			for i in gearPlayers.size():
				if i == currentGearStage - 1:
					gearPlayers[i].play()
				else:
					gearPlayers[i].stop()


	prevGearStage = currentGearStage
	pass
