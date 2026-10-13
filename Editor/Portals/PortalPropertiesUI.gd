extends VBoxContainer
class_name PortalPropertiesUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var self_id: Label = %SelfID
@onready var linked_id: Label = %LinkedID
@onready var linked_id_spinbox: SpinBox = %LinkedIDSpinbox
@onready var link_button: Button = %LinkButton
@onready var unlink_button: Button = %UnlinkButton

@onready var width_spinbox: SpinBox = %WidthSpinbox
@onready var height_spinbox: SpinBox = %HeightSpinbox
@onready var portal_color_button: ColorPickerButton = %PortalColorButton
@onready var frame_color_button: ColorPickerButton = %FrameColorButton
@onready var rust_color_button: ColorPickerButton = %RustColorButton
@onready var rust_strength_spinbox: SpinBox = %RustStrengthSpinbox
@onready var bottom_frame_toggle: CheckButton = %BottomFrameToggle

@onready var gizmo_control_ui: GizmoControlUI = %GizmoControlUI

@onready var visibilityButton: Button = %VisibilityButton

signal link_pressed(base_id: int, link_id: int)
signal unlink_pressed(id: int)

signal width_changed(width: int)
signal height_changed(height: int)
signal frame_color_changed(frame_color: Color)
signal rust_color_changed(rust_color: Color)
signal rust_strength_changed(rust_strength: float)
signal portal_color_changed(portal_color: Color)
signal use_bottom_frame_changed(use_bottom_frame: bool)

signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)

func set_id(id: int) -> void:
	self_id.text = str(id)

func set_linked_id(id: int) -> void:
	linked_id.text = str(id) if id != -1 else "None"
	linked_id_spinbox.value = id

func set_width(width: int) -> void:
	width_spinbox.set_value_no_signal(width)

func set_height(height: int) -> void:
	height_spinbox.set_value_no_signal(height)

func set_frame_color(frame_color: Color) -> void:
	frame_color_button.color = frame_color

func set_rust_color(rust_color: Color) -> void:
	rust_color_button.color = rust_color

func set_rust_strength(rust_strength: float) -> void:
	rust_strength_spinbox.set_value_no_signal(rust_strength)

func set_portal_color(portal_color: Color) -> void:
	portal_color_button.color = portal_color

func set_use_bottom_frame(use_bottom_frame: bool) -> void:
	bottom_frame_toggle.button_pressed = use_bottom_frame

func setPosition(newPosition: Vector3) -> void:
	gizmo_control_ui.posXSpinbox.set_value_no_signal(newPosition.x)
	gizmo_control_ui.posYSpinbox.set_value_no_signal(newPosition.y)
	gizmo_control_ui.posZSpinbox.set_value_no_signal(newPosition.z)

func setRotation(newRotation: Vector3) -> void:
	gizmo_control_ui.rotXSpinbox.set_value_no_signal(newRotation.x)
	gizmo_control_ui.rotYSpinbox.set_value_no_signal(newRotation.y)
	gizmo_control_ui.rotZSpinbox.set_value_no_signal(newRotation.z)

func _ready():
	connect_signals()

func connect_signals() -> void:
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Portal" if visibilityButton.button_pressed else "^ Portal"
	)

	link_button.pressed.connect(func():
		link_pressed.emit(int(self_id.text), linked_id_spinbox.value)
	)
	unlink_button.pressed.connect(func():
		unlink_pressed.emit(int(self_id.text))
	)

	width_spinbox.value_changed.connect(func(value: float) -> void:
		width_changed.emit(value)
	)
	height_spinbox.value_changed.connect(func(value: float) -> void:
		height_changed.emit(value)
	)
	rust_strength_spinbox.value_changed.connect(func(value: float) -> void:
		rust_strength_changed.emit(value)
	)

	portal_color_button.color_changed.connect(func(color: Color) -> void:
		portal_color_changed.emit(color)
	)
	frame_color_button.color_changed.connect(func(color: Color) -> void:
		frame_color_changed.emit(color)
	)
	rust_color_button.color_changed.connect(func(color: Color) -> void:
		rust_color_changed.emit(color)
	)
	
	bottom_frame_toggle.toggled.connect(func(button_pressed: bool):
		use_bottom_frame_changed.emit(button_pressed)
	)



func getProperties() -> Dictionary:
	var properties = {
		"width": width_spinbox.value,
		"height": height_spinbox.value,
		"portal_color": portal_color_button.color,
		"frame_color": frame_color_button.color,
		"rust_color": rust_color_button.color,
		"rust_strength": rust_strength_spinbox.value,
		"use_bottom_frame": bottom_frame_toggle.button_pressed,
		
		"position": gizmo_control_ui.get_position_vec3(),
		"rotation": gizmo_control_ui.get_rotation_vec3()
	}

	return properties

func setProperties(properties: Dictionary) -> void:
	if properties.has("id"):
		set_id(properties["id"])
	
	if properties.has("linked_id"):
		set_linked_id(properties["linked_id"])

	if properties.has("width"):
		set_width(properties["width"])

	if properties.has("width"):
		set_width(properties["width"])

	if properties.has("height"):
		set_height(properties["height"])

	if properties.has("portal_color"):
		set_portal_color(properties["portal_color"])

	if properties.has("frame_color"):
		set_frame_color(properties["frame_color"])

	if properties.has("rust_color"):
		set_rust_color(properties["rust_color"])

	if properties.has("rust_strength"):
		set_rust_strength(properties["rust_strength"])

	if properties.has("use_bottom_frame"):
		set_use_bottom_frame(properties["use_bottom_frame"])

	
	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])