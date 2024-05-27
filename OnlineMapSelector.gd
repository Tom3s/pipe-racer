extends Control
class_name OnlineMapSelector

@onready var tabContainer: TabContainer = %TabContainer
@onready var downloadedTracks: ItemList = %DownloadedTracks
@onready var onlineTracks: ItemList = %OnlineTracks
@onready var backButton: Button = %BackButton
@onready var selectButton: Button = %SelectButton
@onready var mainContent: Control = %MainContent
@onready var clientLabel: Label = %ClientLabel
@onready var ipAddress: Label = %IpAddress
@onready var showIpButton: Button = %ShowIpButton
@onready var copyIpButton: Button = %CopyIpButton

const TEXT_DOWNLOAD := "Download Track"
const TEXT_PLAY := "Play Track"

var downloadedTrackListItems: Array = []
var onlineTrackListItems: Array = []

signal trackSelected(trackName: String)
signal backPressed()
signal downloadFailed()

func _ready():

	mainContent.visible = Network.userId == 1
	clientLabel.visible = Network.userId != 1

	tabContainer.tab_changed.connect(onTabChanged)
	backButton.pressed.connect(onBackPressed)
	selectButton.pressed.connect(onSelectPressed)

	downloadedTracks.item_selected.connect(enableSelectButton)
	onlineTracks.item_selected.connect(enableSelectButton)
	downloadedTracks.item_activated.connect(playButton_pressed)
	onlineTracks.item_activated.connect(downloadButton_pressed)

	showIpButton.button_down.connect(showIpAddress)
	showIpButton.button_up.connect(hideIpAddress)
	copyIpButton.pressed.connect(copyIpAddress)

	# Network.ipAddressChanged.connect(setIpAddress)

	visibility_changed.connect(onVisibilityChanged)

	selectButton.disabled = true

	setupFolders()

	loadDownloadedTracks()


# func setIpAddress(newIp: String):
# 	print("New IP: ", newIp)
# 	ipAddress.text = newIp

func showIpAddress():
	ipAddress.text = Network.ipAddress

func hideIpAddress():
	ipAddress.text = "(hidden)"

func copyIpAddress():
	DisplayServer.clipboard_set(Network.ipAddress)

func enableSelectButton(_sink = null):
	selectButton.disabled = false

func setupFolders():
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("user://tracks"):
		dir.make_dir("user://tracks")
	if !dir.dir_exists("user://tracks/autosave"):
		dir.make_dir("user://tracks/autosave")
	if !dir.dir_exists("user://tracks/downloaded"):
		dir.make_dir("user://tracks/downloaded")
	if !dir.dir_exists("user://tracks/local"):
		dir.make_dir("user://tracks/local")

func onTabChanged(index: int):
	selectButton.disabled = true
	if index == 0:
		selectButton.text = TEXT_PLAY
		loadDownloadedTracks()
	elif index == 1:
		selectButton.text = TEXT_DOWNLOAD
		searchTracks()

func onBackPressed():
	visible = false
	backPressed.emit()

func onSelectPressed():
	# trackSelected.emit("placeholder")
	if selectButton.text == TEXT_DOWNLOAD:
		downloadButton_pressed()
	else:
		playButton_pressed()

func loadDownloadedTracks() -> void:
	if not visible:
		return
	downloadedTracks.clear()
	downloadedTrackListItems.clear()
	var path = "user://tracks/downloaded/"
	var directory = DirAccess.open(path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			var fileHandler = FileAccess.open(path + file_name, FileAccess.READ)
			var trackItem = JSON.parse_string(fileHandler.get_as_text())
			# downloadedTrackListItems.append(file_name.replace(path, ""))
			if trackItem.format == Map.CURRENT_FORMAT_VERSION:
				downloadedTracks.add_item(trackItem.trackName + " - by: " + trackItem.author)
			else:
				downloadedTracks.add_item(trackItem.metadata.trackName + " - by: " + trackItem.metadata.author)

			downloadedTrackListItems.append(file_name)
			file_name = directory.get_next()

func searchTracks() -> void:
	if not visible:
		return

	loadTrackListItems()

func loadTrackListItems():
	onlineTracks.clear()
	onlineTrackListItems.clear()

	if VersionCheck.offline:
		AlertManager.showAlert(self, "Error", "Cannot download tracks in offline mode", "Please connect to the internet and try again") 
		return

	onlineTracks.add_item("Loading Tracks...")
	var loadTracksRequest = HTTPRequest.new()
	add_child(loadTracksRequest)
	loadTracksRequest.timeout = 30
	loadTracksRequest.request_completed.connect(onLoadTracksRequest_completed)
	var httpError = loadTracksRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/tracks",
		[
			"Content-Type: application/json"
		],
		HTTPClient.METHOD_GET
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onLoadTracksRequest_completed(_result: int, responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if (responseCode != 200):
		showAlert("Error", "Failed to load tracks", body.get_string_from_utf8()) 
		return
	
	var response = JSON.parse_string(body.get_string_from_utf8())
	onlineTracks.clear()
	onlineTrackListItems.clear()
	for track in response:
		onlineTrackListItems.append(track)
		onlineTracks.add_item(track.name + " - by: " + track.author.username)
	
	showAlert("Success", "Tracks Loaded Successfully", "Found " + str(onlineTrackListItems.size()) + " tracks")

func showAlert(title: String, text: String, response: String):
	var alert = AcceptDialog.new()
	alert.title = title
	alert.dialog_text = text + "\n"
	alert.dialog_text += response
	alert.canceled.connect(alert.queue_free)
	add_child(alert)
	alert.popup_centered()

func downloadButton_pressed(_sink = null) -> void:
	var trackId: String = onlineTrackListItems[onlineTracks.get_selected_items()[0]]._id as String
	downloadTrack(trackId)

func playButton_pressed(_sink = null) -> void:
	var trackName = "user://tracks/downloaded/" 
	var pureFileName = downloadedTrackListItems[downloadedTracks.get_selected_items()[0]]
	trackName += pureFileName
	visible = false
	var trackId: String = pureFileName.split(".")[0]
	if Network.userId == 1:
		rpc("downloadAndPlay", trackId)
	trackSelected.emit(trackName)
	print("Selected track: ", trackName)

func getDownloadedTrackIds() -> Array[String]:
	var ids: Array[String] = []
	for track in downloadedTrackListItems:
		ids.append(track.split(".")[0])
	return ids

var downloadingTrack: bool = false
var lastDownloadedTrackId: String = ""
func downloadTrack(trackId: String):
	if VersionCheck.offline:
		AlertManager.showAlert(self, "Error", "Cannot download tracks in offline mode", "Please connect to the internet and try again") 
		return


	var alreadyDownloadedTracks = getDownloadedTrackIds()
	if trackId in alreadyDownloadedTracks:
		showAlert("Error", "Track Already Downloaded", "Check your downloaded tracks list at the top") 
		return

	selectButton.disabled = true
	var downloadRequest = HTTPRequest.new()
	add_child(downloadRequest)
	downloadRequest.timeout = 30
	downloadRequest.request_completed.connect(onDownloadRequest_completed)
	downloadingTrack = true
	lastDownloadedTrackId = trackId
	var httpError = downloadRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/tracks/download/" + trackId,
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN
		],
		HTTPClient.METHOD_GET
	)

	if httpError != OK:
		print("Error: " + error_string(httpError))

func onDownloadRequest_completed(_result: int, responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if (responseCode != 200):
		showAlert("Error", "Failed to download track", body.get_string_from_utf8()) 
		downloadingTrack = false
		lastDownloadedTrackId = ""
		return
	
	# var response = JSON.parse_string(body.get_string_from_utf8())
	var path = "user://tracks/downloaded/" + lastDownloadedTrackId + ".json"
	var fileHandler = FileAccess.open(path, FileAccess.WRITE)
	fileHandler.store_string(body.get_string_from_utf8())
	fileHandler.close()
	downloadingTrack = false
	lastDownloadedTrackId = ""

	selectButton.disabled = false

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json.format == Map.CURRENT_FORMAT_VERSION:
		showAlert("Success", "Track Downloaded Successfully", "Track Name: " + json.trackName)
	else:
		showAlert("Success", "Track Downloaded Successfully", "Track Name: " + json.metadata.trackName)
		

@rpc("authority", "call_remote", "reliable")
func downloadAndPlay(trackId: String):

	if VersionCheck.offline:
		AlertManager.showAlert(self, "Error", "Cannot download tracks in offline mode", "Please connect to the internet and try again") 
		return

	var alreadyDownloadedTracks = getDownloadedTrackIds()
	if trackId in alreadyDownloadedTracks:
		var path = "user://tracks/downloaded/" + trackId + ".json"
		visible = false
		trackSelected.emit(path)
		return

	var downloadRequest = HTTPRequest.new()
	add_child(downloadRequest)
	downloadRequest.timeout = 30
	downloadRequest.request_completed.connect(onDownloadAndPlayRequest_completed)
	downloadingTrack = true
	lastDownloadedTrackId = trackId
	var httpError = downloadRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/tracks/download/" + trackId,
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN
		],
		HTTPClient.METHOD_GET
	)

	if httpError != OK:
		print("Error: " + error_string(httpError))

func onDownloadAndPlayRequest_completed(_result: int, responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if (responseCode != 200):
		downloadingTrack = false
		lastDownloadedTrackId = ""
		downloadFailed.emit()
		visible = false
		return
	
	# var response = JSON.parse_string(body.get_string_from_utf8())
	var path = "user://tracks/downloaded/" + lastDownloadedTrackId + ".json"
	var fileHandler = FileAccess.open(path, FileAccess.WRITE)
	fileHandler.store_string(body.get_string_from_utf8())
	fileHandler.close()
	downloadingTrack = false
	lastDownloadedTrackId = ""

	visible = false
	trackSelected.emit(path)

func onVisibilityChanged():
	if visible:
		loadDownloadedTracks()
	
	mainContent.visible = Network.userId == 1
	clientLabel.visible = Network.userId != 1
