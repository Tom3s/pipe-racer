extends Control
class_name MapLoader

@onready var trackList: ItemList = %TrackList
@onready var loadButton: Button = %LoadButton
@onready var backButton: Button = %BackButton

var trackListItems: Array = []

signal trackSelected(trackName: String)
signal backPressed()
# Called when the node enters the scene tree for the first time.
func _ready():
	loadButton.pressed.connect(onLoadButton_pressed)
	backButton.pressed.connect(onBackButton_pressed)

	loadButton.disabled = true

	loadTracks()


func loadTracks() -> void:
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
	
	if trackListItems.size() > 0:
		loadButton.disabled = false

func onLoadButton_pressed() -> void:
	var trackName = trackListItems[trackList.get_selected_items()[0]]
	visible = false
	trackSelected.emit(trackName)
	print("Selected track: ", trackName)

func onBackButton_pressed() -> void:
	visible = false
	backPressed.emit()
