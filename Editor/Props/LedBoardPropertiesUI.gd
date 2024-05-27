extends Control
class_name LedBoardPropertiesUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var widthSpinbox: SpinBox = %WidthSpinbox
@onready var heightSpinbox: SpinBox = %HeightSpinbox

@onready var supportToggle: CheckButton = %SupportToggle
@onready var supportBottomHeightSpinbox: SpinBox = %SupportBottomHeightSpinbox

@onready var customTextureToggle: CheckButton = %CustomTextureToggle

@onready var localTextureContainer: BoxContainer = %LocalTextureContainer
@onready var localTextureOptions: OptionButton = %LocalTextureOptions

@onready var customTextureContainer: BoxContainer = %CustomTextureContainer
@onready var customTextureLineEdit: LineEdit = %CustomTextureLineEdit

@onready var posXSpinbox: SpinBox = %PosXSpinbox
@onready var posYSpinbox: SpinBox = %PosYSpinbox
@onready var posZSpinbox: SpinBox = %PosZSpinbox

@onready var rotXSpinbox: SpinBox = %RotXSpinbox
@onready var rotYSpinbox: SpinBox = %RotYSpinbox
@onready var rotZSpinbox: SpinBox = %RotZSpinbox

@onready var visibilityButton: Button = %VisibilityButton


# out signals
signal widthChanged(width: float)
signal heightChanged(height: float)

signal supportChanged(support: bool)
signal supportBottomHeightChanged(height: float)

signal customTextureChanged(custom: bool)

signal localTextureChanged(texture: String)
signal customTextureUrlChanged(url: String)


signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)

# in setters

func setWidth(newWidth: float) -> void:
	widthSpinbox.set_value_no_signal(newWidth)

func setHeight(newHeight: float) -> void:
	heightSpinbox.set_value_no_signal(newHeight)

func setSupport(newSupport: bool) -> void:
	supportToggle.button_pressed = newSupport

func setSupportBottomHeight(newHeight: float) -> void:
	supportBottomHeightSpinbox.set_value_no_signal(newHeight)

func setCustomTexture(newCustom: bool) -> void:
	customTextureToggle.button_pressed = newCustom

func setLocalTexture(newTexture: String) -> void:
	localTextureOptions.select(TextureLoader.billboardTextureIndices[newTexture])
	pass

func setCustomTextureUrl(newUrl: String) -> void:
	customTextureLineEdit.text = newUrl

func setPosition(newPosition: Vector3) -> void:
	posXSpinbox.set_value_no_signal(newPosition.x)
	posYSpinbox.set_value_no_signal(newPosition.y)
	posZSpinbox.set_value_no_signal(newPosition.z)

func setRotation(newRotation: Vector3) -> void:
	rotXSpinbox.set_value_no_signal(newRotation.x)
	rotYSpinbox.set_value_no_signal(newRotation.y)
	rotZSpinbox.set_value_no_signal(newRotation.z)



func _ready():
	rotXSpinbox.step = deg_to_rad(5)
	rotYSpinbox.step = deg_to_rad(5)
	rotZSpinbox.step = deg_to_rad(5)

	rotXSpinbox.custom_arrow_step = deg_to_rad(5)
	rotYSpinbox.custom_arrow_step = deg_to_rad(5)
	rotZSpinbox.custom_arrow_step = deg_to_rad(5)

	connectSignals()

	localTextureContainer.visible = true
	customTextureContainer.visible = false

	fillTextureOptions()

func connectSignals():
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v LED Board" if visibilityButton.button_pressed else "^ LED Board"
	)

	widthSpinbox.value_changed.connect(func(value: float):
		widthChanged.emit(value)
	)

	heightSpinbox.value_changed.connect(func(value: float):
		heightChanged.emit(value)
	)

	supportToggle.toggled.connect(func(value: bool):
		supportChanged.emit(value)
	)

	supportBottomHeightSpinbox.value_changed.connect(func(value: float):
		supportBottomHeightChanged.emit(value)
	)

	customTextureToggle.toggled.connect(func(value: bool):
		localTextureContainer.visible = !value
		customTextureContainer.visible = value
		customTextureChanged.emit(value)
	)

	localTextureOptions.item_selected.connect(func(index: int):
		localTextureChanged.emit(localTextureOptions.get_item_text(index))
	)

	customTextureLineEdit.text_submitted.connect(func(text: String):
		customTextureUrlChanged.emit(text)
	)

	posXSpinbox.value_changed.connect(func(value: float):
		positionChanged.emit(Vector3(value, posYSpinbox.value, posZSpinbox.value))
	)

	posYSpinbox.value_changed.connect(func(value: float):
		positionChanged.emit(Vector3(posXSpinbox.value, value, posZSpinbox.value))
	)

	posZSpinbox.value_changed.connect(func(value: float):
		positionChanged.emit(Vector3(posXSpinbox.value, posYSpinbox.value, value))
	)

	rotXSpinbox.value_changed.connect(func(value: float):
		rotationChanged.emit(Vector3(value, rotYSpinbox.value, rotZSpinbox.value))
	)

	rotYSpinbox.value_changed.connect(func(value: float):
		rotationChanged.emit(Vector3(rotXSpinbox.value, value, rotZSpinbox.value))
	)

	rotZSpinbox.value_changed.connect(func(value: float):
		rotationChanged.emit(Vector3(rotXSpinbox.value, rotYSpinbox.value, value))
	)

func fillTextureOptions() -> void:
	localTextureOptions.clear()

	for key in TextureLoader.billboardTextures.keys():
		localTextureOptions.add_icon_item(TextureLoader.billboardTextures[key], key)
	
	localTextureOptions.select(TextureLoader.defaultBillboardTextureIndex)

	var popup: PopupMenu = localTextureOptions.get_popup()
	for i in TextureLoader.billboardTextures.size():
		popup.set_item_icon_max_width(i, 148)



	
func getProperties() -> Dictionary:
	var properties =  {
		"width": widthSpinbox.value,
		"height": heightSpinbox.value,
		"support": supportToggle.button_pressed,
		"supportBottomHeight": supportBottomHeightSpinbox.value,

		"usingOnlineTexture": customTextureToggle.button_pressed,

		"position": Vector3(posXSpinbox.value, posYSpinbox.value, posZSpinbox.value),
		"rotation": Vector3(rotXSpinbox.value, rotYSpinbox.value, rotZSpinbox.value)
	}

	if customTextureToggle.button_pressed:
		properties["customTextureUrl"] = customTextureLineEdit.text
	else:
		properties["textureName"] = localTextureOptions.get_item_text(localTextureOptions.selected)
	
	return properties

func setProperties(properties: Dictionary) -> void:
	if properties.has("width"):
		setWidth(properties["width"])
	if properties.has("height"):
		setHeight(properties["height"])
	if properties.has("support"):
		setSupport(properties["support"])
	if properties.has("supportBottomHeight"):
		setSupportBottomHeight(properties["supportBottomHeight"])
	
	if properties.has("usingOnlineTexture"):
		setCustomTexture(properties["usingOnlineTexture"])
	if properties.has("customTextureUrl"):
		setCustomTextureUrl(properties["customTextureUrl"])
	if properties.has("textureName"):
		setLocalTexture(properties["textureName"])


	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])
