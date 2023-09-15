extends Node
class_name IngameSFX

@onready
var countdownSFX = %Countdown

@onready
var startRaceSFX = %StartRace

@onready
var finishLapSFX = %FinishLap

@onready
var checkpoint = %Checkpoint

func playCountdownSFX():
	countdownSFX.play()

func playStartRaceSFX():
	startRaceSFX.play()

func playFinishLapSFX():
	finishLapSFX.play(0.1)

func playCheckpointSFX():
	checkpoint.play()