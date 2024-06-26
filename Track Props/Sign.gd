extends Node3D

var billboardTexture: Texture

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
		# board.get_surface_override_material(0).set_shader_parameter("Texture", billboardTexture)
		%LedBoard.setTexture(billboardTexture)
		if url != "" && textureName == "Custom":
			TextureLoader.loadOnlineTexture(
			url,
			func(image):
				setTexture(image, billboardTextureName, "")
		)
	
	

func _ready():
	# var newMaterial = billboardMaterial.duplicate()
	# newMaterial.set_shader_parameter("Texture", billboardTexture)
	# board.set_surface_override_material(0, newMaterial)
	%LedBoard.setTexture(billboardTexture)

	if billboardTextureUrl != "" && billboardTextureName == "Custom":
		# fetchImage(billboardTextureUrl)
		TextureLoader.loadOnlineTexture(
			billboardTextureUrl,
			func(texture):
				setTexture(texture, billboardTextureName, "")
		)

	print("Prop ready")
