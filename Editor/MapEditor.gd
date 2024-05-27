extends Node3D
class_name MapEditor

signal editorExited()

# @onready var map: InteractiveMap = %InteractiveMap
@onready var eventListener: EditorEventListener = %EditorEventListener

func loadMap(filePath: String) -> bool:
	# map.loaded.connect(printDebug)
	var success = eventListener.loadMap(filePath)
	return success

# func printDebug():
# 	print("MapEditor: ", map.mapLoadSuccess)