extends Control
class_name CheckpointPropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var radiusSpinbox: SpinBox = %RadiusSpinbox
@onready var ringWidthSpinbox: SpinBox = %RingWidthSpinbox

@onready var posXSpinbox: SpinBox = %PosXSpinbox
@onready var posYSpinbox: SpinBox = %PosYSpinbox
@onready var posZSpinbox: SpinBox = %PosZSpinbox

@onready var rotXSpinbox: SpinBox = %RotXSpinbox
@onready var rotYSpinbox: SpinBox = %RotYSpinbox
@onready var rotZSpinbox: SpinBox = %RotZSpinbox

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
		visibilityButton.text = "v Checkpoint" if visibilityButton.button_pressed else "^ Checkpoint"
	)

	radiusSpinbox.value_changed.connect(func(value: float):
		radiusChanged.emit(value)
	)

	ringWidthSpinbox.value_changed.connect(func(value: float):
		ringWidthChanged.emit(value)
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
	return {
		"ringRadius": radiusSpinbox.value,
		"ringWidth": ringWidthSpinbox.value,

		"position": Vector3(posXSpinbox.value, posYSpinbox.value, posZSpinbox.value),
		"rotation": Vector3(rotXSpinbox.value, rotYSpinbox.value, rotZSpinbox.value)
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
