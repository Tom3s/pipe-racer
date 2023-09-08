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

# var mode: int = MODE_SELECT_LOCAL

signal trackSelected(trackName: String)
signal backPressed()
# Called when the node enters the scene tree for the first time.
func _ready():
	backButton.pressed.connect(onBackButton_pressed)
	loadButton.pressed.connect(onLoadButton_pressed)
	uploadButton.pressed.connect(onUploadButton_pressed)
	newButton.pressed.connect(onNewButton_pressed)

	localButton.pressed.connect(onLocalButton_pressed)
	downloadedButton.pressed.connect(onDownloadedButton_pressed)
	findButton.pressed.connect(onFindButton_pressed)

	localTrackList.item_selected.connect(onLocalTrackList_itemSelected)

	visibility_changed.connect(loadLocalTracks)

	loadButton.disabled = true
	uploadButton.disabled = true

	setListVisibility(MODE_SELECT_LOCAL)


	setEditorSelect(true)

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
			downloadedTrackListItems.append(file_name.replace(path, ""))
			file_name = directory.get_next()
	
	for track in downloadedTrackListItems:
		downloadedTrackList.add_item(track.replace(".json", ""))

func searchTracks() -> void:
	if not visible:
		return


func onLocalTrackList_itemSelected(index: int) -> void:
	setLoadUploadButtonEnabled()

func onLoadButton_pressed() -> void:
	var trackName = localTrackListItems[localTrackList.get_selected_items()[0]]
	visible = false
	trackSelected.emit(trackName)
	print("Selected track: ", trackName)

func onUploadButton_pressed() -> void:
	var trackName = localTrackListItems[localTrackList.get_selected_items()[0]]
	uploadTrack(trackName)

func onBackButton_pressed() -> void:
	visible = false
	backPressed.emit()

func onNewButton_pressed() -> void:
	visible = false
	trackSelected.emit("")

func onLocalButton_pressed():
	setButtonVisibility(MODE_SELECT_LOCAL)
	setListVisibility(MODE_SELECT_LOCAL)
	loadLocalTracks()

func onDownloadedButton_pressed():
	setButtonVisibility(MODE_SELECT_DOWNLOADED)
	setListVisibility(MODE_SELECT_DOWNLOADED)
	loadDownloadedTracks()

func onFindButton_pressed():
	setButtonVisibility(MODE_SELECT_SEARCH)
	setListVisibility(MODE_SELECT_SEARCH)





# func showNewButton(value: bool):
# 	newButton.visible = value
func setEditorSelect(value: bool):
	editorSelect = value
	if editorSelect:
		newButton.visible = true
		uploadButton.visible = true
		loadButton.text = "Edit"
	else:
		newButton.visible = false
		uploadButton.visible = false
		loadButton.text = "Load"
		hideTabButtons()

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
	loadButton.disabled = localTrackList.get_selected_items().size() <= 0
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



func setButtonVisibility(mode: int):
	loadButton.visible = mode == MODE_SELECT_LOCAL || mode == MODE_SELECT_DOWNLOADED
	uploadButton.visible = mode == MODE_SELECT_LOCAL
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
