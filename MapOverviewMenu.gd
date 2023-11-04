@tool
extends Control

@export
var trackId: String = "650c73d0c3b8efa6383dde32"


@onready var trackName: Label = %TrackName
@onready var author: Label = %Author
@onready var leaderboardMenu: LeaderboardMenu = %LeaderboardMenu
@onready var downloadNumber: Label = %DownloadNumber
@onready var ratingNumber: Label = %RatingNumber
@onready var uploadDate: Label = %UploadDate

@onready var commentsContainer: Control = %CommentsContainer
@onready var openCommentsButton: Button = %OpenCommentsButton
@onready var closeCommentsButton: Button = %CloseCommentsButton

func _ready():
	leaderboardMenu.fetchTimes(trackId)
	openCommentsButton.pressed.connect(commentsContainer.show)
	closeCommentsButton.pressed.connect(commentsContainer.hide)
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

