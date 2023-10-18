extends Control
class_name OnlineMenu

@onready var username: LineEdit = %Username
@onready var ipAddress: LineEdit = %IpAddress
@onready var joinButton: Button = %JoinButton
@onready var hostButton: Button = %HostButton
@onready var backButton: Button = %BackButton
@onready var statusLabel: Label = %StatusLabel

var selectedTrack: String = "user://tracks/downloaded/650c73d0c3b8efa6383dde32.json"

signal connectionEstablished()
signal backPressed()

func _ready():
	username.text = GlobalProperties.PLAYER_NAME
	username.editable = false
	connectSignals()

func connectSignals():
	joinButton.pressed.connect(onJoinButton_pressed)
	hostButton.pressed.connect(onHostButton_pressed)
	backButton.pressed.connect(onBackButton_pressed)

	visibility_changed.connect(onVisibilityChanged)

	get_tree().get_multiplayer().connection_failed.connect(onConnectionFailed)

	Network.connectionClosed.connect(resetStatusText)
	# get_tree().get_multiplayer().connected_to_server.connect(changeToIngame)
	# get_tree().get_multiplayer().server_disconnected.connect(changeToOnlineMenu)


func onJoinButton_pressed():
	var client := ENetMultiplayerPeer.new()
	var clientResult = client.create_client(ipAddress.text, Network.DEFAULT_PORT)

	if clientResult != OK:
		print("[OnlineMenu.gd] Client creation failed")
		statusLabel.text = "STATUS: Client creation failed"
		AlertManager.showAlert(
			self,
			"Connection failed",
			"Could not connect to server"
		)
		return
	# TODO: this sets global client
	# I could get local client, and so hosting and connecting would be decoupled
	# I could get hosting and connecting on the same screen
	# this would unify the code, and not make duplicate code at server and client
	# see: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#initializing-the-network
	get_tree().get_multiplayer().multiplayer_peer = client

	joinButton.disabled = true
	hostButton.disabled = true

	statusLabel.text = "STATUS: Connecting to server - " + ipAddress.text
	Network.userId = get_tree().get_multiplayer().get_unique_id()

	# visible = false
	get_tree().get_multiplayer().connected_to_server.connect(hide)


func onHostButton_pressed():
	Network.hostServer(onServerCreated, self)
	statusLabel.text = "STATUS: Hosting server"
	# Network.username = username.text

	var id: int = get_tree().get_multiplayer().get_unique_id()

	Network.userId = id
	Network.playerDatas[str(id)] = Network.localData

func onBackButton_pressed():
	Network.closeConnection()
	visible = false
	backPressed.emit()

func onServerCreated():
	visible = false
	connectionEstablished.emit()

func onConnectionFailed():
	print("[OnlineMenu.gd] Connection failed")
	statusLabel.text = "STATUS: Connection failed"
	AlertManager.showAlert(
		self,
		"Connection failed",
		"Could not connect to server"
	)

	joinButton.disabled = false
	hostButton.disabled = false

func onVisibilityChanged():
	joinButton.disabled = false
	hostButton.disabled = false

func resetStatusText():
	statusLabel.text = "STATUS: waiting"

var gameScene := preload("res://GameScene.tscn")
var game: GameScene
# func changeToIngame():
# 	visible = false
# 	game = gameScene.instantiate()
# 	add_child(game)

# func changeToOnlineMenu():
# 	game.queue_free()
# 	visible = true
# 	joinButton.disabled = false
# 	hostButton.disabled = false

