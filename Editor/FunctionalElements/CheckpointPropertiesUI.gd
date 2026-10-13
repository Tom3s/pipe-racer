extends Control
class_name CheckpointPropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var radiusSpinbox: SpinBox = %RadiusSpinbox
@onready var ringWidthSpinbox: SpinBox = %RingWidthSpinbox

@onready var gizmo_control_ui: GizmoControlUI = %GizmoControlUI

@onready var visibilityButton: Button = %VisibilityButton


# out signals
signal radiusChanged(radius: float)
signal ringWidthChanged(ringWidth: float)
signal flatChanged(flat: bool)

signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)

# in setters

func setRadius(newRadius: float) -> void:
	radiusSpinbox.set_value_no_signal(newRadius)

func setRingWidth(newRingWidth: float) -> void:
	ringWidthSpinbox.set_value_no_signal(newRingWidth)


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
		visibilityButton.text = "v Checkpoint" if visibilityButton.button_pressed else "^ Checkpoint"
	)

	radiusSpinbox.value_changed.connect(func(value: float):
		radiusChanged.emit(value)
	)

	ringWidthSpinbox.value_changed.connect(func(value: float):
		ringWidthChanged.emit(value)
	)

	
func getProperties() -> Dictionary:
	return {
		"ringRadius": radiusSpinbox.value,
		"ringWidth": ringWidthSpinbox.value,

		"position": gizmo_control_ui.get_position_vec3(),
		"rotation": gizmo_control_ui.get_rotation_vec3()
	}

func setProperties(properties: Dictionary) -> void:
	if properties.has("ringRadius"):
		setRadius(properties["ringRadius"])
	if properties.has("ringWidth"):
		setRingWidth(properties["ringWidth"])

	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])
