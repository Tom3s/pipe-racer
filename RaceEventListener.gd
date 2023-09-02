extends Node
class_name RaceEventListener

var cars: Array[CarController]
var timeTrialManagers: Array[TimeTrialManager]
var huds: Array[IngameHUD]
var cameras: Array[FollowingCamera]
var map: Map

var countdown: Countdown
var raceInputHandler: RaceInputHandler
var state: RaceStateMachine

var ingameSFX: IngameSFX

var paused = -1

func getTimestamp():
	return floor(Time.get_unix_time_from_system() * 1000)

func setup(initialCars: Array, initialTimeTrialManagers: Array, initialHuds: Array, initialCameras: Array, initialMap: Map, initialIngameSFX: IngameSFX):
	cars = initialCars
	timeTrialManagers = initialTimeTrialManagers
	huds = initialHuds
	cameras = initialCameras
	map = initialMap
	ingameSFX = initialIngameSFX

	countdown = %UniversalCanvas/%Countdown
	raceInputHandler = %RaceInputHandler
	state = %RaceStateMachine

	state.nrPlayers = cars.size()
	state.setupReadyPlayersList()

	connectSignals()

func connectSignals():
	countdown.countdownFinished.connect(onCountdown_countdownFinished)
	raceInputHandler.forceStartRace.connect(onRaceInputHandler_forceStartRace)
	raceInputHandler.pausePressed.connect(onRaceInputHandler_pausePressed)
	raceInputHandler.fullScreenPressed.connect(onRaceInputHandler_fullScreenPressed)

	for i in cars.size():
		cars[i].respawned.connect(onCar_respawned)
		cars[i].isReady.connect(onCar_isReady)
		cars[i].finishedRace.connect(onCar_finishedRace)
	
	for checkpoint in map.getCheckpoints():
		checkpoint.bodyEnteredCheckpoint.connect(onCheckpoint_bodyEnteredCheckpoint)
	map.start.bodyEnteredStart.connect(onStart_bodyEnteredStart)

	state.allPlayersReady.connect(onState_allPlayersReady)
	state.allPlayersFinished.connect(onState_allPlayersFinished)

func onCountdown_countdownFinished(timestamp: int):
	for i in range(cars.size()):
		cars[i].startRace()
		timeTrialManagers[i].startTimeTrial(timestamp)
		huds[i].startTimer()
		state.raceStarted = true

func onRaceInputHandler_forceStartRace():
	# countdown.startCountdown()
	pass

func onState_allPlayersReady():
	countdown.startCountdown()

func onRaceInputHandler_pausePressed(playerIndex: int):
	if state.pausedBy == playerIndex:
		var timestamp = floor(getTimestamp())
		for i in range(cars.size()):
			cars[i].resumeMovement()
			timeTrialManagers[i].resumeTimeTrial(timestamp)
		state.pausedBy = -1
	elif state.pausedBy == -1 && !state.raceStarted:
		var timestamp = floor(getTimestamp())
		for i in range(cars.size()):
			cars[i].pauseMovement()
			timeTrialManagers[i].pauseTimeTrial(timestamp)
		state.pausedBy = playerIndex

func onCar_respawned(playerIndex: int):
	cameras[playerIndex].forceUpdatePosition()

func onCheckpoint_bodyEnteredCheckpoint(car: CarController, checkpoint: Checkpoint):
	print("Checkpoint ", checkpoint.index, " entered by ", car.playerName)

	var alreadyCollected = car.state.collectCheckpoint(checkpoint.index)

	if !alreadyCollected:
		var playerIndex = car.playerIndex
		timeTrialManagers[playerIndex].collectCheckpoint(getTimestamp(), car.state.currentLap)
		car.setRespawnPositionFromDictionary(checkpoint.getRespawnPosition(playerIndex, cars.size()))
		checkpoint.collect()
		car.state.placement = checkpoint.getPlacement(car.state.currentLap)
		ingameSFX.playCheckpointSFX()

func onStart_bodyEnteredStart(car: CarController, start: Start):
	if car.state.hasCollectedAllCheckpoints():
		car.state.finishLap()
		car.setRespawnPositionFromDictionary(start.getStartPosition(car.playerIndex, cars.size()))
		for checkpoint in map.getCheckpoints():
			checkpoint.setUncollected()
		timeTrialManagers[car.playerIndex].finishedLap()
		state.finishedPlayers += 1

func onState_allPlayersFinished():
	print("All players finished")

func onCar_isReady(playerIndex: int):
	state.setPlayerReady(playerIndex)

func onCar_finishedRace(playerIndex: int):
	state.newPlayerFinished()
	print("Player ", cars[playerIndex], " finished")
	print("Best Lap: ", timeTrialManagers[playerIndex].getBestLap())
	print("Total time: ", timeTrialManagers[playerIndex].getTotalTime())

func onRaceInputHandler_fullScreenPressed():
	var nextWindowMode = DisplayServer.window_get_mode()
	if nextWindowMode == DisplayServer.WINDOW_MODE_WINDOWED:
		nextWindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN
	else:
		nextWindowMode = DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(nextWindowMode)
