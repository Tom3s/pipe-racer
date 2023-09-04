extends Control
class_name PropPropertiesUI

signal textureIndexChanged(index: int)

var textureSelector: ItemList

func _ready():
	textureSelector = %TextureSelector

	textureSelector.select(0)
	textureIndexChanged.emit(0)

	textureSelector.item_selected.connect(onTextureSelector_itemSelected)

func onTextureSelector_itemSelected(index: int):
	textureIndexChanged.emit(index)