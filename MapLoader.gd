extends Control
class_name MapLoader

@onready var localTrackList: ItemList = %LocalTrackList

@onready var backButton: Button = %BackButton
@onready var playButton: Button = %PlayButton
@onready var editButton: Button = %EditButton
@onready var deleteButton: Button = %DeleteButton
@onready var uploadButton: Button = %UploadButton
@onready var newButton: Button = %NewButton

var localTrackListItems: Array = []

var editorSelect: bool = false

# signal trackSelected(trackName: String)
signal playTrack(trackName: String)
signal editTrack(trackName: String)
signal backPressed()
# Called when the node enters the scene tree for the first time.
func _ready():
	backButton.pressed.connect(onBackButton_pressed)
	playButton.pressed.connect(onPlayButton_pressed)
	editButton.pressed.connect(onEditButton_pressed)
	deleteButton.pressed.connect(onDeleteButton_pressed)
	uploadButton.pressed.connect(onUploadButton_pressed)
	newButton.pressed.connect(onNewButton_pressed)


	localTrackList.item_selected.connect(onLocalTrackList_itemSelected)
	localTrackList.item_activated.connect(onEditButton_pressed)

	visibility_changed.connect(onVisibilityChanged)
	backButton.grab_focus()

	playButton.disabled = true
	editButton.disabled = true
	deleteButton.disabled = true
	uploadButton.disabled = true

	loadLocalTracks()

func onVisibilityChanged():
	if visible:
		loadLocalTracks()
	setButtonsEnabled()

func onLocalTrackList_itemSelected(_index: int) -> void:
	setButtonsEnabled()

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

func onEditButton_pressed(_sink = null):
	var trackName = ""
	trackName = "user://tracks/local/" 
	trackName += localTrackListItems[localTrackList.get_selected_items()[0]]
	visible = false
	editTrack.emit(trackName)
	print("Selected track for edit: ", trackName)

func onPlayButton_pressed(_sink = null):
	var trackName = ""
	trackName = "user://tracks/local/" 
	trackName += localTrackListItems[localTrackList.get_selected_items()[0]]
	visible = false
	playTrack.emit(trackName)
	print("Selected track for play: ", trackName)

var selectedTrackForDelete: String = ""
func onDeleteButton_pressed() -> void:
	# showAlert("Confirm", "Are you sure you want to delete this track?", "This action cannot be undone", true)
	var trackName = ""
	var readableTrackName = ""
	trackName = "user://tracks/local/" 
	trackName += localTrackListItems[localTrackList.get_selected_items()[0]]
	readableTrackName = localTrackList.get_item_text(localTrackList.get_selected_items()[0])
	selectedTrackForDelete = trackName
	# showDeleteAlert(readableTrackName)
	AlertManager.showDeleteAlert(
		self,
		"Are you sure you want to delete this track?\n",
		onDeleteConfirmed,
		readableTrackName + "\n",
	)

	print("Deleting track: ", trackName)

func onDeleteConfirmed():
	var fileHandler = DirAccess.open("user://")
	if fileHandler.file_exists(selectedTrackForDelete):
		fileHandler.remove(selectedTrackForDelete)
		loadLocalTracks()

	selectedTrackForDelete = ""

func onUploadButton_pressed() -> void:
	var trackName = localTrackListItems[localTrackList.get_selected_items()[0]]
	uploadTrack(trackName)

func onBackButton_pressed() -> void:
	visible = false
	backPressed.emit()

func onNewButton_pressed() -> void:
	visible = false
	editTrack.emit("")

func setButtonsEnabled():
	var disabledButtons = localTrackList.get_selected_items().size() <= 0
	playButton.disabled = disabledButtons
	editButton.disabled = disabledButtons
	deleteButton.disabled = disabledButtons
	uploadButton.disabled = disabledButtons


func uploadTrack(trackFileName: String):
	if VersionCheck.offline:
		AlertManager.showAlert(self, "Error", "Cannot upload track in offline mode", "Please connect to the internet and try again") 
		return
	print("Uploading track: ", trackFileName)
	

	var path = "user://tracks/local/" + trackFileName
	var fileHandler = FileAccess.open(path, FileAccess.READ)

	var fileText = fileHandler.get_as_text()

	var jsonData = JSON.parse_string(fileText)

	if (jsonData == null):
		AlertManager.showAlert(self, "Error", "Upload Failed", "Invalid JSON") 
		return
	if (!jsonData.has("validated") || jsonData.validated == false):
		AlertManager.showAlert(self, "Error", "Upload Failed", "Track must be validated (completed) before uploading") 
		return

	# upload replay

	var replayRequest = HTTPRequest.new()
	add_child(replayRequest)
	replayRequest.timeout = 10
	replayRequest.request_completed.connect(func(_result, response_code, _headers, _body):
		if response_code != 200:
			print(_body.get_string_from_utf8())
			return
		
		var replayId = JSON.parse_string(_body.get_string_from_utf8())._id

		if jsonData.bestTotalReplay != jsonData.bestLapReplay:
			# upload lap replay
			var lapReplayRequest = HTTPRequest.new()
			add_child(lapReplayRequest)
			lapReplayRequest.timeout = 10
			lapReplayRequest.request_completed.connect(func(_result, response_code, _headers, _body):
				if response_code != 200:
					print(_body.get_string_from_utf8())
					return
				
				var lapReplayId = JSON.parse_string(_body.get_string_from_utf8())._id

				jsonData.bestLapReplay = lapReplayId
				jsonData.bestTotalReplay = replayId

				sendUploadRequest(jsonData)
			)

			var lapReplayData = FileAccess.open(jsonData.bestLapReplay, FileAccess.READ)
			var lapReplayBytes = lapReplayData.get_buffer(lapReplayData.get_length())
			lapReplayData.close()

			var httpError = lapReplayRequest.request_raw(
				Backend.BACKEND_IP_ADRESS + "/api/replays/validation",
				[
					"Content-Type: application/octet-stream",
					"Session-Token: " + GlobalProperties.SESSION_TOKEN
				],
				HTTPClient.METHOD_POST,
				lapReplayBytes
			)

			if httpError != OK:
				print("Error: " + error_string(httpError))
				AlertManager.showAlert(self, "Error", "Upload Failed", "Error uploading lap replay")
		else:
			jsonData.bestTotalReplay = replayId
			sendUploadRequest(jsonData)

	)

	var replayData = FileAccess.open(jsonData.bestTotalReplay, FileAccess.READ)
	var replayBytes = replayData.get_buffer(replayData.get_length())
	replayData.close()

	var httpError = replayRequest.request_raw(
		Backend.BACKEND_IP_ADRESS + "/api/replays/validation",
		[
			"Content-Type: application/octet-stream",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN
		],
		HTTPClient.METHOD_POST,
		replayBytes
	)

	if httpError != OK:
		print("Error: " + error_string(httpError))
		AlertManager.showAlert(self, "Error", "Upload Failed", "Error uploading replay")


func sendUploadRequest(jsonData):

	var uploadRequest = HTTPRequest.new()
	add_child(uploadRequest)
	uploadRequest.timeout = 30

	uploadRequest.request_completed.connect(onUploadRequest_completed)

	var httpError = uploadRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/tracks/upload",
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(jsonData)
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onUploadRequest_completed(_result: int, responseCode: int, _headers: PackedStringArray, body: PackedByteArray):

	if (responseCode != 200):
		setButtonsEnabled()
		AlertManager.showAlert(self, "Error", "Upload Failed", body.get_string_from_utf8()) 
		return
	
	var response = JSON.parse_string(body.get_string_from_utf8())

	AlertManager.showAlert(self, "Success", response.name + " Uploaded Successfully", "Track ID: " + response._id) 

