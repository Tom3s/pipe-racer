extends Control
class_name OnlineMenu

@onready var username: LineEdit = %Username
@onready var ipAddress: LineEdit = %IpAddress
@onready var joinButton: Button = %JoinButton
@onready var hostButton: Button = %HostButton
@onready var statusLabel: Label = %StatusLabel

var selectedTrack: String = "user://tracks/downloaded/650c73d0c3b8efa6383dde32.json"

func _ready():
	username.text = GlobalProperties.PLAYER_NAME
	username.editable = false
	connectSignals()

func connectSignals():
	joinButton.pressed.connect(onJoinButton_pressed)
	hostButton.pressed.connect(onHostButton_pressed)

	get_tree().get_multiplayer().connection_failed.connect(onConnectionFailed)
	get_tree().get_multiplayer().connected_to_server.connect(changeToIngame)
	get_tree().get_multiplayer().server_disconnected.connect(changeToOnlineMenu)


func onJoinButton_pressed():
	var playerdata = PlayerData.new(
		69,
		"Client",
		GlobalProperties.PLAYER_COLOR,
		"client_token"
	)

	Network.localData = [playerdata, playerdata]

	var client := ENetMultiplayerPeer.new()
	client.create_client(ipAddress.text, Network.DEFAULT_PORT)
	# TODO: this sets global client
	# I could get local client, and so hosting and connecting would be decoupled
	# I could get hosting and connecting on the same screen
	# this would unify the code, and not make duplicate code at server and client
	# see: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#initializing-the-network
	get_tree().get_multiplayer().multiplayer_peer = client

	joinButton.disabled = true
	hostButton.disabled = true

	statusLabel.text = "STATUS: Connecting to server - " + ipAddress.text
	# Network.username = username.text
	Network.userId = get_tree().get_multiplayer().get_unique_id()


func onHostButton_pressed():
	var playerdata = PlayerData.new(
		12,
		"Host",
		GlobalProperties.PLAYER_COLOR,
		"host_token"
	)

	Network.localData = [playerdata]

	Network.hostServer(Callable(self, "changeToIngame"))
	statusLabel.text = "STATUS: Hosting server"
	# Network.username = username.text

	var id: int = get_tree().get_multiplayer().get_unique_id()

	Network.userId = id
	Network.playerDatas[str(id)] = Network.localData
	# Network.playerNames[str(id)] = GlobalProperties.PLAYER_NAME
	# Network.playerColors[str(id)] = GlobalProperties.PLAYER_COLOR

func onConnectionFailed():
	print("[OnlineMenu.gd] Connection failed")
	statusLabel.text = "STATUS: Connection failed"

	joinButton.disabled = false
	hostButton.disabled = false

var gameScene := preload("res://GameScene.tscn")
var game: GameScene
func changeToIngame():
	%OnlineMenu.visible = false
	game = gameScene.instantiate()
	add_child(game)

func changeToOnlineMenu():
	game.queue_free()
	%OnlineMenu.visible = true
	joinButton.disabled = false
	hostButton.disabled = false
