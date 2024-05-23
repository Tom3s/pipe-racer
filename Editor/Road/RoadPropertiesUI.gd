extends Control
class_name RoadPropertiesUI


# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var roadSurfaceOptions: OptionButton = %RoadSurfaceOptions
@onready var wallMaterialOptions: OptionButton = %WallMaterialOptions
@onready var supportTypeOptions: OptionButton = %SupportTypeOptions
@onready var supportMaterialOptions: OptionButton = %SupportMaterialOptions
@onready var supportBottomSpinbox: SpinBox = %SupportBottomSpinbox

@onready var leftWallTypeOptions: OptionButton = %LeftWallTypeOptions
@onready var leftWallStartHeightSpinbox: SpinBox = %LeftWallStartHeightSpinbox
@onready var leftWallEndHeightSpinbox: SpinBox = %LeftWallEndHeightSpinbox
@onready var leftRunoffMaterialOptions: OptionButton = %LeftRunoffMaterialOptions

@onready var rightWallTypeOptions: OptionButton = %RightWallTypeOptions
@onready var rightWallStartHeightSpinbox: SpinBox = %RightWallStartHeightSpinbox
@onready var rightWallEndHeightSpinbox: SpinBox = %RightWallEndHeightSpinbox
@onready var rightRunoffMaterialOptions: OptionButton = %RightRunoffMaterialOptions

@onready var visibilityButton: Button = %VisibilityButton


# out signals

signal roadSurfaceChanged(surface: int)
signal wallMaterialChanged(material: int)
signal supportTypeChanged(type: int)
signal supportMaterialChanged(material: int)
signal supportBottomChanged(bottom: float)

signal leftWallTypeChanged(type: int)
signal leftWallStartHeightChanged(height: float)
signal leftWallEndHeightChanged(height: float)
signal leftRunoffMaterialChanged(material: int)

signal rightWallTypeChanged(type: int)
signal rightWallStartHeightChanged(height: float)
signal rightWallEndHeightChanged(height: float)
signal rightRunoffMaterialChanged(material: int)


# in setters

func setRoadSurface(surface: int) -> void:
	roadSurfaceOptions.selected = surface

func setWallMaterial(wallMaterial: int) -> void:
	wallMaterialOptions.selected = wallMaterial

func setSupportType(supportType: int) -> void:
	supportTypeOptions.selected = supportType

func setSupportMaterial(supportMaterial: int) -> void:
	supportMaterialOptions.selected = supportMaterial

func setSupportBottom(bottom: float) -> void:
	supportBottomSpinbox.set_value_no_signal(bottom)

func setLeftWallType(wallType: int) -> void:
	leftWallTypeOptions.selected = wallType

func setLeftWallStartHeight(height: float) -> void:
	leftWallStartHeightSpinbox.set_value_no_signal(height)

func setLeftWallEndHeight(height: float) -> void:
	leftWallEndHeightSpinbox.set_value_no_signal(height)

func setLeftRunoffMaterial(material: int) -> void:
	leftRunoffMaterialOptions.selected = material

func setRightWallType(wallType: int) -> void:
	rightWallTypeOptions.selected = wallType

func setRightWallStartHeight(height: float) -> void:
	rightWallStartHeightSpinbox.set_value_no_signal(height)

func setRightWallEndHeight(height: float) -> void:
	rightWallEndHeightSpinbox.set_value_no_signal(height)

func setRightRunoffMaterial(material: int) -> void:
	rightRunoffMaterialOptions.selected = material


func _ready():
	setupMaterialOptions()
	setupSupportTypeOptions()
	setupWallTypeOptions()

	connectSignals()

func connectSignals() -> void:
	visibilityButton.pressed.connect(func():
		mainContainer.visible = !visibilityButton.button_pressed
		visibilityButton.text = "v Road Settings" if visibilityButton.button_pressed else "^ Road Settings"
	)

	roadSurfaceOptions.item_selected.connect(func(index: int):
		roadSurfaceChanged.emit(index)
	)

	wallMaterialOptions.item_selected.connect(func(index: int):
		wallMaterialChanged.emit(index)
	)

	supportTypeOptions.item_selected.connect(func(index: int):
		supportTypeChanged.emit(index)
	)

	supportMaterialOptions.item_selected.connect(func(index: int):
		supportMaterialChanged.emit(index)
	)

	supportBottomSpinbox.value_changed.connect(func(value: float):
		supportBottomChanged.emit(value)
	)

	leftWallTypeOptions.item_selected.connect(func(index: int):
		leftWallTypeChanged.emit(index)
	)

	leftWallStartHeightSpinbox.value_changed.connect(func(value: float):
		leftWallStartHeightChanged.emit(value)
	)

	leftWallEndHeightSpinbox.value_changed.connect(func(value: float):
		leftWallEndHeightChanged.emit(value)
	)

	leftRunoffMaterialOptions.item_selected.connect(func(index: int):
		leftRunoffMaterialChanged.emit(index)
	)

	rightWallTypeOptions.item_selected.connect(func(index: int):
		rightWallTypeChanged.emit(index)
	)

	rightWallStartHeightSpinbox.value_changed.connect(func(value: float):
		rightWallStartHeightChanged.emit(value)
	)

	rightWallEndHeightSpinbox.value_changed.connect(func(value: float):
		rightWallEndHeightChanged.emit(value)
	)

	rightRunoffMaterialOptions.item_selected.connect(func(index: int):
		rightRunoffMaterialChanged.emit(index)
	)


func setupMaterialOptions() -> void:
	# road surface options
	# wall material options
	# support material options
	# left runoff material options
	# right runoff material options
	
	roadSurfaceOptions.clear()
	wallMaterialOptions.clear()
	supportMaterialOptions.clear()
	leftRunoffMaterialOptions.clear()
	rightRunoffMaterialOptions.clear()

	for material in PhysicsSurface.SurfaceType.keys():
		roadSurfaceOptions.add_item(material.capitalize())
		wallMaterialOptions.add_item(material.capitalize())
		supportMaterialOptions.add_item(material.capitalize())
		leftRunoffMaterialOptions.add_item(material.capitalize())
		rightRunoffMaterialOptions.add_item(material.capitalize())

	roadSurfaceOptions.selected = 0
	wallMaterialOptions.selected = 6
	supportMaterialOptions.selected = 5
	leftRunoffMaterialOptions.selected = 1
	rightRunoffMaterialOptions.selected = 1

func setupSupportTypeOptions() -> void:
	supportTypeOptions.clear()
	for supportType in RoadMeshGenerator.SupportType:
		supportTypeOptions.add_item(supportType.capitalize())

	supportTypeOptions.selected = 0


func setupWallTypeOptions() -> void:
	leftWallTypeOptions.clear()
	rightWallTypeOptions.clear()
	for wallType in RoadMeshGenerator.WallTypes:
		leftWallTypeOptions.add_item(wallType.capitalize())
		rightWallTypeOptions.add_item(wallType.capitalize())

	leftWallTypeOptions.selected = 0
	rightWallTypeOptions.selected = 0

func getProperties() -> Dictionary:
	return {
		"surfaceType": roadSurfaceOptions.selected,
		"wallSurfaceType": wallMaterialOptions.selected,

		"leftWallType": leftWallTypeOptions.selected,
		"leftWallStartHeight": leftWallStartHeightSpinbox.value,
		"leftWallEndHeight": leftWallEndHeightSpinbox.value,

		"rightWallType": rightWallTypeOptions.selected,
		"rightWallStartHeight": rightWallStartHeightSpinbox.value,
		"rightWallEndHeight": rightWallEndHeightSpinbox.value,

		"supportType": supportTypeOptions.selected,
		"supportBottomHeight": supportBottomSpinbox.value,
		"supportMaterial": supportMaterialOptions.selected,
		
		"leftRunoffSurfaceType": leftRunoffMaterialOptions.selected,
		"rightRunoffSurfaceType": rightRunoffMaterialOptions.selected
	}

func setProperties(properties: Dictionary) -> void:
	if properties.has("surfaceType"):
		setRoadSurface(properties["surfaceType"])
	if properties.has("wallSurfaceType"):
		setWallMaterial(properties["wallSurfaceType"])
	
	if properties.has("leftWallType"):
		setLeftWallType(properties["leftWallType"])
	if properties.has("leftWallStartHeight"):
		setLeftWallStartHeight(properties["leftWallStartHeight"])
	if properties.has("leftWallEndHeight"):
		setLeftWallEndHeight(properties["leftWallEndHeight"])

	if properties.has("rightWallType"):
		setRightWallType(properties["rightWallType"])
	if properties.has("rightWallStartHeight"):
		setRightWallStartHeight(properties["rightWallStartHeight"])
	if properties.has("rightWallEndHeight"):
		setRightWallEndHeight(properties["rightWallEndHeight"])

	if properties.has("supportType"):
		setSupportType(properties["supportType"])
	if properties.has("supportBottomHeight"):
		setSupportBottom(properties["supportBottomHeight"])
	if properties.has("supportMaterial"):
		setSupportMaterial(properties["supportMaterial"])

	if properties.has("leftRunoffSurfaceType"):
		setLeftRunoffMaterial(properties["leftRunoffSurfaceType"])
	if properties.has("rightRunoffSurfaceType"):
		setRightRunoffMaterial(properties["rightRunoffSurfaceType"])
	