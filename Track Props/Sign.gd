extends Node3D

var billboardMaterial := preload("res://Track Props/SignMaterial.tres")

@onready
var board: MeshInstance3D = %Board

var billboardTexture: Texture
	# set(newTexture):
	# 	billboardTexture = newTexture
	# 	%Board.set_surface_override_material(0, billboardMaterial.duplicate())
	# 	%Board.get_surface_override_material(0).set_shader_parameter("Texture", billboardTexture)
	# get:
	# 	return billboardTexture

var billboardTextureName: String = ""
var billboardTextureUrl: String = ""

func isProp():
	pass

func setTexture(texture: Texture, textureName: String, url: String = "") -> void:
	billboardTexture = texture
	billboardTextureName = textureName
	if url != "":
		billboardTextureUrl = url

	if is_node_ready():
		board.get_surface_override_material(0).set_shader_parameter("Texture", billboardTexture)
		if url != "" && textureName == "Custom":
			fetchImage(url)
	
	

func _ready():
	print(self)
	var newScale = Vector3.ONE * 8.5
	%Collider1.scale = newScale
	%Collider2.scale = newScale
	%Frame.scale = newScale
	%Board.scale = newScale


	var newMaterial = billboardMaterial.duplicate()
	newMaterial.set_shader_parameter("Texture", billboardTexture)
	board.set_surface_override_material(0, newMaterial)

	if billboardTextureUrl != "" && billboardTextureName == "Custom":
		fetchImage(billboardTextureUrl)

	print("Prop ready")


func fetchImage(imageUrl: String) -> void:
	if !is_node_ready():
		return
	var httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.timeout = 60
	httpRequest.request_completed.connect(onLoadTexture_RequestCompleted)

	var httpError = httpRequest.request(imageUrl)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onLoadTexture_RequestCompleted(_result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	var image = Image.new()
	var imageError = image.load_jpg_from_buffer(body)
	if imageError != OK:
		print("Error loading jpg: " + error_string(imageError))
		print("Trying PNG...")
		imageError = image.load_png_from_buffer(body)
		if imageError != OK:
			print("Error loading png: " + error_string(imageError))
			return
	# 	else:
	# 		print("PNG loaded successfully")
	# else:
	# 	print("JPG loaded successfully")

	print("Setting custom billboard texture")

	var texture = ImageTexture.create_from_image(image)
	setTexture(texture, billboardTextureName, "")