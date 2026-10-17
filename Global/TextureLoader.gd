extends Node

var billboardTextures: Dictionary = {}
var billboardTextureIndices: Dictionary = {}
var defaultBillboardTextureIndex: int = 0

var propTextures: Dictionary = {}
var propTextureIndices: Dictionary = {}
var defaultPropTextureIndex: int = 0

const ONLINE_TEXTURE_PATH: String = "user://online_textures"

func _ready():
	var dir = DirAccess.open("user://")
	if !dir.dir_exists(ONLINE_TEXTURE_PATH):
		dir.make_dir(ONLINE_TEXTURE_PATH)



	loadBillboardTextures()
	loadPropTextures()

func loadBillboardTextures() -> void:
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

			billboardTextureIndices[textureFileName] = index

			if textureFileName == "PipeRacerLanguages":
				defaultBillboardTextureIndex = index

			billboardTextures[textureFileName] = texture

			file_name = directory.get_next()
			index += 1

func loadPropTextures() -> void:
	var path = "res://Editor/PropTextures/"
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

			propTextureIndices[textureFileName] = index

			if textureFileName == "Ice":
				defaultPropTextureIndex = index

			propTextures[textureFileName] = texture

			file_name = directory.get_next()
			index += 1

var onlineTextures: Dictionary = {}
var pendingRequests: Dictionary = {}

func loadOnlineTexture(imageUrl: String, setTextureCallback: Callable) -> void:
	if !is_node_ready():
		return
	if onlineTextures.has(imageUrl):
		MogyiLogger.log(self, "Texture already loaded in memory: %s" % imageUrl, MogyiLogger.Severity.WARNING)
		setTextureCallback.call(onlineTextures[imageUrl])
		return
	if load_cached_texture(imageUrl):
		setTextureCallback.call(onlineTextures[imageUrl])
		return
	if pendingRequests.has(imageUrl):
		MogyiLogger.log(self, "Request already in progress: %s" % imageUrl, MogyiLogger.Severity.WARNING)
		pendingRequests[imageUrl].append(setTextureCallback)
		return
	pendingRequests[imageUrl] = [setTextureCallback]
	var httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.timeout = 60
	httpRequest.request_completed.connect(func(_result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
		var image = Image.new()
		var imageError = image.load_jpg_from_buffer(body)
		MogyiLogger.log(self, "Trying JPG...")
		if imageError != OK:
			MogyiLogger.log(self, "Error loading jpg %s - %s" % [imageUrl, error_string(imageError)], MogyiLogger.Severity.WARNING)
			MogyiLogger.log(self, "Trying PNG...")
			imageError = image.load_png_from_buffer(body)
			if imageError != OK:
				MogyiLogger.log(self, "Error loading png: %s - %s" % [imageUrl, error_string(imageError)], MogyiLogger.Severity.WARNING)
				MogyiLogger.log(self, "Trying WEBP...")	
				imageError = image.load_webp_from_buffer(body)
				if imageError != OK:
					MogyiLogger.log(self, "Error loading WEBP: %s - %s" % [imageUrl, error_string(imageError)], MogyiLogger.Severity.ERROR)
					return

		cache_online_texture(imageUrl, image)

		var texture = ImageTexture.create_from_image(image)
		onlineTextures[imageUrl] = texture
		for callback in pendingRequests[imageUrl]:
			callback.call(texture)
		pendingRequests.erase(imageUrl)
	)

	var httpError = httpRequest.request(imageUrl)
	if httpError != OK:
		MogyiLogger.log(self, "Error sending request: %s" % error_string(httpError))

func cache_online_texture(url: String, texture: Image) -> void:
	var texture_path: String = "%s/%s.png" % [ONLINE_TEXTURE_PATH, url.md5_text()]

	texture.save_png(texture_path)

	MogyiLogger.log(self, "Cached image (%s) to %s" % [url, texture_path])

func load_cached_texture(url: String) -> bool:
	var texture_path: String = "%s/%s.png" % [ONLINE_TEXTURE_PATH, url.md5_text()]

	if FileAccess.file_exists(texture_path):
		MogyiLogger.log(self, "Image %s is already cached. Loading from %s" % [url, texture_path])

		var img := Image.load_from_file(texture_path)
		var texture := ImageTexture.create_from_image(img)
		onlineTextures[url] = texture
		return true
	else:
		MogyiLogger.log(self, "Image %s is not cached. Needs downloading" % url)
		return false
	
func clear_cached_images() -> void:
	MogyiLogger.log(self, "Clearing cached textures...")
	for file in DirAccess.get_files_at(ONLINE_TEXTURE_PATH):  
		DirAccess.remove_absolute(ONLINE_TEXTURE_PATH + "/" + file)
	
func get_cached_texture_size() -> float:
	var folder_size: float = 0.0
	var dir: DirAccess = DirAccess.open(ONLINE_TEXTURE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if !file_name.ends_with(".png"): 
				file_name = dir.get_next()
				continue
			
			var full_path := "%s/%s" % [ONLINE_TEXTURE_PATH, file_name]
			folder_size += FileAccess.get_size(full_path)

			file_name = dir.get_next()
	
	MogyiLogger.log(self, "Total size of cached textures: %.2f MB" % (folder_size / 1024.0 / 1024.0))

	return folder_size / 1024.0 / 1024.0