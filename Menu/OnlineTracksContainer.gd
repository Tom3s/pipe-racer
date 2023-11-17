extends Control
class_name OnlineTracksContainer

@onready var trackList: VBoxContainer = %TrackList
@onready var backButton: Button = %BackButton

@onready var customTrackId: LineEdit = %CustomTrackId
@onready var loadFromIdButton: Button = %LoadFromIdButton

@onready var downloadedOnlyButton: CheckBox = %DownloadedOnlyButton

@onready var mainContents: VBoxContainer = %MainContents

@onready var trackPanelScene = preload("res://Menu/TrackPanel.tscn")

signal trackPlayPressed(trackPath: int)
signal viewPressed(trackId: int)
signal backPressed()

func _ready():
	loadTracks()
	backButton.pressed.connect(onBackButton_Pressed)
	loadFromIdButton.pressed.connect(func():
		await animateOut()
		viewPressed.emit(customTrackId.text)
	)
	downloadedOnlyButton.toggled.connect(func(newToggleState: bool):
		# showDownloadedOnly = newToggleState
		# loadTracks()
		if newToggleState:
			initializeTrackList(cachedTracks, true)
		else:
			loadTracks()
	)

	set_physics_process(true)

func _physics_process(delta):
	if (get_viewport().gui_get_focus_owner() == null || !get_viewport().gui_get_focus_owner().is_visible_in_tree()) && mainContents.visible:
		# playButton.grab_focus()
		if Input.is_action_just_pressed("ui_left") || \
			Input.is_action_just_pressed("ui_right") || \
			Input.is_action_just_pressed("ui_up") || \
			Input.is_action_just_pressed("ui_down") || \
			Input.is_action_just_pressed("ui_accept") || \
			Input.is_action_just_pressed("ui_cancel"):
			viewButtons.front().grab_focus()

func loadTracks():
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 10
	request.request_completed.connect(onTracksLoaded)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/tracks?sortByField=rating&descending=true",
		[
			"Content-Type: application/json",
		],
		HTTPClient.METHOD_GET,
	)
	if httpError != OK:
		print("Error loading tracks: " + error_string(httpError))

func onTracksLoaded(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	if _responseCode != 200:
		print("Error loading tracks: ", _responseCode)
		return
	
	var tracks = JSON.parse_string(_body.get_string_from_utf8())
	cachedTracks = tracks
	initializeTrackList(cachedTracks)

var cachedTracks = []
var viewButtons: Array[Button] = []
# var showDownloadedOnly: bool = false
func initializeTrackList(tracks, showDownloadedOnly: bool = false):
	cacheDownloadedTracks()
	viewButtons.clear()
	for child in trackList.get_children():
		trackList.remove_child(child)
		child.queue_free()
	for track in tracks:
		if showDownloadedOnly && !(track._id in downloadedTracks):
			continue
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
		viewButtons.push_back(trackPanel.viewButton)
		# await trackPanel.
		trackPanel.viewButtonPressed.connect(
			func(id): 
				await animateOut()
				viewPressed.emit(id)
		)
	
	for i in viewButtons.size():
		var nextIndex = (i + viewButtons.size() + 1) % viewButtons.size()
		var prevIndex = (i + viewButtons.size() - 1) % viewButtons.size()

		viewButtons[i].focus_neighbor_top = viewButtons[prevIndex].get_path()
		viewButtons[i].focus_neighbor_bottom = viewButtons[nextIndex].get_path()
	viewButtons.front().grab_focus()

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

var downloadedTracks: Array[String] = []
func cacheDownloadedTracks() -> void:
	# if not visible:
	# 	return false
	downloadedTracks.clear()
	var path = "user://tracks/downloaded/"
	var directory = DirAccess.open(path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			# if file_name == trackId + ".json":
			# 	return true
			downloadedTracks.append(file_name.split(".")[0])
			file_name = directory.get_next()