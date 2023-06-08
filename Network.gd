extends Node

var DEFAULT_PORT = 7777
var MAX_CLIENTS = 8

var server = null
var client = null

var ipAddress = ""

@export
var LAG_COMPENSATION: float = 0.9

func _ready() -> void:
	var osName = OS.get_name()

	if osName == "Windows":
		ipAddress = IP.get_local_addresses()[3]
	elif osName == "Andoird":
		ipAddress = IP.get_local_addresses()[0]
	else:
		ipAddress = IP.get_local_addresses()[3]

	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") && !ip.ends_with(".1"):
			ipAddress = ip
			break
	
	get_tree().get_multiplayer().connected_to_server.connect(connectedToServer)
	# get_tree().connect("disconnected_from_server", disconnectedFromServer)
	get_tree().get_multiplayer().server_disconnected.connect(disconnectedFromServer)


func createServer() -> void:
	server = ENetMultiplayerPeer.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().get_multiplayer().multiplayer_peer = server

func joinServer(_callback: Callable = func(): return) -> void:
	get_tree().get_multiplayer().connected_to_server.connect(_callback)
	client = ENetMultiplayerPeer.new()
	client.create_client(ipAddress, DEFAULT_PORT)
	get_tree().get_multiplayer().multiplayer_peer = client
	print("Joining server at " + ipAddress + ":" + str(DEFAULT_PORT))

func connectedToServer() -> void:
	print("Connected to server")

func disconnectedFromServer() -> void:
	print("Disconnected from server")

