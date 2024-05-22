extends Control
class_name PipePropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var pipeSurfaceOptions: OptionButton = %PipeSurfaceOptions

@onready var visibilityButton: Button = %VisibilityButton


# out signals

signal pipeSurfaceChanged(surface: int)
# in setters

func setRoadSurface(surface: int) -> void:
	pipeSurfaceOptions.selected = surface


func _ready():
	setupMaterialOptions()

	connectSignals()

func connectSignals() -> void:
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Pipe Settings" if visibilityButton.button_pressed else "^ Pipe Settings"
	)

	pipeSurfaceOptions.item_selected.connect(func(index: int):
		pipeSurfaceChanged.emit(index)
	)

func setupMaterialOptions() -> void:
	# pipe surface options
	pipeSurfaceOptions.clear()

	for material in PhysicsSurface.SurfaceType.keys():
		pipeSurfaceOptions.add_item(material.capitalize())

	pipeSurfaceOptions.selected = 0

func getProperties() -> Dictionary:
	return {
		"surfaceType": pipeSurfaceOptions.selected,
	}