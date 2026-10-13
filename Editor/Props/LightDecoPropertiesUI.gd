extends VBoxContainer
class_name LightDecoPropertiesUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var colorButton: ColorPickerButton = %ColorButton
@onready var spotToggle: CheckButton = %SpotToggle
@onready var omniSizeSpinbox: SpinBox = %OmniSizeSpinbox
@onready var spotlightSizeSpinbox: SpinBox = %SpotlightSizeSpinbox
@onready var spotlightAngleSpinbox: SpinBox = %SpotlightAngleSpinbox

@onready var gizmo_control_ui: GizmoControlUI = %GizmoControlUI

@onready var visibilityButton: Button = %VisibilityButton

# out signals
signal colorChanged(color: Color)

signal spotChanged(spot: bool)

signal omniSizeChanged(size: float)

signal spotlightSizeChanged(size: float)
signal spotlightAngleChanged(angle: float)

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
	gizmo_control_ui.posXSpinbox.set_value_no_signal(newPosition.x)
	gizmo_control_ui.posYSpinbox.set_value_no_signal(newPosition.y)
	gizmo_control_ui.posZSpinbox.set_value_no_signal(newPosition.z)

func setRotation(newRotation: Vector3) -> void:
	gizmo_control_ui.rotXSpinbox.set_value_no_signal(newRotation.x)
	gizmo_control_ui.rotYSpinbox.set_value_no_signal(newRotation.y)
	gizmo_control_ui.rotZSpinbox.set_value_no_signal(newRotation.z)

func _ready():
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

func getProperties() -> Dictionary:
	var properties = {
		"color": colorButton.color,

		"spot": spotToggle.button_pressed,

		"omniSize": omniSizeSpinbox.value,
		
		"spotlightSize": spotlightSizeSpinbox.value,
		"spotlightAngle": spotlightAngleSpinbox.value,
		
		"position": gizmo_control_ui.get_position_vec3(),
		"rotation": gizmo_control_ui.get_rotation_vec3()
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

