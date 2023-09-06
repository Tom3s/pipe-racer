extends Node
class_name EditorMapLoader

var editorScene = preload("res://MapEditor.tscn")

var mapLoader: MapLoader

var editor: MapEditor

signal backPressed()

func _ready():
	mapLoader = %MapLoader

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
	editor.loadMap(mapName)
	editor.editorExited.connect(unloadMap)
	mapLoader.visible = false

func unloadMap():
	editor.queue_free()
	mapLoader.visible = true

func onMapLoader_backPressed():
	backPressed.emit()
