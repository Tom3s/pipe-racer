extends Control
class_name PropPropertiesUI

signal textureChanged(fileName: String, url: String)

@onready var textureSelector: ItemList = %TextureSelector
@onready var imageUrl: TextEdit = %ImageUrl
@onready var applyButton: Button = %ApplyButton


func _ready():

	applyButton.disabled = true
	applyButton.visible = false
	imageUrl.visible = false


	textureSelector.item_selected.connect(onTextureSelector_itemSelected)
	applyButton.pressed.connect(onApplyButton_pressed)

	for key in BillboardTextureLoader.textures:
		textureSelector.add_item(
			key,
			BillboardTextureLoader.textures[key]
		)
	
	textureSelector.add_item("Custom")

	print("defaultTextureIndex ", BillboardTextureLoader.defaultTextureIndex)
	textureSelector.select(BillboardTextureLoader.defaultTextureIndex)
	textureChanged.emit("PipeRacerLanguages", "")

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

	textureChanged.emit(
		textureSelector.get_item_text(index), ""
	)

func onApplyButton_pressed():
	var url = imageUrl.text

	textureChanged.emit("Custom", url)

