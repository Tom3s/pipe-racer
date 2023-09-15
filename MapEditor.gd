extends Node3D
class_name MapEditor

signal editorExited()

func loadMap(mapName: String):
	%Map.loadFrom = mapName
