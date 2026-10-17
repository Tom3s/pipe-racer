extends Node
class_name EditorMapLoader

# var editorScene = preload("res://MapEditor.tscn")
var editorScene = preload("res://Editor/MapEditor.tscn")

var raceIngame = preload("res://GameScene.tscn")

var mapLoader: MapLoader

var editor: MapEditor
var raceNode: GameScene


signal backPressed()
signal enteredMapEditor()
signal exitedMapEditor()

func _ready():
	mapLoader = %MapLoader

	# mapLoader.setEditorSelect(true)
	# mapLoader.trackSelected.connect(editMap)
	mapLoader.editTrack.connect(editMap)
	mapLoader.playTrack.connect(playMap)
	mapLoader.backPressed.connect(onMapLoader_backPressed)

func show():
	mapLoader.visible = true

func hide():
	mapLoader.visible = false

func editMap(mapName: String):
	MogyiLogger.log(self, "Opening map for editing: %s" % mapName)
	editor = editorScene.instantiate()
	add_child(editor)
	# editor.loadFailed.connect(unloadMap)
	if mapName != "":
		var success = editor.loadMap(mapName)
		MogyiLogger.log(self, "Map load result: %s" % str(success))
		if !success:
			unloadMap()
			AlertManager.showAlert(
				self,
				"Error loading map",
				"Try updating the map to the new format, or download it again"
			)
			return
	editor.editorExited.connect(unloadMap)
	mapLoader.visible = false
	enteredMapEditor.emit()

func unloadMap():
	editor.queue_free()
	mapLoader.visible = true
	exitedMapEditor.emit()

func onMapLoader_backPressed():
	backPressed.emit()

func playMap(trackName: String):
	raceNode = raceIngame.instantiate()
	add_child(raceNode)
	raceNode.exitPressed.connect(onRace_exited)
	Network.localData = [
		PlayerData.new(
			"",
			GlobalProperties.PLAYER_NAME,
			GlobalProperties.PLAYER_COLOR,
		)
	]
	var setup_result: GameScene.SetupResult = raceNode.setup(trackName, false, false, true)
	if setup_result != GameScene.SetupResult.SUCCESS:
		match setup_result:
			GameScene.SetupResult.NO_CP:
				AlertManager.showAlert(
					self,
					"Error loading map",
					"A level cannot be validated until it has at least 1 Checkpoint"
				)

			GameScene.SetupResult.NO_START:
				AlertManager.showAlert(
					self,
					"Error loading map",
					"There is no Start Line in the level"
				)

			GameScene.SetupResult.INVALID_DATA:
				AlertManager.showAlert(
					self,
					"Error loading map",
					"Level data is invalid. Level might be corrupt or uses old format"
				)

			_:
				AlertManager.showAlert(
					self,
					"Error loading map",
					"Unknown error: %s. Please report this to a developer" % str(setup_result)
				)
				
		mapLoader.visible = true

func onRace_exited():
	raceNode.queue_free()
	mapLoader.visible = true
