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

func isProp():
	pass

func setTexture(texture: Texture, index: int) -> void:
	billboardTexture = texture
	billboardTextureIndex = index
	

func _ready():
	print(self)
	var newScale = Vector3.ONE * 8.5
	%Collider1.scale = newScale
	%Collider2.scale = newScale
	%Frame.scale = newScale
	%Board.scale = newScale


	board.set_surface_override_material(0, billboardMaterial.duplicate())
	# board.get_surface_override_material(0).set_shader_parameter("Texture", billboardTexture)

	print("Prop ready")
