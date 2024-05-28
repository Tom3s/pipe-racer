extends Control
class_name ReplayViewerLoader

@onready var mapList: ItemList = %MapList
@onready var replaySelector: ReplaySelector = %ReplaySelector

var ReplayViewerScene := preload("res://Menu/ReplayViewer.tscn")

var trackIds: Array = []
var currentTrackId: String = ""

signal backPressed()

func _ready():
	loadMapList()

	mapList.item_selected.connect(func(index: int):
		replaySelector.init(trackIds[index])
		currentTrackId = trackIds[index]
	)

	replaySelector.cancelPressed.connect(func():
		replaySelector.show()
		hide()
		backPressed.emit()
	)

	replaySelector.replaysSelected.connect(func(local: Array[String], online: Array[String]):
		if local.size() == 0 and online.size() == 0:
			return
		replaySelector.show()

		var replayViewer: ReplayViewer = ReplayViewerScene.instantiate()
		add_child(replayViewer)
		replayViewer.setup(
			local,
			online,
			currentTrackId
		)
		replayViewer.exitPressed.connect(func():
			show()
			get_tree().root.get_node("MainMenu/Background").show()
		)
		hide()
		get_tree().root.get_node("MainMenu/Background").hide()
	)

	visibility_changed.connect(func():
		if is_visible_in_tree():
			loadMapList()
	)
			

func loadMapList():
	mapList.clear()
	trackIds.clear()
	var path = "user://tracks/downloaded/"
	var directory = DirAccess.open(path)
	if directory:
		directory.list_dir_begin()
		var fileName = directory.get_next()
		while fileName != "":
			var fileHandler = FileAccess.open(path + fileName, FileAccess.READ)
			var trackItem = JSON.parse_string(fileHandler.get_as_text())

			if trackItem.format <= Map.CURRENT_FORMAT_VERSION:
				mapList.add_item(trackItem.trackName + " - by: " + trackItem.author)
			else:
				mapList.add_item(trackItem.metadata.trackName + " - by: " + trackItem.metadata.author)

			trackIds.append(fileName.split(".")[0])

			fileName = directory.get_next()
