extends Control
class_name RoadNodePropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var roadProfileOptions: OptionButton = %RoadProfileOptions

@onready var profileHeightSpinbox: SpinBox = %ProfileHeightSpinbox
@onready var widthSpinbox: SpinBox = %WidthSpinbox
@onready var leftRunoffSpinbox: SpinBox = %LeftRunoffSpinbox
@onready var rightRunoffSpinbox: SpinBox = %RightRunoffSpinbox

@onready var gizmo_control_ui: GizmoControlUI = %GizmoControlUI

@onready var visibilityButton: Button = %VisibilityButton


# out signals
signal roadProfileChanged(profile: int)

signal profileHeightChanged(height: float)
signal widthChanged(width: float)
signal leftRunoffChanged(runoff: float)
signal rightRunoffChanged(runoff: float)

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
	gizmo_control_ui.posXSpinbox.set_value_no_signal(newPosition.x)
	gizmo_control_ui.posYSpinbox.set_value_no_signal(newPosition.y)
	gizmo_control_ui.posZSpinbox.set_value_no_signal(newPosition.z)

func setRotation(newRotation: Vector3) -> void:
	gizmo_control_ui.rotXSpinbox.set_value_no_signal(newRotation.x)
	gizmo_control_ui.rotYSpinbox.set_value_no_signal(newRotation.y)
	gizmo_control_ui.rotZSpinbox.set_value_no_signal(newRotation.z)



func _ready():
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




func getProperties() -> Dictionary:
	return {
		"profileType": roadProfileOptions.selected,
		"profileHeight": profileHeightSpinbox.value,
		"width": widthSpinbox.value,

		"leftRunoff": leftRunoffSpinbox.value,
		"rightRunoff": rightRunoffSpinbox.value,

		"position": gizmo_control_ui.get_position_vec3(),
		"rotation": gizmo_control_ui.get_rotation_vec3()
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