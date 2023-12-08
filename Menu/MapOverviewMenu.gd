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
@onready var rateButton: Button = %RateButton
@onready var ratingMenu: RatingMenu = %RatingMenu
@onready var refreshButton: Button = %RefreshButton
@onready var deleteButton: Button = %DeleteButton

@onready var backButton: Button = %BackButton
@onready var selectButton: Button = %SelectButton

@onready var mainContents: MarginContainer = %MainContents


signal backPressed()
signal playPressed(trackPath: String)

signal loaded()

func _ready():
	openCommentsButton.pressed.connect(commentsContainer.show)
	rateButton.pressed.connect(ratingMenu.show)
	commentsContainer.hide()
	ratingMenu.hide()
	backButton.pressed.connect(onBackPressed)
	commentsContainer.closePressed.connect(func():
		selectButton.grab_focus()
	)
	ratingMenu.closePressed.connect(func():
		selectButton.grab_focus()
	)
	ratingMenu.ratingSubmitted.connect(func(x):
		ratingNumber.text = str(x).pad_decimals(2) + "/5"
	)
	selectButton.pressed.connect(onSelectButton_Pressed)
	refreshButton.pressed.connect(func():
		leaderboardMenu.fetchTimes(trackId)
		fetchLevelDetails()
	)
	deleteButton.pressed.connect(onDeleteButton_Pressed)
	set_physics_process(true)

func _physics_process(delta):
	if (get_viewport().gui_get_focus_owner() == null || !get_viewport().gui_get_focus_owner().is_visible_in_tree())  && mainContents.visible:
		# playButton.grab_focus()
		if Input.is_action_just_pressed("ui_left") || \
			Input.is_action_just_pressed("ui_right") || \
			Input.is_action_just_pressed("ui_up") || \
			Input.is_action_just_pressed("ui_down") || \
			Input.is_action_just_pressed("ui_accept") || \
			Input.is_action_just_pressed("ui_cancel"):
			selectButton.grab_focus()

var downloaded = false

func onBackPressed():
	commentsContainer.hide()
	ratingMenu.hide()
	animateOut()

func init(initTrackId: String) -> bool:
	if initTrackId == trackId:
		return false
	trackId = initTrackId
	leaderboardMenu.fetchTimes(trackId)
	commentsContainer.init(
		trackId	
	)
	ratingMenu.init(
		trackId
	)
	downloaded = isDownloaded()
	if downloaded:
		selectButton.setLabelText("Play")
		deleteButton.show()
	else:
		selectButton.setLabelText("Download")
		deleteButton.hide()

	fetchLevelDetails()
	return true

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
	if _responseCode != 200:
		print("Error: ", _responseCode)

		if (_responseCode == 404):
			AlertManager.showAlert(self, "Error", "Track not found", "The track you are looking for does not exist")
			onBackPressed()
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())

	trackName.text = data.name
	author.text = "By: " + data.author.username

	downloadNumber.text = str(data.downloads)

	ratingNumber.text = str(data.rating).pad_decimals(2) + "/5"

	uploadDate.text = data.uploadDate.split("T")[0]

	loaded.emit()

func isDownloaded() -> bool:
	# if not visible:
	# 	return false
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
	deleteButton.show()
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
	deleteButton.hide()

const ANIMATE_TIME = 0.3
func animateIn():
	var tween = create_tween()

	var windowSize = get_viewport_rect().size

	tween.tween_property(mainContents, "inAnimation", true, 0.0)
	tween.tween_property(mainContents, "position", Vector2(0, windowSize.y), 0.0)\
		.as_relative()

	tween.tween_property(self, "visible", true, 0.0)
	tween.tween_property(mainContents, "position", Vector2(0, -windowSize.y), ANIMATE_TIME)\
		.as_relative()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(mainContents, "inAnimation", false, 0.0)
	tween.tween_callback(selectButton.grab_focus)

func animateOut():
	var tween = create_tween()

	var windowSize = get_viewport_rect().size

	tween.tween_property(mainContents, "inAnimation", true, 0.0)
	tween.tween_property(mainContents, "position", Vector2(0, windowSize.y), ANIMATE_TIME)\
		.as_relative()\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(mainContents, "inAnimation", false, 0.0)
	tween.tween_property(self, "visible", false, 0.0)
	tween.tween_callback(func(): backPressed.emit())
