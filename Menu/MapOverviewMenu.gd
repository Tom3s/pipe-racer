extends Control
class_name MapOverviewMenu

@export
var trackId: String = "650c73d0c3b8efa6383dde32"


@onready var trackName: Label = %TrackName
@onready var author: Label = %Author
@onready var leaderboardMenu: LeaderboardMenu = %LeaderboardMenu
@onready var downloadNumber: Label = %DownloadNumber
@onready var ratingNumber: Label = %RatingNumber
@onready var uploadDate: Label = %UploadDate

@onready var commentsContainer: CommentsContainer = %CommentsContainer
@onready var openCommentsButton: Button = %OpenCommentsButton
@onready var deleteButton: Button = %DeleteButton

@onready var backButton: Button = %BackButton
@onready var selectButton: Button = %SelectButton

signal backPressed()
signal playPressed(trackPath: String)

func _ready():
	openCommentsButton.pressed.connect(commentsContainer.show)
	commentsContainer.hide()
	backButton.pressed.connect(func(): backPressed.emit())
	selectButton.pressed.connect(onSelectButton_Pressed)
	deleteButton.pressed.connect(onDeleteButton_Pressed)

var downloaded = false

func init(initTrackId: String):
	trackId = initTrackId
	leaderboardMenu.fetchTimes(trackId)
	commentsContainer.init(
		trackId	
	)
	downloaded = isDownloaded()
	if downloaded:
		selectButton.setLabelText("Play")
	else:
		selectButton.setLabelText("Download")
	fetchLevelDetails()

func fetchLevelDetails():
	downloadNumber.text = "0"
	var detailsRequest = HTTPRequest.new()
	add_child(detailsRequest)
	detailsRequest.timeout = 25
	detailsRequest.request_completed.connect(onDetailsRequest_RequestCompleted)

	var httpError = detailsRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/tracks/" + trackId
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onDetailsRequest_RequestCompleted(result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != OK:
		print("Error: " + error_string(result))
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())

	trackName.text = data.name
	author.text = "By: " + data.author.username

	downloadNumber.text = str(data.downloads)

	ratingNumber.text = str(data.rating).pad_decimals(2) + "/5"

	uploadDate.text = data.uploadDate.split("T")[0]

func isDownloaded() -> bool:
	if not visible:
		return false
	var path = "user://tracks/downloaded/"
	var directory = DirAccess.open(path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			if file_name == trackId + ".json":
				return true
			file_name = directory.get_next()
		return false
	return false

func onSelectButton_Pressed():
	if downloaded:
		hide() 
		playPressed.emit("user://tracks/downloaded/" + trackId + ".json")
	else:
		downloadTrack()

func downloadTrack():
	if VersionCheck.offline:
		AlertManager.showAlert(self, "Error", "Cannot download track in offline mode", "Please connect to the internet and try again") 
		return
	var downloadRequest = HTTPRequest.new()
	add_child(downloadRequest)
	downloadRequest.timeout = 30
	downloadRequest.request_completed.connect(onDownloadRequest_completed)
	# downloadingTrack = true
	selectButton.setLabelText("Downloading...")
	selectButton.disabled = true
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
		AlertManager.showAlert(self, "Error", "Failed to download track", body.get_string_from_utf8()) 
		return
	
	# var response = JSON.parse_string(body.get_string_from_utf8())
	var path = "user://tracks/downloaded/" + trackId + ".json"
	var fileHandler = FileAccess.open(path, FileAccess.WRITE)
	fileHandler.store_string(body.get_string_from_utf8())
	fileHandler.close()

	downloaded = true
	selectButton.setLabelText("Play")
	selectButton.disabled = false

	var json = JSON.parse_string(body.get_string_from_utf8())
	AlertManager.showAlert(self, "Success", "Track Downloaded Successfully", "Track Name: " + json.trackName)

func onDeleteButton_Pressed():
	AlertManager.showDeleteAlert(
		self,
		"Are you sure you want to delete this track?",
		deleteTrack
	)

func deleteTrack():
	var fileHandler = DirAccess.open("user://")
	var selectedTrackForDelete = "user://tracks/downloaded/" + trackId + ".json"
	if fileHandler.file_exists(selectedTrackForDelete):
		fileHandler.remove(selectedTrackForDelete)
	downloaded = false
	selectButton.setLabelText("Download")