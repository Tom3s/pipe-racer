extends Node
class_name EditorMapLoader

var editorScene = preload("res://MapEditor.tscn")

var mapLoader: MapLoader

var editor: MapEditor

signal backPressed()
signal enteredMapEditor()
signal exitedMapEditor()

func _ready():
	mapLoader = %MapLoader

	mapLoader.setEditorSelect(true)
	mapLoader.trackSelected.connect(editMap)
	mapLoader.backPressed.connect(onMapLoader_backPressed)

func show():
	mapLoader.visible = true

func hide():
	mapLoader.visible = false

func editMap(mapName: String):
	print("Editing map: ", mapName)
	editor = editorScene.instantiate()
	add_child(editor)
	if mapName != "":
		editor.loadMap(mapName)
	editor.editorExited.connect(unloadMap)
	mapLoader.visible = false
	enteredMapEditor.emit()

func unloadMap():
	editor.queue_free()
	mapLoader.visible = true
	exitedMapEditor.emit()

func onMapLoader_backPressed():
	backPressed.emit()