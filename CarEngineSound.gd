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

@export
var PITCH_FACTOR: float = 2

@export_range(0, 1, 0.05)
var PITCH_HARSHNESS: float = 0.33

@export
var GEAR_SHIFT_COOLDOWN_DEFAULT: float = 5

var GEAR_SHIFT_COOLDOWN: float = 0

var currentGearStage: int
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	currentGearStage = min(floor(targetPitchScale), 4)
	for gear in gearPlayers:
		gear.pitch_scale = ((targetPitchScale - int(targetPitchScale)) ** PITCH_FACTOR) * PITCH_HARSHNESS + 1

	if playingIdle:
		if !IDLE.playing:
			IDLE.play()
			for gear in gearPlayers:
				gear.stop()
	elif !playingIdle && IDLE.playing:
		IDLE.stop()
		gearPlayers[0].play()
	else:
		if currentGearStage > prevGearStage && GEAR_SHIFT_COOLDOWN <= 0:
			# gearPlayers[currentGearStage - 2].stop()
			# gearPlayers[currentGearStage - 1].play() 
			for i in gearPlayers.size():
				if i == currentGearStage - 1:
					gearPlayers[i].play()
				else:
					gearPlayers[i].stop()
			GEAR_SHIFT_COOLDOWN = GEAR_SHIFT_COOLDOWN_DEFAULT
		elif currentGearStage < prevGearStage && GEAR_SHIFT_COOLDOWN <= 0:
			# gearPlayers[currentGearStage].stop()
			# gearPlayers[currentGearStage - 1].play()
			for i in gearPlayers.size():
				if i == currentGearStage - 1:
					gearPlayers[i].play()
				else:
					gearPlayers[i].stop()
			GEAR_SHIFT_COOLDOWN = GEAR_SHIFT_COOLDOWN_DEFAULT


	GEAR_SHIFT_COOLDOWN -= delta

	prevGearStage = currentGearStage
