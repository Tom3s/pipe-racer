extends Node

const DEFAULT_PORT = 23456
const MAX_PLAYERS = 8

const LAG_COMPENSATION: float = 0.9

signal userListNeedsUpdate(id: int)

var userColor: String = "Red"
var userId: int = 1

var playerDatas: Dictionary = {}
# var playerColors: Dictionary = {}

var portsMapped = false

var localData: Array[PlayerData] = []

var ipAddress: String = ""

signal ipAddressChanged(ip: String)

func _ready():
	get_tree().get_multiplayer().connected_to_server.connect(onConnectedToServer)
	get_tree().get_multiplayer().server_disconnected.connect(onServerDisconnected)

	ipAddress = "localhost"

func onConnectedToServer():
	print("[Network.gd] Connected to server")
	var id = get_tree().get_multiplayer().get_unique_id()
	var jsonData = []
	for data in localData:
		jsonData.append(data.toJson(true))
	var clientData = [str(id), JSON.stringify(jsonData)]
	rpc_id(1, "setUserData", clientData)
	# changeToIngameScene()

@rpc("any_peer", "call_local", "unreliable")
func setUserData(jsonData):
	# var parsedData = JSON.parse_string(jsonData)
	var id = str(jsonData[0])
	var playerDataList = JSON.parse_string(jsonData[1])
	var decodedData: Array[PlayerData] = []
	for json in playerDataList:
		decodedData.append(PlayerData.fromJson(json))
	playerDatas[id] = decodedData
	userListNeedsUpdate.emit(id.to_int())

	var updatedJsonList = {}
	for playerData in playerDatas:
		# if playerData == str(userId):
		# 	updatedJsonList[playerData] = localData
		# 	continue
		var jsonList = []
		for singleData in playerDatas[playerData]:
			jsonList.append(singleData.toJson(true))
		updatedJsonList[playerData] = jsonList
	rpc("updateUserList", updatedJsonList)

var playerCount = 0
@rpc("any_peer", "call_local", "unreliable")
func updateUserList(updatedUserList):
	# playerDatas = updatedUserList
	# var jsonList = JSON.parse_string(updatedUserList)
	var newUserList = {}
	for playerData in updatedUserList:
		if playerData == str(userId):
			newUserList[playerData] = localData
			continue
		var decodedData: Array[PlayerData] = []
		for singleData in updatedUserList[playerData]:
			decodedData.append(PlayerData.fromJson(singleData))
		newUserList[playerData] = decodedData
	playerDatas = newUserList

	playerCount = get_tree().get_multiplayer().get_peers().size()
	userListNeedsUpdate.emit(-1)

func onServerDisconnected():
	print("[Network.gd] Server closed connection")
	OS.alert("Server closed connection", "Error")
	userId = 1
	# changeToOnlineMenu() 

func hostServer(callback: Callable):
	var upnp = UPNP.new()
	var discoverResult = upnp.discover()

	if discoverResult == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() && upnp.get_gateway().is_valid_gateway():
			var mappingResultUDP = upnp.add_port_mapping(DEFAULT_PORT, DEFAULT_PORT, "Pipe_racer", "UDP")
			var mappingResultTCP = upnp.add_port_mapping(DEFAULT_PORT, DEFAULT_PORT, "Pipe_racer", "TCP")

			if mappingResultUDP != UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(DEFAULT_PORT, DEFAULT_PORT, "", "UDP")
			if mappingResultTCP != UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(DEFAULT_PORT, DEFAULT_PORT, "", "TCP")
			portsMapped = true

			ipAddress = upnp.query_external_address()
			ipAddressChanged.emit(ipAddress)
		else:
			print("No valid gateway found for forwarding. Try manually forwarding port ", DEFAULT_PORT)
			# return
	else:
		print(error_string(discoverResult), ": Could not forward port")
		# return
	


	var server = ENetMultiplayerPeer.new()
	server.create_server(DEFAULT_PORT, MAX_PLAYERS)

	get_tree().get_multiplayer().multiplayer_peer = server

	userId = get_tree().get_multiplayer().get_unique_id()

	callback.call()

func closeConnection():
	get_tree().get_multiplayer().multiplayer_peer = null
	userId = 1
	playerDatas.clear()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		deletePortMappings()

func deletePortMappings() -> void:
	if portsMapped:
		var upnp = UPNP.new()
		var _discoverResult = upnp.discover()

		upnp.delete_port_mapping(DEFAULT_PORT, "UDP")
		upnp.delete_port_mapping(DEFAULT_PORT, "TCP")

		portsMapped = false
