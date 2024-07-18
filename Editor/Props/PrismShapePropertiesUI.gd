extends Control
class_name PrismShapePropertiesUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var surfaceOptions: OptionButton = %SurfaceOptions

@onready var widthSpinbox: SpinBox = %WidthSpinbox
@onready var heightSpinbox: SpinBox = %HeightSpinbox
@onready var depthSpinbox: SpinBox = %DepthSpinbox

@onready var sideSpinbox: SpinBox = %SideSpinbox

@onready var pointyToggle: CheckButton = %PointyToggle
@onready var sharpToggle: CheckButton = %SharpToggle

@onready var textureVisibilityButton: Button = %TextureVisibilityButton

@onready var textureOptionsContainer: Control = %TextureOptionsContainer
@onready var textureUrlsContainer: Control = %TextureUrlsContainer

@onready var topTextureOptions: OptionButton = %TopTextureOptions
@onready var sideTextureOptions: OptionButton = %SideTextureOptions
@onready var bottomTextureOptions: OptionButton = %BottomTextureOptions

@onready var topTextureLineEdit: LineEdit = %TopTextureLineEdit
@onready var sideTextureLineEdit: LineEdit = %SideTextureLineEdit
@onready var bottomTextureLineEdit: LineEdit = %BottomTextureLineEdit

@onready var onlineTextureToggle: CheckButton = %OnlineTextureToggle

@onready var posXSpinbox: SpinBox = %PosXSpinbox
@onready var posYSpinbox: SpinBox = %PosYSpinbox
@onready var posZSpinbox: SpinBox = %PosZSpinbox

@onready var rotXSpinbox: SpinBox = %RotXSpinbox
@onready var rotYSpinbox: SpinBox = %RotYSpinbox
@onready var rotZSpinbox: SpinBox = %RotZSpinbox

@onready var visibilityButton: Button = %VisibilityButton

# out signals
signal surfaceChanged(surface: int)

signal widthChanged(width: float)
signal heightChanged(height: float)
signal depthChanged(depth: float)

signal sideChanged(side: float)

signal pointyChanged(pointy: bool)
signal sharpChanged(sharp: bool)

signal useOnlineTexturesChanged(useOnlineTextures: bool)

signal topTextureChanged(texture: String)
signal sideTextureChanged(texture: String)
signal bottomTextureChanged(texture: String)

signal topTextureUrlChanged(url: String)
signal sideTextureUrlChanged(url: String)
signal bottomTextureUrlChanged(url: String)

signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)

# in setters

func setSurface(surface: int) -> void:
	surfaceOptions.selected = surface

func setWidth(newWidth: float) -> void:
	widthSpinbox.set_value_no_signal(newWidth)

func setHeight(newHeight: float) -> void:
	heightSpinbox.set_value_no_signal(newHeight)

func setDepth(newDepth: float) -> void:
	depthSpinbox.set_value_no_signal(newDepth)

func setSide(newSide: float) -> void:
	sideSpinbox.set_value_no_signal(newSide)

func setPointy(newPointy: bool) -> void:
	pointyToggle.button_pressed = newPointy

func setSharp(newSharp: bool) -> void:
	sharpToggle.button_pressed = newSharp

func setUseOnlineTextures(newUseOnlineTextures: bool) -> void:
	onlineTextureToggle.button_pressed = newUseOnlineTextures

func setTopTexture(newTexture: String) -> void:
	topTextureOptions.select(TextureLoader.propTextureIndices[newTexture])

func setSideTexture(newTexture: String) -> void:
	sideTextureOptions.select(TextureLoader.propTextureIndices[newTexture])

func setBottomTexture(newTexture: String) -> void:
	bottomTextureOptions.select(TextureLoader.propTextureIndices[newTexture])

func setTopTextureUrl(newUrl: String) -> void:
	topTextureLineEdit.text = newUrl

func setSideTextureUrl(newUrl: String) -> void:
	sideTextureLineEdit.text = newUrl

func setBottomTextureUrl(newUrl: String) -> void:
	bottomTextureLineEdit.text = newUrl

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

	setupSurfaceOptions()

	connectSignals()

	# localTextureContainer.visible = true
	# customTextureContainer.visible = false
	textureOptionsContainer.visible = false
	textureUrlsContainer.visible = false

	fillTextureOptions()

func connectSignals():
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Prism Shape" if visibilityButton.button_pressed else "^ Prism Shape"
	)

	surfaceOptions.item_selected.connect(func(index: int):
		surfaceChanged.emit(index)
	)

	widthSpinbox.value_changed.connect(func(value: float):
		widthChanged.emit(value)
	)

	heightSpinbox.value_changed.connect(func(value: float):
		heightChanged.emit(value)
	)

	depthSpinbox.value_changed.connect(func(value: float):
		depthChanged.emit(value)
	)

	sideSpinbox.value_changed.connect(func(value: float):
		sideChanged.emit(value)
	)

	pointyToggle.toggled.connect(func(button_pressed: bool):
		pointyChanged.emit(button_pressed)
	)

	sharpToggle.toggled.connect(func(button_pressed: bool):
		sharpChanged.emit(button_pressed)
	)

	onlineTextureToggle.toggled.connect(func(button_pressed: bool):
		textureOptionsContainer.visible = !button_pressed && textureVisibilityButton.button_pressed
		textureUrlsContainer.visible = button_pressed && textureVisibilityButton.button_pressed
		useOnlineTexturesChanged.emit(button_pressed)
	)

	textureVisibilityButton.pressed.connect(func():
		textureOptionsContainer.visible = textureVisibilityButton.button_pressed && !onlineTextureToggle.button_pressed
		textureUrlsContainer.visible = textureVisibilityButton.button_pressed && onlineTextureToggle.button_pressed
	)

	topTextureOptions.item_selected.connect(func(index: int):
		topTextureChanged.emit(topTextureOptions.get_item_text(index))
	)

	sideTextureOptions.item_selected.connect(func(index: int):
		sideTextureChanged.emit(sideTextureOptions.get_item_text(index))
	)

	bottomTextureOptions.item_selected.connect(func(index: int):
		bottomTextureChanged.emit(bottomTextureOptions.get_item_text(index))
	)

	topTextureLineEdit.text_submitted.connect(func(text: String):
		topTextureUrlChanged.emit(text)
	)

	sideTextureLineEdit.text_submitted.connect(func(text: String):
		sideTextureUrlChanged.emit(text)
	)

	bottomTextureLineEdit.text_submitted.connect(func(text: String):
		bottomTextureUrlChanged.emit(text)
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
	
func setupSurfaceOptions() -> void:
	
	surfaceOptions.clear()

	for surfaceType in PhysicsSurface.SurfaceType.keys():
		surfaceOptions.add_item(surfaceType.capitalize())

	surfaceOptions.selected = 0

func fillTextureOptions():
	topTextureOptions.clear()
	sideTextureOptions.clear()
	bottomTextureOptions.clear()

	for key in TextureLoader.propTextures.keys():
		topTextureOptions.add_icon_item(TextureLoader.propTextures[key], key)
		sideTextureOptions.add_icon_item(TextureLoader.propTextures[key], key)
		bottomTextureOptions.add_icon_item(TextureLoader.propTextures[key], key)
	
	topTextureOptions.select(TextureLoader.defaultPropTextureIndex)
	sideTextureOptions.select(TextureLoader.defaultPropTextureIndex)
	bottomTextureOptions.select(TextureLoader.defaultPropTextureIndex)

	var popup1: PopupMenu = topTextureOptions.get_popup()
	var popup2: PopupMenu = sideTextureOptions.get_popup()
	var popup3: PopupMenu = bottomTextureOptions.get_popup()
	for i in TextureLoader.propTextures.size():
		popup1.set_item_icon_max_width(i, 96)
		popup2.set_item_icon_max_width(i, 96)
		popup3.set_item_icon_max_width(i, 96)

func getProperties() -> Dictionary:
	var properties := {
		"width": widthSpinbox.value,
		"height": heightSpinbox.value,
		"depth": depthSpinbox.value,
		
		"sides": sideSpinbox.value,

		"pointy": pointyToggle.button_pressed,
		"sharp": sharpToggle.button_pressed,

		"usingOnlineTextures": onlineTextureToggle.button_pressed,

		"position": Vector3(posXSpinbox.value, posYSpinbox.value, posZSpinbox.value),
		"rotation": Vector3(rotXSpinbox.value, rotYSpinbox.value, rotZSpinbox.value)
	}

	if onlineTextureToggle.button_pressed:
		properties["topTextureUrl"] = topTextureLineEdit.text
		properties["sideTextureUrl"] = sideTextureLineEdit.text
		properties["bottomTextureUrl"] = bottomTextureLineEdit.text
	else:
		properties["topTextureName"] = topTextureOptions.get_item_text(topTextureOptions.selected)
		properties["sideTextureName"] = sideTextureOptions.get_item_text(sideTextureOptions.selected)
		properties["bottomTextureName"] = bottomTextureOptions.get_item_text(bottomTextureOptions.selected)
	
	return properties

func setProperties(properties: Dictionary) -> void:
	if properties.has("width"):
		setWidth(properties["width"])
	if properties.has("height"):
		setHeight(properties["height"])
	if properties.has("depth"):
		setDepth(properties["depth"])
	
	if properties.has("sides"):
		setSide(properties["sides"])
	
	if properties.has("pointy"):
		setPointy(properties["pointy"])
	if properties.has("sharp"):
		setSharp(properties["sharp"])
	
	if properties.has("usingOnlineTextures"):
		setUseOnlineTextures(properties["usingOnlineTextures"])
	if properties.has("topTextureName"):
		setTopTexture(properties["topTextureName"])
	if properties.has("sideTextureName"):
		setSideTexture(properties["sideTextureName"])
	if properties.has("bottomTextureName"):
		setBottomTexture(properties["bottomTextureName"])
	if properties.has("topTextureUrl"):
		setTopTextureUrl(properties["topTextureUrl"])
	if properties.has("sideTextureUrl"):
		setSideTextureUrl(properties["sideTextureUrl"])
	if properties.has("bottomTextureUrl"):
		setBottomTextureUrl(properties["bottomTextureUrl"])
	
	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])

