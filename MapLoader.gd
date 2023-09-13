extends Control
class_name MapLoader

@onready var localTrackList: ItemList = %LocalTrackList
@onready var downloadedTrackList: ItemList = %DownloadedTrackList
@onready var onlineTrackList: ItemList = %OnlineTrackList

@onready var localButton: Button = %LocalButton
@onready var downloadedButton: Button = %DownloadedButton
@onready var findButton: Button = %FindButton

@onready var backButton: Button = %BackButton
@onready var loadButton: Button = %LoadButton
@onready var uploadButton: Button = %UploadButton
@onready var downloadButton: Button = %DownloadButton
@onready var newButton: Button = %NewButton

var localTrackListItems: Array = []
var downloadedTrackListItems: Array = []
var onlineTrackListItems: Array = []

var editorSelect: bool = false



const MODE_SELECT_LOCAL = 0
const MODE_SELECT_DOWNLOADED = 1
const MODE_SELECT_SEARCH = 2

var selectMode: int = MODE_SELECT_LOCAL

signal trackSelected(trackName: String)
signal backPressed()
# Called when the node enters the scene tree for the first time.
func _ready():
	backButton.pressed.connect(onBackButton_pressed)
	loadButton.pressed.connect(onLoadButton_pressed)
	uploadButton.pressed.connect(onUploadButton_pressed)
	downloadButton.pressed.connect(onDownloadButton_pressed)
	newButton.pressed.connect(onNewButton_pressed)

	localButton.pressed.connect(onLocalButton_pressed)
	downloadedButton.pressed.connect(onDownloadedButton_pressed)
	findButton.pressed.connect(onFindButton_pressed)

	localTrackList.item_selected.connect(onLocalTrackList_itemSelected)
	downloadedTrackList.item_selected.connect(onDownloadedTrackList_itemSelected)
	onlineTrackList.item_selected.connect(onOnlineTrackList_itemSelected)

	visibility_changed.connect(loadLocalTracks)

	loadButton.disabled = true
	uploadButton.disabled = true

	setListVisibility(MODE_SELECT_LOCAL)
	setButtonVisibility(MODE_SELECT_LOCAL)


	setEditorSelect(false)

	loadLocalTracks()


func loadLocalTracks() -> void:
	if not visible:
		return
	localTrackList.clear()
	localTrackListItems.clear()
	var path = "user://tracks/local/"
	var directory = DirAccess.open(path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			localTrackListItems.append(file_name.replace(path, ""))
			file_name = directory.get_next()
	
	for track in localTrackListItems:
		localTrackList.add_item(track.replace(".json", ""))
	
	# if localTrackListItems.size() > 0:
	# 	loadButton.disabled = false

func loadDownloadedTracks() -> void:
	if not visible:
		return
	downloadedTrackList.clear()
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
			downloadedTrackList.add_item(trackItem.trackName + " - by: " + trackItem.author)
			downloadedTrackListItems.append(file_name)
			file_name = directory.get_next()
	
	# for track in downloadedTrackListItems:
	# 	downloadedTrackList.add_item(track.replace(".json", ""))

func searchTracks() -> void:
	if not visible:
		return

	loadTrackListItems()


func onLocalTrackList_itemSelected(index: int) -> void:
	setLoadUploadButtonEnabled()

func onDownloadedTrackList_itemSelected(index: int) -> void:
	setLoadUploadButtonEnabled()

func onOnlineTrackList_itemSelected(index: int) -> void:
	downloadButton.disabled = onlineTrackList.get_selected_items().size() <= 0 && !downloadingTrack



func onLoadButton_pressed() -> void:
	var trackName = ""
	if selectMode == MODE_SELECT_LOCAL:
		trackName = "user://tracks/local/" 
		trackName += localTrackListItems[localTrackList.get_selected_items()[0]]
	elif selectMode == MODE_SELECT_DOWNLOADED:
		trackName = "user://tracks/downloaded/" 
		trackName += downloadedTrackListItems[downloadedTrackList.get_selected_items()[0]]
	else:
		return
	visible = false
	trackSelected.emit(trackName)
	print("Selected track: ", trackName)

func onUploadButton_pressed() -> void:
	var trackName = localTrackListItems[localTrackList.get_selected_items()[0]]
	uploadTrack(trackName)

func onDownloadButton_pressed() -> void:
	var trackId = onlineTrackListItems[onlineTrackList.get_selected_items()[0]]._id
	downloadTrack(trackId)

func onBackButton_pressed() -> void:
	visible = false
	backPressed.emit()

func onNewButton_pressed() -> void:
	visible = false
	trackSelected.emit("")

func onLocalButton_pressed():
	setSelectMode(MODE_SELECT_LOCAL)
	enableAllButtons()
	loadButton.disabled = true
	loadLocalTracks()

func onDownloadedButton_pressed():
	setSelectMode(MODE_SELECT_DOWNLOADED)
	enableAllButtons()
	loadButton.disabled = true
	loadDownloadedTracks()

func onFindButton_pressed():
	setSelectMode(MODE_SELECT_SEARCH)
	enableAllButtons()
	searchTracks()





# func showNewButton(value: bool):
# 	newButton.visible = value
func setEditorSelect(value: bool):
	editorSelect = value
	if editorSelect:
		newButton.visible = true
		uploadButton.visible = true
		loadButton.text = "Edit"
		hideTabButtons()
	else:
		newButton.visible = false
		uploadButton.visible = false
		loadButton.text = "Load Track"

func hideTabButtons():
	localButton.visible = false
	downloadedButton.visible = false
	findButton.visible = false

func disableAllButtons():
	backButton.disabled = true
	loadButton.disabled = true
	uploadButton.disabled = true
	newButton.disabled = true

func enableAllButtons():
	uploadButton.disabled = false
	newButton.disabled = false
	setLoadUploadButtonEnabled()

func setLoadUploadButtonEnabled():
	# loadButton.disabled = localTrackList.get_selected_items().size() <= 0
	if selectMode == MODE_SELECT_LOCAL:
		loadButton.disabled = localTrackList.get_selected_items().size() <= 0
	elif selectMode == MODE_SELECT_DOWNLOADED:
		loadButton.disabled = downloadedTrackList.get_selected_items().size() <= 0
	uploadButton.disabled = localTrackList.get_selected_items().size() <= 0


func uploadTrack(trackFileName: String):
	print("Uploading track: ", trackFileName)
	var uploadRequest = HTTPRequest.new()
	add_child(uploadRequest)

	var path = "user://tracks/local/" + trackFileName
	var fileHandler = FileAccess.open(path, FileAccess.READ)

	uploadRequest.request_completed.connect(onUploadRequest_completed)

	var httpError = uploadRequest.request(
		"http://localhost:80/api/tracks/upload",
		[
			"Content-Type: application/json",
			"Session-Token: " + Playerstats.SESSION_TOKEN
		],
		HTTPClient.METHOD_POST,
		fileHandler.get_as_text()
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onUploadRequest_completed(result: int, responseCode: int, headers: PackedStringArray, body: PackedByteArray):

	if (responseCode != 200):
		setLoadUploadButtonEnabled()
		showAlert("Error", "Upload Failed", body.get_string_from_utf8()) 
		return
	
	var response = JSON.parse_string(body.get_string_from_utf8())

	showAlert("Success", response.name + " Uploaded Successfully", "Track ID: " + response._id) 

func loadTrackListItems():
	var loadTracksRequest = HTTPRequest.new()
	add_child(loadTracksRequest)
	loadTracksRequest.request_completed.connect(onLoadTracksRequest_completed)
	var httpError = loadTracksRequest.request(
		"http://localhost:80/api/tracks",
		[
			"Content-Type: application/json"
		],
		HTTPClient.METHOD_GET
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onLoadTracksRequest_completed(result: int, responseCode: int, headers: PackedStringArray, body: PackedByteArray):
	if (responseCode != 200):
		showAlert("Error", "Failed to load tracks", body.get_string_from_utf8()) 
		return
	
	var response = JSON.parse_string(body.get_string_from_utf8())
	onlineTrackList.clear()
	onlineTrackListItems.clear()
	for track in response:
		onlineTrackListItems.append(track)
		onlineTrackList.add_item(track.name + " - by: " + track.author.username)
	
	showAlert("Success", "Tracks Loaded Successfully", "Found " + str(onlineTrackListItems.size()) + " tracks")

var downloadingTrack: bool = false
var lastDownloadedTrackId: String = ""
func downloadTrack(trackId: String):
	var downloadRequest = HTTPRequest.new()
	add_child(downloadRequest)
	downloadRequest.request_completed.connect(onDownloadRequest_completed)
	downloadingTrack = true
	lastDownloadedTrackId = trackId
	var httpError = downloadRequest.request(
		"http://localhost:80/api/tracks/download/" + trackId,
		[
			"Content-Type: application/json",
			"Session-Token: " + Playerstats.SESSION_TOKEN
		],
		HTTPClient.METHOD_GET
	)

	if httpError != OK:
		print("Error: " + error_string(httpError))

func onDownloadRequest_completed(result: int, responseCode: int, headers: PackedStringArray, body: PackedByteArray):
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
	showAlert("Success", "Track Downloaded Successfully", "Track saved to: " + path)



func setSelectMode(mode: int):
	selectMode = mode
	setButtonVisibility(mode)
	setListVisibility(mode)

func setButtonVisibility(mode: int):
	loadButton.visible = mode == MODE_SELECT_LOCAL || mode == MODE_SELECT_DOWNLOADED
	uploadButton.visible = mode == MODE_SELECT_LOCAL && editorSelect
	downloadButton.visible = mode == MODE_SELECT_SEARCH

func setListVisibility(mode: int):
	localTrackList.visible = mode == MODE_SELECT_LOCAL
	downloadedTrackList.visible = mode == MODE_SELECT_DOWNLOADED
	onlineTrackList.visible = mode == MODE_SELECT_SEARCH


func showAlert(title: String, text: String, response: String):
	var alert = AcceptDialog.new()
	alert.title = title
	alert.dialog_text = text + "\n"
	alert.dialog_text += response
	alert.canceled.connect(alert.queue_free)
	add_child(alert)
	alert.popup_centered()