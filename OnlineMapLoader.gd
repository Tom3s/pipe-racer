extends Node
class_name OnlineMapLoader

var gameScene = preload("res://GameScene.tscn")

var raceNode: GameScene

@onready var mapLoader: OnlineMapSelector = %OnlineMapSelector
@onready var playerSelectorMenu: PlayerSelectorMenu #= %PlayerSelectorMenu
@onready var onlineMenu: OnlineMenu = %OnlineMenu


var players: Array[PlayerData] = []

signal backPressed()

func _ready():
	# playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
	# 	self,
	# 	onPlayerSelectorMenu_backPressed,
	# 	onPlayerSelectorMenu_nextPressed
	# )
	# playerSelectorMenu.visible = true
	mapLoader.visible = false
	onlineMenu.visible = false
	connectSignals()

func connectSignals():
	# playerSelectorMenu.backPressed.connect(onPlayerSelectorMenu_backPressed)
	# playerSelectorMenu.nextPressed.connect(onPlayerSelectorMenu_nextPressed)
	onlineMenu.connectionEstablished.connect(onOnlineMenu_connectionEstablished)
	onlineMenu.backPressed.connect(onOnlineMenu_backPressed)
	get_tree().get_multiplayer().connected_to_server.connect(onOnlineMenu_connectionEstablished)
	get_tree().get_multiplayer().server_disconnected.connect(onServerClosed)
	get_tree().get_multiplayer().connection_failed.connect(onServerClosed)
	get_tree().get_multiplayer().peer_connected.connect(broadcastCurrentMap)
	# get_tree().get_multiplayer().peer_disconnected.connect(increaseReadyPlayers)
	mapLoader.downloadFailed.connect(onMapLoader_DownloadFailed)
	mapLoader.backPressed.connect(onMapLoader_backPressed)
	mapLoader.trackSelected.connect(onMapLoader_trackSelected)

var readyPlayers: int = 0
func onPlayerSelectorMenu_nextPressed(selectedPlayers: Array[PlayerData]):
	players = selectedPlayers
	Network.localData = players
	onlineMenu.visible = true
	GlobalProperties.returnPlayerSelectorMenu(
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)

func onPlayerSelectorMenu_backPressed():
	GlobalProperties.returnPlayerSelectorMenu(
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	backPressed.emit()

func onOnlineMenu_connectionEstablished():
	mapLoader.visible = true
	readyPlayers = 0

func onOnlineMenu_backPressed():
	# Network.closeConnection()

	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	playerSelectorMenu.visible = true

func onServerClosed():
	Network.closeConnection()
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	playerSelectorMenu.visible = true
	onlineMenu.visible = false
	mapLoader.visible = false
	for child in %RaceParent.get_children():
		child.queue_free()

func broadcastCurrentMap(id: int):
	if selectedTrack != "":
		rpc_id(id, "raceOngoing", true)

@rpc("authority", "call_remote", "reliable")
func raceOngoing(ongoing: bool):
	# mapLoader.downloadAndPlay(trackName.split("/")[-1].split(".")[0])
	mapLoader.clientLabel.text = "Race Ongoing..." if ongoing else "Waiting for host..." 

func onMapLoader_backPressed():
	onlineMenu.visible = true
	Network.closeConnection()

func onMapLoader_DownloadFailed():
	Network.closeConnection()
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	playerSelectorMenu.visible = true

var selectedTrack: String
func onMapLoader_trackSelected(trackName: String):

	# raceNode = gameScene.instantiate()
	# raceNode.name = trackName.split("/")[-1].split(".")[0]
	# %RaceParent.add_child(raceNode)
	# raceNode.setup(trackName, true, true)
	# raceNode.exitPressed.connect(onRace_exited)

	selectedTrack = trackName
	initializeRace()
	
	# if Network.userId != 1:
	# 	print("Waiting for client")
		# await get_tree().create_timer(5.0).timeout
		# while !raceNode.is_node_ready():
		# 	print("Waiting for client")
		# 	await get_tree().create_timer(1.0).timeout

func onRace_exited():
	for child in %RaceParent.get_children():
		child.queue_free()
	mapLoader.visible = true
	readyPlayers = 0
	selectedTrack = ""
	if Network.userId == 1:
		rpc("raceOngoing", false)



@rpc("any_peer", "call_remote", "reliable")
func increaseReadyPlayers(_sink = null):
	readyPlayers += 1
	print("readyPlayers: ", readyPlayers, "/", Network.playerCount)
	if readyPlayers >= Network.playerCount:
		# initializeRace()
		raceNode.initializePlayers()

func initializeRace():
	raceNode = gameScene.instantiate()
	raceNode.name = selectedTrack.split("/")[-1].split(".")[0]
	%RaceParent.add_child(raceNode)
	if Network.userId != 1:
		raceNode.finishedLoading.connect(broadcastReady)
	raceNode.exitPressed.connect(onRace_exited)
	var success = raceNode.setup(selectedTrack, true, true)
	if !success:
		return

	if Network.playerCount == 0 && Network.userId == 1:
		raceNode.initializePlayers()

func broadcastReady():
	await get_tree().create_timer(3).timeout
	rpc_id(1, "increaseReadyPlayers")
	

func show():
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	
	playerSelectorMenu.visible = true

func hide():
	if playerSelectorMenu != null:
		playerSelectorMenu.visible = false
		GlobalProperties.returnPlayerSelectorMenu(
			onPlayerSelectorMenu_backPressed,
			onPlayerSelectorMenu_nextPressed
		)
	mapLoader.visible = false
	onlineMenu.visible = false
