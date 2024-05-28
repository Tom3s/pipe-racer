extends Control
class_name PaintBrushUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var surfaceOptions: OptionButton = %SurfaceOptions

@onready var visibilityButton: Button = %VisibilityButton


# out signals

signal surfaceMaterialChanged(surface: int)
# in setters

func setRoadSurface(surface: int) -> void:
	surfaceOptions.selected = surface


func _ready():
	setupMaterialOptions()

	connectSignals()

func connectSignals() -> void:
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Paint Brush" if visibilityButton.button_pressed else "^ Paint Brush"
	)

	surfaceOptions.item_selected.connect(func(index: int):
		surfaceMaterialChanged.emit(index)
	)

func setupMaterialOptions() -> void:
	# pipe surface options
	surfaceOptions.clear()

	for material in PhysicsSurface.SurfaceType.keys():
		surfaceOptions.add_item(material.capitalize())

	surfaceOptions.selected = 0

func getProperties() -> Dictionary:
	return {
		"surfaceType": surfaceOptions.selected,
	}

func setProperties(properties: Dictionary) -> void:
	setRoadSurface(properties["surfaceType"])