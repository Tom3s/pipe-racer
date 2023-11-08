extends Control
class_name OnlineTracksContainer

@onready var trackList: VBoxContainer = %TrackList
@onready var backButton: Button = %BackButton

@onready var mainContents: VBoxContainer = %MainContents

@onready var trackPanelScene = preload("res://Menu/TrackPanel.tscn")

signal trackPlayPressed(trackPath: int)
signal viewPressed(trackId: int)
signal backPressed()

func _ready():
	loadTracks()
	backButton.pressed.connect(onBackButton_Pressed)

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
		# await trackPanel.
		trackPanel.viewButtonPressed.connect(
			func(id): 
				await animateOut()
				viewPressed.emit(id)
		)

func onBackButton_Pressed():
	await animateOut()
	backPressed.emit()

const ANIMATE_TIME = 0.3
func animateIn():
	var tween = create_tween()

	var windowSize = get_viewport_rect().size

	tween.tween_property(mainContents, "inAnimation", true, 0.0)
	tween.tween_property(mainContents, "position", Vector2(0, -windowSize.y), 0.0)\
		.as_relative()

	tween.tween_property(self, "visible", true, 0.0)
	tween.tween_property(mainContents, "position", Vector2(0, windowSize.y), ANIMATE_TIME)\
		.as_relative()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(mainContents, "inAnimation", false, 0.0)

func animateOut():
	var tween = create_tween()

	var windowSize = get_viewport_rect().size

	tween.tween_property(mainContents, "inAnimation", true, 0.0)
	tween.tween_property(mainContents, "position", Vector2(0, -windowSize.y), ANIMATE_TIME)\
		.as_relative()\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(mainContents, "inAnimation", false, 0.0)
	tween.tween_property(self, "visible", false, 0.0)
	# tween.tween_callback(func(): backPressed.emit())

	return tween.finished
