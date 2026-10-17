extends Node3D
class_name MapEditor

signal editorExited()

@onready var eventListener: EditorEventListener = %EditorEventListener

func loadMap(filePath: String) -> bool:
	var success = eventListener.loadMap(filePath)
	return success
