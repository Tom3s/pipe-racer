extends Node
class_name GameEventListener

# scenes
var Car := preload("res://CarController.tscn")
var HudScene := preload("res://HUD/HUD.tscn")

# data to care about
var playerDatas: Array[PlayerData] = []
var localPlayerDatas: Array[PlayerData] = []
var huds: Array[IngameHUD] = []
var timeTrialManagers = {}
var raceStats: Dictionary = {}
var localCameras: Dictionary = {}

# node in scene
var map: Map:
	set(newMap):
		map = newMap
		for checkpoint in map.getCheckpoints():
			checkpoint.bodyEnteredCheckpoint.connect(onCheckpoint_bodyEnteredCheckpoint)
		map.start.bodyEnteredStart.connect(onStart_bodyEnteredStart)
		leaderboardUI.setHeader(map.trackName, map.author)

@onready var players: Node3D = %Players
@onready var state: GameStateMachine = %GameStateMachine
@onready var verticalSplitTop: HBoxContainer = %VerticalSplitTop
@onready var verticalSplitBottom: HBoxContainer = %VerticalSplitBottom
@onready var countdown = %UniversalCanvas/%Countdown
@onready var raceInputHandler = %RaceInputHandler
@onready var leaderboardUI = %LeaderboardUI
@onready var ingameSFX = %IngameSFX
@onready var pauseMenu = %PauseMenu

func _ready():
	verticalSplitBottom.visible = false
	pauseMenu.visible = false
	leaderboardUI.visible = false
	connectSignals()

func connectSignals():
	countdown.countdownFinished.connect(onCountdown_countdownFinished)

	raceInputHandler.pausePressed.connect(onRaceInputHandler_pausePressed)
	raceInputHandler.fullScreenPressed.connect(onRaceInputHandler_fullScreenPressed)

	state.allPlayersReady.connect(onState_allPlayersReady)
	state.allPlayersFinished.connect(onState_allPlayersFinished)
	state.allPlayersReset.connect(recalculate)

	pauseMenu.resumePressed.connect(forceResumeGame)
	pauseMenu.restartPressed.connect(onPauseMenu_restartPressed)
	pauseMenu.exitPressed.connect(onPauseMenu_exitPressed)

	Network.userListNeedsUpdate.connect(onUserListNeedsUpdate)

# Singaled functions

func onCountdown_countdownFinished(timestamp: int):
	for player in players.get_children():
		player = player as CarController
		player.startRace()
	
	for hud in huds:
		hud.startTimer()
	
	for key in timeTrialManagers:
		timeTrialManagers[key].startTimeTrial(timestamp)

	state.raceStarted = true

func onRaceInputHandler_pausePressed(playerIndex: int):
	if state.online:
		if state.pausedBy == playerIndex:
			for player in players.get_children():
				player = player as CarController
				if player.networkId == Network.userId:
					player.state.hasControl = true
			state.pausedBy = -1
			pauseMenu.visible = false
		elif state.pauseBy == -1 && state.raceStarted:
			for player in players.get_children():
				player = player as CarController
				if player.networkId == Network.userId:
					player.state.hasControl = false
			state.pausedBy = playerIndex
			pauseMenu.visible = true
			leaderboardUI.visible = false
	else:
		if state.pausedBy == playerIndex:
			var timestamp = floor(getTimestamp())
			if state.raceStarted:
				for player in players.get_children():
					player = player as CarController
					player.resumeMovement()
					timeTrialManagers[player.name].resumeTimeTrial(timestamp)
					player.state.hasControl = true
			state.pausedBy = -1
			pauseMenu.visible = false
		elif state.pausedBy == -1 && state.raceStarted:
			var timestamp = floor(getTimestamp())
			for player in players.get_children():
				player = player as CarController
				player.pauseMovement()
				timeTrialManagers[player.name].pauseTimeTrial(timestamp)
				player.state.hasControl = false
			state.pausedBy = playerIndex
			pauseMenu.visible = true
			leaderboardUI.visible = false

func onRaceInputHandler_fullScreenPressed():
	GlobalProperties.FULLSCREEN = !GlobalProperties.FULLSCREEN

func onCar_respawned(playerIndex: int, networkId: int):
	# this in unneccessary i guess
	if networkId != Network.userId:
		return
	var playerIdentifer = players.get_child(playerIndex).name
	localCameras[playerIdentifer].forceUpdatePosition()

func onCar_isReady(playerIndex: int, networkId: int):
	rpc("broadcastReady", playerIndex, networkId)

@rpc("any_peer", "call_local", "reliable")
func broadcastReady(playerIndex: int, networkId: int):
	state.setPlayerReady(playerIndex)

func onCar_finishedRace(playerIndex: int, networkId: int):
	state.newPlayerFinished()
	var car: CarController = players.get_child(playerIndex)
	var playerIdentifier = car.name
	var bestLap = timeTrialManagers[playerIdentifier].getBestLap()
	var totalTime = timeTrialManagers[playerIdentifier].getTotalTime()


	if networkId == Network.userId:
		raceStats[playerIdentifier].increaseFinishes()
		raceStats[playerIdentifier].setBestLap(bestLap)
		raceStats[playerIdentifier].setBestTime(totalTime)

		var sessionToken = Network.localData[car.getLocalIndex()].SESSION_TOKEN

		if state.ranked:
			# submitTime(timeTrialManagers[playerIdentifier].splits, bestLap, totalTime, playerIndex)
			Leaderboard.submitTime(
				timeTrialManagers[playerIdentifier].splits,
				bestLap,
				totalTime,
				map.trackId,
				sessionToken, # FIX
				onSubmitRun_requestCompleted
			)
			# TODO: broadcast info to host/other players maybe
		print("Best Lap: ", bestLap)
		print("Total time: ", totalTime)

func onCar_isResetting(playerIndex: int, resetting: bool, networkId: int) -> void:
	rpc("broadcastReset", playerIndex, resetting, networkId)

@rpc("any_peer", "call_local", "reliable")
func broadcastReset(playerIndex: int, resetting: bool, networkId: int) -> void:
	if !state.raceStarted || state.pausedBy != -1:
		return
	state.setPlayerReset(playerIndex, resetting)
	if networkId == Network.userId:
		leaderboardUI.visible = false

func onCheckpoint_bodyEnteredCheckpoint(car: CarController, checkpoint: Checkpoint):
	print("Checkpoint ", checkpoint.index, " entered by ", car.playerName)

	var alreadyCollected = car.state.collectCheckpoint(checkpoint.index)

	if !alreadyCollected:
		if car.networkId == Network.userId:
			# var playerIndex = car.playerIndex
			timeTrialManagers[car.name].collectCheckpoint(getTimestamp(), car.state.currentLap)
			car.setRespawnPositionFromDictionary(checkpoint.getRespawnPosition(car.playerIndex, players.get_child_count()))
			checkpoint.collect()
		car.state.placement = checkpoint.getPlacement(car.state.currentLap)
		ingameSFX.playCheckpointSFX()

func onStart_bodyEnteredStart(car: CarController, start: Start):
	if car.state.hasCollectedAllCheckpoints():
		car.setRespawnPositionFromDictionary(start.getStartPosition(car.playerIndex, players.get_child_count()))
		if car.networkId == Network.userId:
			for checkpoint in map.getCheckpoints():
				checkpoint.setUncollected()
			timeTrialManagers[car.name].finishedLap()
		# await timeTrialManagers[car.playerIndex].addedTime
		car.state.finishLap()

func onState_allPlayersReady():
	countdown.startCountdown()
	# state.countdownStarted = true
	# state.countdownFinished	= false
	for key in raceStats:
		raceStats[key].increaseAttempts()

func onState_allPlayersFinished():
	print("All players finished")
	if state.ranked:
		leaderboardUI.fetchTimes(map.trackId)
		leaderboardUI.visible = true

func forceResumeGame():
	var timestamp = floor(getTimestamp())
	if state.raceStarted:
		for car in players.get_children():
			car.resumeMovement()
			car.state.hasControl = true
		# timeTrialManagers[i].resumeTimeTrial(timestamp)
		for key in timeTrialManagers:
			timeTrialManagers[key].resumeTimeTrial(timestamp)

	state.pausedBy = -1

func onPauseMenu_restartPressed():
	if state.online:
		for player in players.get_children():
			player = player as CarController
			if player.networkId == Network.userId:
				onCar_isResetting(player.playerIndex, true, Network.userId)
	else:
		recalculate()

func onPauseMenu_exitPressed():
	var musicPlayer = get_tree().root.get_node("MainMenu/MusicPlayer")
	if musicPlayer != null:
		musicPlayer.playMenuMusic()
	
	# TODO: submit times elsewhere, to avoid waiting for exit
	if state.ranked:
		for key in raceStats:
			var car := players.get_node(key)
			var sessionToken = Network.localData[car.getLocalIndex()].SESSION_TOKEN

			Leaderboard.submitRaceStats(
				raceStats[key].getObject(),
				sessionToken # FIX
			)
		
	get_parent().exitPressed.emit()

func onUserListNeedsUpdate(id: int) -> void:
	if id == -1 || Network.userId != 1:
		return
	
	for playerId in Network.playerDatas:
		if playerId.to_int() == id:
			for playerData in Network.playerDatas[playerId]:
				spawnPlayer(playerData, id) 


# helper functions

func getTimestamp():
	return floor(Time.get_unix_time_from_system() * 1000)

func addPlayers(_playerDatas: Array[PlayerData], networkId: int) -> void:
	for playerData in _playerDatas:
		spawnPlayer(playerData, networkId)

func spawnPlayer(
	data: PlayerData,
	networkId: int
) -> void:

	var car: CarController = Car.instantiate()

	car.name = str(networkId) + '_' + str(getTimestamp())
	# car.playerIndex = players.get_child_count()

	players.add_child(car)
	car.setup(
		data,
		# playerDatas.size(), # player's index
		# getInputDevices(networkId), # TODO: add local input devices
		map.getCheckpointCount(),
		map.lapCount
	)

	# car.respawned.connect(onCar_respawned)
	# car.isReady.connect(onCar_isReady)
	# car.finishedRace.connect(onCar_finishedRace)
	# car.isResetting.connect(onCar_isResetting)

	# timeTrialManagers.append(TimeTrialManager.new(%IngameSFX, map.lapCount))

	if networkId == Network.userId || Network.userId == -1:
		addLocalCamera(car, getInputDevices(networkId))
	else:
		# addRemoteCamera(car.name)
		rpc_id(networkId, "addRemoteCamera", car.name, getInputDevices(networkId))

	playerDatas.append(data)

	# recalculate()
	rpc("recalculate")

func getInputDevices(networkId: int) -> Array[int]:
	# var inputDevices: Array = []
	var localPlayerCount = 0
	for player in players.get_children():
		player = player as CarController
		if player.networkId == networkId:
			localPlayerCount += 1
	if localPlayerCount == 1:
		return [1, 2]
	return [localPlayerCount]
	
@rpc("authority", "call_remote", "reliable")
func addRemoteCamera(nodeName: String, inputDevices: Array):
	for player in players.get_children():
		if player.name == nodeName:
			addLocalCamera(player,inputDevices)
			return

func addLocalCamera(car: CarController, inputDevices: Array) -> void:
	var newCamerPosition: HBoxContainer = \
		verticalSplitTop \
		if verticalSplitTop.get_child_count() <= verticalSplitBottom.get_child_count() \
		else verticalSplitBottom
	
	if newCamerPosition == verticalSplitBottom:
		verticalSplitBottom.visible = true
	
	var camera := FollowingCamera.new(car)

	localCameras[car.name] = camera

	var viewPortContainer = getNewViewportContainer()
	var viewPort = getNewViewport()
	var canvasLayer = CanvasLayer.new()
	canvasLayer.follow_viewport_enabled = true

	var hud: IngameHUD = HudScene.instantiate()
	var timeTrialManager = TimeTrialManager.new(%IngameSFX, map.lapCount)
	timeTrialManagers[car.name] = timeTrialManager
	hud.init(car, timeTrialManager, playerDatas.size())

	huds.append(hud)

	canvasLayer.add_child(hud)

	viewPort.add_child(canvasLayer)
	viewPortContainer.add_child(viewPort)
	viewPort.add_child(camera)

	newCamerPosition.add_child(viewPortContainer)

	raceStats[car.name] = RaceStats.new(map.trackId)

	var typedArray: Array[int] 
	typedArray.assign(inputDevices)
	car.inputHandler.setInputPlayers(typedArray)

	car.respawned.connect(onCar_respawned)
	car.isReady.connect(onCar_isReady)
	car.finishedRace.connect(onCar_finishedRace)
	car.isResetting.connect(onCar_isResetting)

func getNewViewportContainer() -> SubViewportContainer:
	var viewPortContainer = SubViewportContainer.new()
	viewPortContainer.stretch = true
	viewPortContainer.size_flags_horizontal = SubViewportContainer.SIZE_EXPAND_FILL
	viewPortContainer.size_flags_vertical = SubViewportContainer.SIZE_EXPAND_FILL

	return viewPortContainer

func getNewViewport() -> SubViewport:
	var viewPort = SubViewport.new()
	viewPort.audio_listener_enable_3d = true
	viewPort.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	return viewPort


@rpc("authority", "call_local", "reliable")
func recalculate() -> void:
	# reset state
	var musicPlayer = get_tree().root.get_node("MainMenu/MusicPlayer")
	if musicPlayer != null:
		musicPlayer.playMenuMusic()

	var index = 0
	for car in players.get_children():
		car.resumeMovement()
		car.playerIndex = index
		index += 1
		car.reset(map.start.getStartPosition(car.playerIndex, players.get_child_count()), map.getCheckpointCount(), map.lapCount)
	
	for checkpoint in map.getCheckpoints():
		checkpoint.reset()
	
	for timeTrialManager in timeTrialManagers:
		timeTrialManagers[timeTrialManager].reset()
	
	for hud in huds:
		hud.reset(players.get_child_count())
	
	state.reset(players.get_child_count())

	raceInputHandler.setup(localCameras.size())
	# reset everything else
	# respawn players
	pass

func onSubmitRun_requestCompleted(_result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	print(body.get_string_from_utf8())
	leaderboardUI.fetchTimes(map.trackId)
	return