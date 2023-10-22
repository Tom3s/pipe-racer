extends Node3D
class_name MapEditor

signal editorExited()

@onready var map: Map = %Map

func loadMap(mapName: String) -> bool:
	map.loaded.connect(printDebug)
	var success = map.loadMap(mapName)
	# return await map.loaded
	# await map.loaded
	# print("Loading map from: " + mapName, map.mapLoadSuccess)
	return success

func printDebug():
	print("MapEditor: ", map.mapLoadSuccess)
