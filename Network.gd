extends Node

var DEFAULT_PORT = 7890
var MAX_CLIENTS = 8

var server = null
var client = null

var ipAddress = ""

var portsMapped = false

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
	var upnp = UPNP.new()
	var discoverResult = upnp.discover()

	if discoverResult ==  UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var mappingResultUDP = upnp.add_port_mapping(DEFAULT_PORT, 0, "Pipe_racer", "UDP")
			var mappingResultTCP = upnp.add_port_mapping(DEFAULT_PORT, 0, "Pipe_racer", "TCP")

			if mappingResultUDP != UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(DEFAULT_PORT, 0, "", "UDP")
			if mappingResultTCP != UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(DEFAULT_PORT, 0, "", "TCP")
			portsMapped = true
			

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

func deletePortMappings() -> void:
	if portsMapped:
		var upnp = UPNP.new()
		var _discoverResult = upnp.discover()

		upnp.delete_port_mapping(DEFAULT_PORT, "UDP")
		upnp.delete_port_mapping(DEFAULT_PORT, "TCP")

		portsMapped = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		deletePortMappings()