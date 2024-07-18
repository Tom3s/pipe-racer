extends Node

var billboardTextures: Dictionary = {}
var billboardTextureIndices: Dictionary = {}
var defaultBillboardTextureIndex: int = 0

var propTextures: Dictionary = {}
var propTextureIndices: Dictionary = {}
var defaultPropTextureIndex: int = 0

func _ready():
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
		print("[TextureLoader.gd] Texture already loaded: ", imageUrl)
		setTextureCallback.call(onlineTextures[imageUrl])
		return
	if pendingRequests.has(imageUrl):
		print("[TextureLoader.gd] Request already in progress: ", imageUrl)
		pendingRequests[imageUrl].append(setTextureCallback)
		return
	pendingRequests[imageUrl] = [setTextureCallback]
	var httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.timeout = 60
	httpRequest.request_completed.connect(func(_result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
		var image = Image.new()
		var imageError = image.load_jpg_from_buffer(body)
		print("[TextureLoader.gd] Trying JPG...")
		if imageError != OK:
			print("[TextureLoader.gd] Error loading jpg ", imageUrl, "\n", error_string(imageError))
			print("[TextureLoader.gd] Trying PNG...")
			imageError = image.load_png_from_buffer(body)
			if imageError != OK:
				print("[TextureLoader.gd] Error loading png: ", imageUrl, "\n", error_string(imageError))
				return

		var texture = ImageTexture.create_from_image(image)
		onlineTextures[imageUrl] = texture
		for callback in pendingRequests[imageUrl]:
			callback.call(texture)
		pendingRequests.erase(imageUrl)
	)

	var httpError = httpRequest.request(imageUrl)
	if httpError != OK:
		print("[TextureLoader.gd] Error sending request: " + error_string(httpError))
