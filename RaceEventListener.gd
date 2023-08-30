extends Node3D
class_name RaceEventListener

var cars: Array[CarController]
var timeTrialManagers: Array[TimeTrialManager]
var huds: Array[IngameHUD]
var cameras: Array[FollowingCamera]

var countdown: Countdown
var raceInputHandler: RaceInputHandler

var paused = -1

func setup(initialCars: Array, initialTimeTrialManagers: Array, initialHuds: Array, initialCameras: Array):
	cars = initialCars
	timeTrialManagers = initialTimeTrialManagers
	huds = initialHuds
	cameras = initialCameras

	countdown = %UniversalCanvas/%Countdown
	raceInputHandler = %RaceInputHandler

	connectSignals()

func connectSignals():
	countdown.countdownFinished.connect(onCountdown_countdownFinished)
	raceInputHandler.forceStartRace.connect(onRaceInputHandler_forceStartRace)
	raceInputHandler.pausePressed.connect(onRaceInputHandler_pausePressed)

	for i in cars.size():
		cars[i].respawned.connect(onCar_respawned)

func onCountdown_countdownFinished(timestamp: int):
	for i in range(cars.size()):
		cars[i].startRace()
		timeTrialManagers[i].startTimeTrial(timestamp)
		huds[i].startTimer()

func onRaceInputHandler_forceStartRace():
	countdown.startCountdown()

func onRaceInputHandler_pausePressed(playerIndex: int):
	if paused == playerIndex:
		var timestamp = floor(Time.get_unix_time_from_system() * 1000)
		for i in range(cars.size()):
			cars[i].resumeMovement()
			timeTrialManagers[i].resumeTimeTrial(timestamp)
		paused = -1
	elif paused == -1:
		var timestamp = floor(Time.get_unix_time_from_system() * 1000)
		for i in range(cars.size()):
			cars[i].pauseMovement()
			timeTrialManagers[i].pauseTimeTrial(timestamp)
		paused = playerIndex

func onCar_respawned(playerIndex: int):
	cameras[playerIndex].forceUpdatePosition()
