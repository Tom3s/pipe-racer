extends Control

@onready
var multiplayerConfigUI = %MultiplayerConfig

@onready
var serverIpAddress = get_node("%MultiplayerConfig/ServerIpAddress")

@onready
var deviceIpAddress = get_node("%DeviceIpAdress")

func _ready():
	# get_tree().connect("network_peer_connected", onPlayerConnected)
	get_tree().get_multiplayer().peer_connected.connect(onPlayerConnected)
	# get_tree().connect("network_peer_disconnected", onPlayerDisconnected)
	get_tree().get_multiplayer().peer_disconnected.connect(onPlayerDisconnected)
	# get_tree().connect("connected_to_server", onConnectedToServer)

	var createServerButton: Button = %MultiplayerConfig/CreateServer
	createServerButton.button_up.connect(onCreateServerButton_Pressed)

	var joinServerButton: Button = %MultiplayerConfig/JoinServer
	joinServerButton.button_up.connect(onJoinServerButton_Pressed)

	deviceIpAddress.text = Network.ipAddress

	%BackButton.button_up.connect(onBackButton_pressed)

func onPlayerConnected(id: int):
	# print("Player connected: " + str(id))

	var spawner = get_node(".").get_parent().get_node("%CarSpawner")
	spawner.spawnCar(id)
	# var timer = Timer.new()

	# timer.timeout.connect(func(): 
	# 	spawner.spawnCar(id)
	# 	print("Spawned car with Timer")
	# )
	# timer.one_shot = true
	# timer.start(1.0)

	# var delayedSpawnCar = func():
	# 	await get_tree().create_timer(1.0, true, true).timeout
	# 	get_node(".").get_parent().get_node("%CarSpawner").spawnCar(id)
	# 	print("Spawned car with async/await")
	
	# delayedSpawnCar.call()
		


func onPlayerDisconnected(id: int):
	# print("Player disconnected: " + str(id))

	get_node(".").get_parent().get_node("%CarSpawner").get_node(str(id)).queue_free()

func onCreateServerButton_Pressed():
	multiplayerConfigUI.hide()
	Network.createServer()
	get_node(".").get_parent().get_node("%CarSpawner").spawnCar(1)

func onJoinServerButton_Pressed():
	if serverIpAddress.text == "":
		print("Server IP address is empty")
		return
	
	multiplayerConfigUI.hide()
	Network.ipAddress = serverIpAddress.text
	# var peerId = get_tree().get_multiplayer().get_unique_id()
	var spawner = get_node(".").get_parent().get_node("%CarSpawner")
	
	Network.joinServer(func(): spawner.spawnCar(-1))

	
func onBackButton_pressed():
	get_parent().get_node("%MainMenu/%SelectMode").show()
	%MultiplayerConfig.hide()
