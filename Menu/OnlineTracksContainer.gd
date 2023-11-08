extends Control
class_name OnlineTracksContainer

@onready var trackList: VBoxContainer = %TrackList
@onready var backButton: Button = %BackButton

@onready var trackPanelScene = preload("res://Menu/TrackPanel.tscn")


func _ready():
	loadTracks()

func loadTracks():
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 10
	request.request_completed.connect(onTracksLoaded)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/tracks",
		[
			"Content-Type: application/json",
		],
		HTTPClient.METHOD_GET,
	)
	if httpError != OK:
		print("Error loading tracks: " + error_string(httpError))

func onTracksLoaded(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	if _result != OK:
		print("Error loading tracks: " + error_string(_result))
		return
	
	var tracks = JSON.parse_string(_body.get_string_from_utf8())

	initializeTrackList(tracks)

func initializeTrackList(tracks):
	for track in tracks:
		var trackPanel: TrackPanel = trackPanelScene.instantiate()
		trackList.add_child(trackPanel)
		trackPanel.init(
			track._id,
			track.name,
			track.author.username,
			track.downloads,
			track.rating,
			track.uploadDate.split("T")[0],
		)