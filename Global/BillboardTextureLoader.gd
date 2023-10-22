extends Node

var textures: Dictionary = {}
var defaultTextureIndex: int = 0

func _ready():
	var path = "res://BillboardTextures/"
	var directory = DirAccess.open(path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		var index = 0
		while file_name != "":
			# localTrackListItems.append(file_name.replace(path, ""))

			if file_name.ends_with(".png"):
				file_name = directory.get_next()
				continue

			var textureFileName = file_name.replace(path, "").replace(".png.import", "")
			var texture: Texture = ResourceLoader.load(path + file_name.replace(".import", ""))

			if textureFileName == "PipeRacerLanguages":
				defaultTextureIndex = index

			textures[textureFileName] = texture

			file_name = directory.get_next()
			index += 1
	
