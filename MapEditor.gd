extends Node3D
class_name MapEditorOld

signal editorExited()

@onready var map: Map = %Map

func loadMap(mapName: String) -> bool:
	map.loaded.connect(printDebug)
	map.editing = true
	var success = map.loadMap(mapName)
	return success

func printDebug():
	print("MapEditor: ", map.mapLoadSuccess)
