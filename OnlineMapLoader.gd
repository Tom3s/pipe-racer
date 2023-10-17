extends Node
class_name OnlineMapLoader

var gameScene = preload("res://GameScene.tscn")

var raceNode: GameScene

@onready var mapLoader: OnlineMapSelector = %OnlineMapSelector
@onready var playerSelectorMenu: PlayerSelectorMenu = %PlayerSelectorMenu
@onready var onlineMenu: OnlineMenu = %OnlineMenu


var players: Array[PlayerData] = []

signal backPressed()

func _ready():
	playerSelectorMenu.visible = true
	mapLoader.visible = false
	onlineMenu.visible = false
	connectSignals()

func connectSignals():
	playerSelectorMenu.nextPressed.connect(onPlayerSelectorMenu_nextPressed)
	playerSelectorMenu.backPressed.connect(onPlayerSelectorMenu_backPressed)
	onlineMenu.connectionEstablished.connect(onOnlineMenu_connectionEstablished)
	onlineMenu.backPressed.connect(onOnlineMenu_backPressed)
	get_tree().get_multiplayer().connected_to_server.connect(onOnlineMenu_connectionEstablished)
	get_tree().get_multiplayer().server_disconnected.connect(onServerClosed)
	mapLoader.downloadFailed.connect(onMapLoader_DownloadFailed)
	mapLoader.backPressed.connect(onMapLoader_backPressed)
	mapLoader.trackSelected.connect(onMapLoader_trackSelected)

var readyPlayers: int = 0
func onPlayerSelectorMenu_nextPressed(selectedPlayers: Array[PlayerData]):
	players = selectedPlayers
	Network.localData = players
	onlineMenu.visible = true

func onPlayerSelectorMenu_backPressed():
	backPressed.emit()

func onOnlineMenu_connectionEstablished():
	mapLoader.visible = true
	readyPlayers = 0

func onOnlineMenu_backPressed():
	# Network.closeConnection()
	playerSelectorMenu.visible = true

func onServerClosed():
	Network.closeConnection()
	playerSelectorMenu.visible = true

func onMapLoader_backPressed():
	onlineMenu.visible = true
	Network.closeConnection()

func onMapLoader_DownloadFailed():
	Network.closeConnection()
	playerSelectorMenu.visible = true

func onMapLoader_trackSelected(trackName: String):

	raceNode = gameScene.instantiate()
	raceNode.name = trackName.split("/")[-1].split(".")[0]
	add_child(raceNode)
	raceNode.setup(trackName, true, true)
	raceNode.exitPressed.connect(onRace_exited)


	if Network.userId != 1:
		print("Waiting for client")
		await get_tree().create_timer(1.0).timeout
		while !raceNode.is_node_ready():
			print("Waiting for client")
			await get_tree().create_timer(1.0).timeout
		rpc_id(1, "increaseReadyPlayers")

func onRace_exited():
	raceNode.queue_free()
	mapLoader.visible = true
	readyPlayers = 0

@rpc("any_peer", "call_remote", "reliable")
func increaseReadyPlayers():
	readyPlayers += 1
	print("readyPlayers: ", readyPlayers, "/", Network.playerCount)
	if readyPlayers == Network.playerCount:
		raceNode.initializePlayers()

func show():
	playerSelectorMenu.visible = true

func hide():
	playerSelectorMenu.visible = false
	mapLoader.visible = false
	onlineMenu.visible = false