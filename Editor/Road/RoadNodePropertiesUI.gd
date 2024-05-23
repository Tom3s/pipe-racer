extends Control
class_name RoadNodePropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var roadProfileOptions: OptionButton = %RoadProfileOptions

@onready var profileHeightSpinbox: SpinBox = %ProfileHeightSpinbox
@onready var widthSpinbox: SpinBox = %WidthSpinbox
@onready var leftRunoffSpinbox: SpinBox = %LeftRunoffSpinbox
@onready var rightRunoffSpinbox: SpinBox = %RightRunoffSpinbox

@onready var posXSpinbox: SpinBox = %PosXSpinbox
@onready var posYSpinbox: SpinBox = %PosYSpinbox
@onready var posZSpinbox: SpinBox = %PosZSpinbox

@onready var rotXSpinbox: SpinBox = %RotXSpinbox
@onready var rotYSpinbox: SpinBox = %RotYSpinbox
@onready var rotZSpinbox: SpinBox = %RotZSpinbox

@onready var visibilityButton: Button = %VisibilityButton


# out signals
signal roadProfileChanged(profile: int)

signal profileHeightChanged(height: float)
signal widthChanged(width: float)
signal leftRunoffChanged(runoff: float)
signal rightRunoffChanged(runoff: float)

signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)

# in setters

func setRoadProfile(profile: int) -> void:
	roadProfileOptions.selected = profile

func setProfileHeight(height: float) -> void:
	profileHeightSpinbox.set_value_no_signal(height)

func setWidth(width: float) -> void:
	widthSpinbox.set_value_no_signal(width)

func setLeftRunoff(runoff: float) -> void:
	leftRunoffSpinbox.set_value_no_signal(runoff)

func setRightRunoff(runoff: float) -> void:
	rightRunoffSpinbox.set_value_no_signal(runoff)

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

	roadProfileOptions.clear()
	for profile in RoadNode.RoadProfile.keys():
		roadProfileOptions.add_item(profile.capitalize())
	roadProfileOptions.selected = 0

	
	connectSignals()

func connectSignals():
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Road Node" if visibilityButton.button_pressed else "^ Road Node"
	)

	roadProfileOptions.item_selected.connect(func(index: int):
		roadProfileChanged.emit(index)
	)

	profileHeightSpinbox.value_changed.connect(func(value: float):
		profileHeightChanged.emit(value)
	)

	widthSpinbox.value_changed.connect(func(value: float):
		widthChanged.emit(value)
	)

	leftRunoffSpinbox.value_changed.connect(func(value: float):
		leftRunoffChanged.emit(value)
	)

	rightRunoffSpinbox.value_changed.connect(func(value: float):
		rightRunoffChanged.emit(value)
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
		"profileType": roadProfileOptions.selected,
		"profileHeight": profileHeightSpinbox.value,
		"width": widthSpinbox.value,

		"leftRunoff": leftRunoffSpinbox.value,
		"rightRunoff": rightRunoffSpinbox.value,

		"position": Vector3(posXSpinbox.value, posYSpinbox.value, posZSpinbox.value),
		"rotation": Vector3(rotXSpinbox.value, rotYSpinbox.value, rotZSpinbox.value)
	}

func setProperties(properties: Dictionary) -> void:
	if properties.has("profileType"):
		setRoadProfile(properties["profileType"])
	if properties.has("profileHeight"):
		setProfileHeight(properties["profileHeight"])
	if properties.has("width"):
		setWidth(properties["width"])

	if properties.has("leftRunoff"):
		setLeftRunoff(properties["leftRunoff"])
	if properties.has("rightRunoff"):
		setRightRunoff(properties["rightRunoff"])

	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])