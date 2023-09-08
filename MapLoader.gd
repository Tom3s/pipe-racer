extends Control
class_name MapLoader

@onready var trackList: ItemList = %TrackList
@onready var backButton: Button = %BackButton
@onready var loadButton: Button = %LoadButton
@onready var uploadButton: Button = %UploadButton
@onready var newButton: Button = %NewButton

var trackListItems: Array = []

var editorSelect: bool = false

signal trackSelected(trackName: String)
signal backPressed()
# Called when the node enters the scene tree for the first time.
func _ready():
	backButton.pressed.connect(onBackButton_pressed)
	loadButton.pressed.connect(onLoadButton_pressed)
	uploadButton.pressed.connect(onUploadButton_pressed)
	newButton.pressed.connect(onNewButton_pressed)

	trackList.item_selected.connect(onTrackList_itemSelected)

	visibility_changed.connect(loadTracks)

	loadButton.disabled = true
	uploadButton.disabled = true

	setEditorSelect(false)

	loadTracks()


func loadTracks() -> void:
	if not visible:
		return
	trackList.clear()
	trackListItems.clear()
	var path = "user://tracks/local/"
	var directory = DirAccess.open(path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			trackListItems.append(file_name.replace(path, ""))
			file_name = directory.get_next()
	
	for track in trackListItems:
		trackList.add_item(track.replace(".json", ""))
	
	# if trackListItems.size() > 0:
	# 	loadButton.disabled = false

func onTrackList_itemSelected(index: int) -> void:
	setLoadUploadButtonEnabled()


func onLoadButton_pressed() -> void:
	var trackName = trackListItems[trackList.get_selected_items()[0]]
	visible = false
	trackSelected.emit(trackName)
	print("Selected track: ", trackName)

func onUploadButton_pressed() -> void:
	var trackName = trackListItems[trackList.get_selected_items()[0]]
	uploadTrack(trackName)

func onBackButton_pressed() -> void:
	visible = false
	backPressed.emit()

func onNewButton_pressed() -> void:
	visible = false
	trackSelected.emit("")

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
	loadButton.disabled = trackList.get_selected_items().size() <= 0
	uploadButton.disabled = trackList.get_selected_items().size() <= 0

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
	


func showAlert(title: String, text: String, response: String):
	var alert = AcceptDialog.new()
	alert.title = title
	alert.dialog_text = text + "\n"
	alert.dialog_text += response
	alert.canceled.connect(alert.queue_free)
	add_child(alert)
	alert.popup_centered()
