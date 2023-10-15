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

# node in scene
var map: Map
@onready var players: Node3D = %Players
@onready var state: GameStateMachine = %GameStateMachine
@onready var verticalSplitTop: HBoxContainer = %VerticalSplitTop
@onready var verticalSplitBottom: HBoxContainer = %VerticalSplitBottom

func _ready():
	verticalSplitBottom.visible = false
	connectSignals()

func connectSignals():
	# get_tree().get_multiplayer().peer_connected.connect(onPeerConnected)
	Network.userListNeedsUpdate.connect(onUserListNeedsUpdate)

func onUserListNeedsUpdate(id: int) -> void:
	if id == -1 || Network.userId != 1:
		return
	
	for playerId in Network.playerDatas:
		if playerId.to_int() == id:
			for playerData in Network.playerDatas[playerId]:
				spawnPlayer(playerData, id) 



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
		getInputDevices(networkId), # TODO: add local input devices
		map.getCheckpointCount(),
		map.lapCount
	)

	# timeTrialManagers.append(TimeTrialManager.new(%IngameSFX, map.lapCount))

	if networkId == Network.userId || Network.userId == -1:
		addLocalCamera(car)
	else:
		# addRemoteCamera(car.name)
		rpc_id(networkId, "addRemoteCamera", car.name)

	playerDatas.append(data)

	# recalculate()
	rpc("recalculate")

func getInputDevices(networkId: int) -> Array[int]:
	# var inputDevices: Array[int] = []
	var localPlayerCount = 0
	for player in players.get_children():
		player = player as CarController
		if player.networkId == networkId:
			localPlayerCount += 1
	
	return [localPlayerCount]
	
@rpc("authority", "call_remote", "reliable")
func addRemoteCamera(nodeName: String):
	for player in players.get_children():
		if player.name == nodeName:
			addLocalCamera(player)
			return

func addLocalCamera(car: CarController) -> void:
	var newCamerPosition: HBoxContainer = \
		verticalSplitTop \
		if verticalSplitTop.get_child_count() <= verticalSplitBottom.get_child_count() \
		else verticalSplitBottom
	
	if newCamerPosition == verticalSplitBottom:
		verticalSplitBottom.visible = true
	
	var camera := FollowingCamera.new(car)
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
		car.reset(map.start.getStartPosition(car.playerIndex, players.get_child_count()), map.getCheckpointCount())
	
	for checkpoint in map.getCheckpoints():
		checkpoint.reset()
	
	for timeTrialManager in timeTrialManagers:
		timeTrialManagers[timeTrialManager].reset()
	
	for hud in huds:
		hud.reset()
	
	state.reset()
	# reset everything else
	# respawn players
	pass

