extends Node3D
class_name RaceInputHandler

signal forceStartRace()
signal fullScreenPressed()
signal pausePressed(playerIndex: int)
signal resetRacePressed()

var playerPrefixes = []

func setup(nrPlayers: int):
	for i in range(nrPlayers):
		playerPrefixes.append("p" + str(i + 1) + "_")

func _ready():
	set_physics_process(true)

# func _input(_event):
func _physics_process(_delta):
	if Input.is_action_just_pressed("p1_ready"):
		forceStartRace.emit()

	if Input.is_action_just_pressed("fullscreen"):
		fullScreenPressed.emit()

	if Input.is_action_just_pressed("reset_race"):
		resetRacePressed.emit()
	
	for playerPrefix in playerPrefixes:
		if Input.is_action_just_pressed(playerPrefix + "pause"):
			pausePressed.emit(int(playerPrefix[1]) - 1)