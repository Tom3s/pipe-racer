extends VBoxContainer
class_name LightDecoPropertiesUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var colorButton: ColorPickerButton = %ColorButton
@onready var spotToggle: CheckButton = %SpotToggle
@onready var omniSizeSpinbox: SpinBox = %OmniSizeSpinbox
@onready var spotlightSizeSpinbox: SpinBox = %SpotlightSizeSpinbox
@onready var spotlightAngleSpinbox: SpinBox = %SpotlightAngleSpinbox

@onready var posXSpinbox: SpinBox = %PosXSpinbox
@onready var posYSpinbox: SpinBox = %PosYSpinbox
@onready var posZSpinbox: SpinBox = %PosZSpinbox

@onready var rotXSpinbox: SpinBox = %RotXSpinbox
@onready var rotYSpinbox: SpinBox = %RotYSpinbox
@onready var rotZSpinbox: SpinBox = %RotZSpinbox

@onready var visibilityButton: Button = %VisibilityButton

# out signals
signal colorChanged(color: Color)

signal spotChanged(spot: bool)

signal omniSizeChanged(size: float)

signal spotlightSizeChanged(size: float)
signal spotlightAngleChanged(angle: float)

signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)

# in setters
func setColor(newColor: Color) -> void:
	colorButton.color = newColor

func setSpot(newSpot: bool) -> void:
	spotToggle.button_pressed = newSpot

func setOmniSize(newSize: float) -> void:
	omniSizeSpinbox.set_value_no_signal(newSize)

func setSpotlightSize(newSize: float) -> void:
	spotlightSizeSpinbox.set_value_no_signal(newSize)

func setSpotlightAngle(newAngle: float) -> void:
	spotlightAngleSpinbox.set_value_no_signal(newAngle)

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

	omniSizeSpinbox.get_parent().visible = true
	spotlightSizeSpinbox.get_parent().visible = false
	spotlightAngleSpinbox.get_parent().visible = false

func connectSignals():
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Light" if visibilityButton.button_pressed else "^ Light"
	)

	colorButton.color_changed.connect(func(color: Color):
		colorChanged.emit(color)
	)

	spotToggle.toggled.connect(func(button_pressed: bool):
		omniSizeSpinbox.get_parent().visible = !button_pressed
		spotlightSizeSpinbox.get_parent().visible = button_pressed
		spotlightAngleSpinbox.get_parent().visible = button_pressed
		spotChanged.emit(button_pressed)
	)

	omniSizeSpinbox.value_changed.connect(func(value: float):
		omniSizeChanged.emit(value)
	)

	spotlightSizeSpinbox.value_changed.connect(func(value: float):
		spotlightSizeChanged.emit(value)
	)

	spotlightAngleSpinbox.value_changed.connect(func(value: float):
		spotlightAngleChanged.emit(value)
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

func getProperties() -> Dictionary:
	var properties = {
		"color": colorButton.color,

		"spot": spotToggle.button_pressed,

		"omniSize": omniSizeSpinbox.value,
		
		"spotlightSize": spotlightSizeSpinbox.value,
		"spotlightAngle": spotlightAngleSpinbox.value,
		
		"position": Vector3(posXSpinbox.value, posYSpinbox.value, posZSpinbox.value),
		"rotation": Vector3(rotXSpinbox.value, rotYSpinbox.value, rotZSpinbox.value),
	}

	return properties

func setProperties(properties: Dictionary) -> void:
	if properties.has("color"):
		colorButton.color = properties["color"]

	if properties.has("spot"):
		setSpot(properties["spot"])
	
	if properties.has("omniSize"):
		setOmniSize(properties["omniSize"])
	
	if properties.has("spotlightSize"):
		setSpotlightSize(properties["spotlightSize"])
	if properties.has("spotlightAngle"):
		setSpotlightAngle(properties["spotlightAngle"])
	
	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])

