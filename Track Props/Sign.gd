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

var billboardTextureIndex: int = 0
var billboardTextureUrl: String = ""

func isProp():
	pass

func setTexture(texture: Texture, index: int, url: String = "none") -> void:
	billboardTexture = texture
	billboardTextureIndex = index
	if url != "none":
		billboardTextureUrl = url

	if is_node_ready():
		board.get_surface_override_material(0).set_shader_parameter("Texture", billboardTexture)
	
	if url != "" && index == -2:
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

	if billboardTextureUrl != "" && billboardTextureIndex == -2:
		fetchImage(billboardTextureUrl)

	print("Prop ready")


func fetchImage(imageUrl: String) -> void:
	var httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.request_completed.connect(onLoadTexture_RequestCompleted)

	var httpError = httpRequest.request(imageUrl)
	if httpError != OK:
		print("Error: " + str(httpError))

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
		else:
			print("PNG loaded successfully")
	else:
		print("JPG loaded successfully")

	var texture = ImageTexture.create_from_image(image)
	setTexture(texture, billboardTextureIndex, "none")