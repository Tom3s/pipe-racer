extends Control
class_name StartLinePropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var widthSpinbox: SpinBox = %WidthSpinbox
@onready var heightSpinbox: SpinBox = %HeightSpinbox

@onready var gizmo_control_ui: GizmoControlUI = %GizmoControlUI

@onready var visibilityButton: Button = %VisibilityButton


# out signals
signal widthChanged(width: float)
signal heightChanged(height: float)
signal flatChanged(flat: bool)


# in setters

func setWidth(newWidth: float) -> void:
	widthSpinbox.set_value_no_signal(newWidth)

func setHeight(newHeight: float) -> void:
	heightSpinbox.set_value_no_signal(newHeight)

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

func connectSignals():
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Start" if visibilityButton.button_pressed else "^ Start"
	)

	widthSpinbox.value_changed.connect(func(value: float):
		widthChanged.emit(value)
	)

	heightSpinbox.value_changed.connect(func(value: float):
		heightChanged.emit(value)
	)

	
func getProperties() -> Dictionary:
	return {
		"width": widthSpinbox.value,
		"height": deg_to_rad(heightSpinbox.value),

		"position": gizmo_control_ui.get_position_vec3(),
		"rotation": gizmo_control_ui.get_rotation_vec3()
	}

func setProperties(properties: Dictionary) -> void:
	if properties.has("width"):
		setWidth(properties["width"])
	if properties.has("height"):
		setHeight(properties["height"])

	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])
