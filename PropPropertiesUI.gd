extends Control
class_name PropPropertiesUI

signal textureIndexChanged(index: int, url: String)

@onready var textureSelector: ItemList = %TextureSelector
@onready var imageUrl: TextEdit = %ImageUrl
@onready var applyButton: Button = %ApplyButton


func _ready():
	textureSelector.select(0)
	textureIndexChanged.emit(0)

	applyButton.disabled = true
	applyButton.visible = false
	imageUrl.visible = false


	textureSelector.item_selected.connect(onTextureSelector_itemSelected)
	applyButton.pressed.connect(onApplyButton_pressed)

func onTextureSelector_itemSelected(index: int):
	if index == textureSelector.item_count - 1:
		imageUrl.visible = true
		applyButton.disabled = false
		applyButton.visible = true
		return
	else:
		imageUrl.visible = false
		applyButton.disabled = true
		applyButton.visible = false

	textureIndexChanged.emit(index, "")

func onApplyButton_pressed():
	var url = imageUrl.text

	textureIndexChanged.emit(-2, url)

