extends Node3D
class_name RaceInputHandler

signal forceStartRace()
signal pausePressed(playerIndex: int)

var playerPrefixes = []

func setup(nrPlayers: int):
	for i in range(nrPlayers):
		playerPrefixes.append("p" + str(i + 1) + "_")

func _input(event):
	if Input.is_action_just_pressed("p1_ready"):
		forceStartRace.emit()
	
	for playerPrefix in playerPrefixes:
		if Input.is_action_just_pressed(playerPrefix + "pause"):
			pausePressed.emit(int(playerPrefix[1]) - 1)