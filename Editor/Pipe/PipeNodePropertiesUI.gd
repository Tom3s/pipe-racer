extends Control
class_name PipeNodePropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var radiusSpinbox: SpinBox = %RadiusSpinbox
@onready var profileSpinbox: SpinBox = %ProfileSpinbox
@onready var flatToggle: CheckButton = %FlatToggle

@onready var posXSpinbox: SpinBox = %PosXSpinbox
@onready var posYSpinbox: SpinBox = %PosYSpinbox
@onready var posZSpinbox: SpinBox = %PosZSpinbox

@onready var rotXSpinbox: SpinBox = %RotXSpinbox
@onready var rotYSpinbox: SpinBox = %RotYSpinbox
@onready var rotZSpinbox: SpinBox = %RotZSpinbox

@onready var visibilityButton: Button = %VisibilityButton


# out signals
signal radiusChanged(radius: float)
signal profileChanged(profile: float)
signal flatChanged(flat: bool)

signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)

# in setters

func setRadius(newRadius: float) -> void:
	radiusSpinbox.set_value_no_signal(newRadius)

func setProfile(newProfile: float) -> void:
	profileSpinbox.set_value_no_signal(rad_to_deg(newProfile))

func setFlat(newFlat: bool) -> void:
	flatToggle.button_pressed = newFlat

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

	

