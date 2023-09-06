extends Node

var editorScene = preload("res://MapEditor.tscn")

var mapLoader: MapLoader

var editor: MapEditor

func _ready():
	mapLoader = %MapLoader

	mapLoader.trackSelected.connect(editMap)
	

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
