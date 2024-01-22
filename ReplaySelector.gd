extends Control
class_name ReplaySelector

@onready var localReplays: ItemList = %LocalReplays
@onready var downloadedReplays: ItemList = %DownloadedReplays

@onready var selectButton: Button = %SelectButton
@onready var cancelButton: Button = %CancelButton

signal replaysSelected(local: Array[String], online: Array[String])
signal cancelPressed()

var trackId: String = ""

var downloadedReplayIds: Array[String] = []

func _ready():
	localReplays.clear()
	downloadedReplays.clear()

	selectButton.pressed.connect(func():
		var local: Array[String] = []
		for index in localReplays.get_selected_items():
			local.append(localReplays.get_item_text(index))
		var online: Array[String] = []
		for index in downloadedReplays.get_selected_items():
			online.append(downloadedReplayIds[index])
		# TODO: handle downloaded replays

		if local.size() == 0 and online.size() == 0:
			return

		print("[ReplaySelector.gd] selected replays: ", local, online)

		hide()
		replaysSelected.emit(local, online)
	)

	cancelButton.pressed.connect(func():
		localReplays.deselect_all()
		downloadedReplays.deselect_all()
		hide()
		replaysSelected.emit([] as Array[String], [] as Array[String])
		cancelPressed.emit()
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
	localReplays.deselect_all()
	localReplays.clear()

	if trackId == "":
		return

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
			var replayFormatVersion = fileHandler.get_8()
			if replayFormatVersion != ReplayManager.REPLAY_FORMAT_VERSION:
				fileName = directory.get_next()
				continue
			# var replayTrackId = fileHandler.get_line()
			var mapMetadata = fileHandler.get_csv_line()
			var replayTrackId = mapMetadata[0]
			if replayTrackId == trackId:
				localReplays.add_item(fileName)

			fileName = directory.get_next()

func loadDownloadedReplays(trackId: String) -> void:
	downloadedReplays.deselect_all()
	downloadedReplays.clear()
	downloadedReplayIds.clear()

	var path = "user://replays/downloaded/"
	var directory = DirAccess.open(path)

	if directory:
		directory.list_dir_begin()
		var fileName = directory.get_next()
		while fileName != "":
			var fileHandler = FileAccess.open(path + fileName, FileAccess.READ)
			if fileHandler == null:
				fileName = directory.get_next()
				continue
			var replayFormatVersion = fileHandler.get_8()
			if replayFormatVersion != ReplayManager.REPLAY_FORMAT_VERSION:
				fileName = directory.get_next()
				continue

			var mapMetadata = fileHandler.get_csv_line()

			var replayTrackId = mapMetadata[0]
			if replayTrackId == trackId:
				var _nrCars = fileHandler.get_16()
				var time = fileHandler.get_32()
				var carMetadata = fileHandler.get_csv_line()
				var carName = carMetadata[0]

				var itemName = carName + " - " + IngameHUD.getTimeStringFromTicks(time)

				downloadedReplays.add_item(itemName)
				downloadedReplayIds.append(fileName)



			fileName = directory.get_next()

func refresh() -> void:
	loadLocalReplays(trackId)
	loadDownloadedReplays(trackId)

func hideDownloaded():
	%Downloaded.hide()