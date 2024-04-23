extends Node

var billboardTextures: Dictionary = {}
var defaultBillboardTextureIndex: int = 0

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

			if textureFileName == "PipeRacerLanguages":
				defaultBillboardTextureIndex = index

			billboardTextures[textureFileName] = texture

			file_name = directory.get_next()
			index += 1

var onlineTextures: Dictionary = {}

func loadOnlineTexture(imageUrl: String, setTextureCallback: Callable) -> void:
	if !is_node_ready():
		return
	if onlineTextures.has(imageUrl):
		print("[TextureLoader.gd] Texture already loaded: ", imageUrl)
		setTextureCallback.call(onlineTextures[imageUrl])
		return
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
		setTextureCallback.call(texture)
	)

	var httpError = httpRequest.request(imageUrl)
	if httpError != OK:
		print("[TextureLoader.gd] Error sending request: " + error_string(httpError))