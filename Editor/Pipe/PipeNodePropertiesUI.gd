extends Control
class_name PipeNodePropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var radiusSpinbox: SpinBox = %RadiusSpinbox
@onready var profileSpinbox: SpinBox = %ProfileSpinbox
@onready var flatToggle: CheckButton = %FlatToggle

@onready var gizmo_control_ui: GizmoControlUI = %GizmoControlUI

@onready var visibilityButton: Button = %VisibilityButton


# out signals
signal radiusChanged(radius: float)
signal profileChanged(profile: float)
signal flatChanged(flat: bool)

# in setters

func setRadius(newRadius: float) -> void:
	radiusSpinbox.set_value_no_signal(newRadius)

func setProfile(newProfile: float) -> void:
	profileSpinbox.set_value_no_signal(rad_to_deg(newProfile))

func setFlat(newFlat: bool) -> void:
	flatToggle.button_pressed = newFlat

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
		visibilityButton.text = "v Pipe Node" if visibilityButton.button_pressed else "^ Pipe Node"
	)

	radiusSpinbox.value_changed.connect(func(value: float):
		radiusChanged.emit(value)
	)

	profileSpinbox.value_changed.connect(func(value: float):
		profileChanged.emit(deg_to_rad(value))
	)

	flatToggle.toggled.connect(func(value: bool):
		flatChanged.emit(value)
	)


	
func getProperties() -> Dictionary:
	return {
		"radius": radiusSpinbox.value,
		"profile": deg_to_rad(profileSpinbox.value),
		"flat": flatToggle.button_pressed,

		"position": gizmo_control_ui.get_position_vec3(),
		"rotation": gizmo_control_ui.get_rotation_vec3()
	}

func setProperties(properties: Dictionary) -> void:
	if properties.has("radius"):
		setRadius(properties["radius"])
	if properties.has("profile"):
		setProfile(properties["profile"])
	if properties.has("flat"):
		setFlat(properties["flat"])

	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])
