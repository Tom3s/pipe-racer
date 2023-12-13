extends Control
class_name ReplaySelector

@onready var localReplays: ItemList = %LocalReplays

@onready var selectButton: Button = %SelectButton
@onready var cancelButton: Button = %CancelButton

signal replaysSelected(local: Array[String], online: Array[String])

var trackId: String = "650c73d0c3b8efa6383dde32"

func _ready():
	localReplays.clear()

	selectButton.pressed.connect(func():
		var local: Array[String] = []
		for index in localReplays.get_selected_items():
			local.append(localReplays.get_item_text(index))
		var online: Array[String] = []
		# TODO: handle downloaded replays

		print("[ReplaySelector.gd] selected replays: ", local, online)

		hide()
		replaysSelected.emit(local, online)
	)

	cancelButton.pressed.connect(func():
		localReplays.deselect_all()
		hide()
		replaysSelected.emit([] as Array[String], [] as Array[String])
	)

	visibility_changed.connect(func():
		if visible:
			refresh()
			selectButton.grab_focus()
	)

	# loadLocalReplays("650c73d0c3b8efa6383dde32")

func init(newTrackId: String) -> void:
	trackId = newTrackId
	refresh()

func loadLocalReplays(trackId: String) -> void:
	localReplays.clear()

	var path = "user://replays/"
	var directory = DirAccess.open(path)

	if directory:
		directory.list_dir_begin()
		var fileName = directory.get_next()
		while fileName != "":
			var fileHandler = FileAccess.open(path + fileName, FileAccess.READ)
			if fileHandler == null:
				fileName = directory.get_next()
				continue
			var replayTrackId = fileHandler.get_line()
			if replayTrackId == trackId:
				localReplays.add_item(fileName)

			fileName = directory.get_next()

func refresh() -> void:
	loadLocalReplays(trackId)