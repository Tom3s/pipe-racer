extends Node
class_name RaceEventListener

var cars: Array[CarController]
var timeTrialManagers: Array[TimeTrialManager]
var huds: Array[IngameHUD]
var cameras: Array[FollowingCamera]
var raceStats: Array[RaceStats]
var map: Map
var players: Array[PlayerData]

var countdown: Countdown
var raceInputHandler: RaceInputHandler
var state: RaceStateMachine

var ingameSFX: IngameSFX

var paused = -1

@onready var pauseMenu: PauseMenu = %PauseMenu
@onready var leaderboardUI: LeaderboardUI = %LeaderboardUI

func getTimestamp():
	return floor(Time.get_unix_time_from_system() * 1000)

func setup(
		initialCars: Array, 
		initialTimeTrialManagers: Array, 
		initialHuds: Array, 
		initialCameras: Array, 
		initialStats: Array,
		initialMap: Map, 
		initialIngameSFX: IngameSFX, 
		initialPlayers: Array[PlayerData], 
		ranked: bool,
		online: bool
	):
	cars = initialCars
	timeTrialManagers = initialTimeTrialManagers
	huds = initialHuds
	cameras = initialCameras
	raceStats = initialStats
	map = initialMap
	ingameSFX = initialIngameSFX
	players = initialPlayers

	countdown = %UniversalCanvas/%Countdown
	raceInputHandler = %RaceInputHandler
	state = %RaceStateMachine

	pauseMenu.visible = false
	leaderboardUI.visible = false
	leaderboardUI.setHeader(map.trackName, map.author)

	state.nrPlayers = cars.size()
	state.setupReadyPlayersList()
	state.setupResettingPlayersList()
	state.ranked = ranked
	state.online = online

	connectSignals()

func connectSignals():
	countdown.countdownFinished.connect(onCountdown_countdownFinished)
	raceInputHandler.forceStartRace.connect(onRaceInputHandler_forceStartRace)
	raceInputHandler.pausePressed.connect(onRaceInputHandler_pausePressed)
	raceInputHandler.fullScreenPressed.connect(onRaceInputHandler_fullScreenPressed)
	# raceInputHandler.resetRacePressed.connect(onRaceInputHandler_resetRacePressed)

	for i in cars.size():
		cars[i].respawned.connect(onCar_respawned)
		cars[i].isReady.connect(onCar_isReady)
		cars[i].finishedRace.connect(onCar_finishedRace)
		cars[i].isResetting.connect(onCar_isResetting)
	
	for checkpoint in map.getCheckpoints():
		checkpoint.bodyEnteredCheckpoint.connect(onCheckpoint_bodyEnteredCheckpoint)
	map.start.bodyEnteredStart.connect(onStart_bodyEnteredStart)

	state.allPlayersReady.connect(onState_allPlayersReady)
	state.allPlayersFinished.connect(onState_allPlayersFinished)
	state.allPlayersReset.connect(onState_allPlayersReset)

	pauseMenu.resumePressed.connect(forceResumeGame)
	pauseMenu.restartPressed.connect(onState_allPlayersReset)
	pauseMenu.exitPressed.connect(onPauseMenu_exitPressed)

	# get_tree().get_multiplayer().peer_connected.connect(onPeer_connected)

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
	# state.countdownStarted = true
	# state.countdownFinished	= false
	for stats in raceStats:
		stats.increaseAttempts()

func onRaceInputHandler_pausePressed(playerIndex: int):
	if state.pausedBy == playerIndex:
		var timestamp = floor(getTimestamp())
		if state.raceStarted:
			for i in range(cars.size()):
				cars[i].resumeMovement()
				timeTrialManagers[i].resumeTimeTrial(timestamp)
				cars[i].state.hasControl = true
		state.pausedBy = -1
		pauseMenu.visible = false
	elif state.pausedBy == -1 && state.raceStarted:
		var timestamp = floor(getTimestamp())
		for i in range(cars.size()):
			cars[i].pauseMovement()
			timeTrialManagers[i].pauseTimeTrial(timestamp)
			cars[i].state.hasControl = false
		state.pausedBy = playerIndex
		pauseMenu.visible = true
		leaderboardUI.visible = false

func forceResumeGame():
	var timestamp = floor(getTimestamp())
	if state.raceStarted:
		for i in range(cars.size()):
			cars[i].resumeMovement()
			timeTrialManagers[i].resumeTimeTrial(timestamp)
			cars[i].state.hasControl = true
	state.pausedBy = -1

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
		car.setRespawnPositionFromDictionary(start.getStartPosition(car.playerIndex, cars.size()))
		for checkpoint in map.getCheckpoints():
			checkpoint.setUncollected()
		timeTrialManagers[car.playerIndex].finishedLap()
		# await timeTrialManagers[car.playerIndex].addedTime
		car.state.finishLap()
		# state.finishedPlayers += 1

func onState_allPlayersFinished():
	print("All players finished")
	if state.ranked:
		leaderboardUI.fetchTimes(map.trackId)
		leaderboardUI.visible = true

func onCar_isReady(playerIndex: int):
	state.setPlayerReady(playerIndex)

func onCar_finishedRace(playerIndex: int):
	state.newPlayerFinished()
	raceStats[playerIndex].increaseFinishes()

	var bestLap = timeTrialManagers[playerIndex].getBestLap()
	var totalTime = timeTrialManagers[playerIndex].getTotalTime()

	raceStats[playerIndex].setBestLap(bestLap)
	raceStats[playerIndex].setBestTime(totalTime)

	if state.ranked:
		submitTime(timeTrialManagers[playerIndex].splits, bestLap, totalTime, playerIndex)
	print("Player ", cars[playerIndex], " finished")
	print("Best Lap: ", bestLap)
	print("Total time: ", totalTime)

func onRaceInputHandler_fullScreenPressed():
	GlobalProperties.FULLSCREEN = !GlobalProperties.FULLSCREEN

func onState_allPlayersReset():
	# reset cars
	# reset checkpoints
	# reset time trial managers
	# reset huds (may not be necessary)
	# reset state machine

	var musicPlayer = get_tree().root.get_node("MainMenu/MusicPlayer")
	if musicPlayer != null:
		musicPlayer.playMenuMusic()

	for car in cars:
		car.resumeMovement()
		car.reset(map.start.getStartPosition(car.playerIndex, cars.size()), map.getCheckpointCount())
	
	for checkpoint in map.getCheckpoints():
		checkpoint.reset()
	
	for timeTrialManager in timeTrialManagers:
		timeTrialManager.reset()
	
	for hud in huds:
		hud.reset()
	
	state.reset()

func onCar_isResetting(playerIndex: int, resetting: bool) -> void:
	if !state.raceStarted || state.pausedBy != -1:
		return
	state.setPlayerReset(playerIndex, resetting)
	leaderboardUI.visible = false

func onPauseMenu_exitPressed():
	var musicPlayer = get_tree().root.get_node("MainMenu/MusicPlayer")
	if musicPlayer != null:
		musicPlayer.playMenuMusic()
	if state.ranked:
		var callbackSignals: Array[Signal] = []
		for i in raceStats.size():
			callbackSignals.append(submitRaceStats(raceStats[i].getObject(), i))
		
		for callback in callbackSignals:
			await callback
		
	get_parent().exitPressed.emit()

# func onPeer_connected(id: int) -> void:
# 	# cars
# 	# players
# 	var carScene = preload("res://CarController.tscn")
# 	var peerCar: CarController = carScene.instantiate()
# 	%Players.add_child(peerCar)

# 	var peerPlayerData = PlayerData.new(\
# 		id, \
# 		Network.playerNames[id], \
# 		Network.playerColors[id]\
# 	)

# 	state.nrPlayers += 1
# 	state.setupReadyPlayersList()
# 	state.setupResettingPlayersList()


# 	var spawnPoint = map.start.getStartPosition(cars.size(), state.nrPlayers)

# 	peerCar.setup(peerPlayerData, cars.size(), [1], spawnPoint, map.getCheckpointCount(), map.lapCount)
# 	cars.append(peerCar)



func submitTime(splits: Array, bestLap: int, totalTime: int, playerIndex: int) -> void:
	if map.trackId == "":
		print("Can't submit record on a non-downloaded track")
		return
	var submitData = {
		"track": map.trackId,
		"splits": splits,
		"time": totalTime,
		"bestLap": bestLap,
	}

	print(JSON.stringify(submitData, "\t"))

	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 10
	request.request_completed.connect(onSubmitRun_requestCompleted)

	
	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/leaderboard",
		[
			"Content-Type: application/json",
			"Session-Token: " + players[playerIndex].SESSION_TOKEN,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(submitData)
	)
	if httpError != OK:
		print("Error submitting time: " + error_string(httpError))


func onSubmitRun_requestCompleted(_result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	print(body.get_string_from_utf8())
	leaderboardUI.fetchTimes(map.trackId)
	return

func submitRaceStats(stats: Dictionary, playerIndex: int) -> Signal:
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 5
	request.request_completed.connect(onSubmitRaceStats_requestCompleted)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/stats/track",
		[
			"Content-Type: application/json",
			"Session-Token: " + players[playerIndex].SESSION_TOKEN,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(stats)
	)
	if httpError != OK:
		print("Error submitting time: " + error_string(httpError))
	
	return request.request_completed

func onSubmitRaceStats_requestCompleted(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	print("Race stat Submit Response: ", _responseCode)
	return
