extends Control
class_name EditorPrompts

@onready var lookAround: HBoxContainer = %LookAround
@onready var moveCamera: HBoxContainer = %MoveCamera
@onready var placeItem: HBoxContainer = %PlaceItem
@onready var selectItem: HBoxContainer = %SelectItem
@onready var moveSelectedItem: HBoxContainer = %MoveSelectedItem
@onready var moveItemUpdown: HBoxContainer = %MoveItemUpdown
@onready var rotateItem: HBoxContainer = %RotateItem
@onready var rotateItemFine: HBoxContainer = %RotateItemFine
@onready var deleteSelected: HBoxContainer = %DeleteSelected
@onready var deleteItem: HBoxContainer = %DeleteItem
@onready var returnToEditor: HBoxContainer = %ReturnToEditor


func setGenericVisible(_visible: bool):
	lookAround.visible = _visible
	moveCamera.visible = _visible

func setBuildVisible(_visible: bool):
	placeItem.visible = _visible
	moveItemUpdown.visible = _visible
	rotateItem.visible = _visible
	rotateItemFine.visible = _visible

func setSelectVisible(_visible: bool):
	selectItem.visible = _visible

func setEditItemVisible(_visible: bool):
	moveItemUpdown.visible = _visible
	moveSelectedItem.visible = _visible
	deleteSelected.visible = _visible
	rotateItem.visible = _visible
	rotateItemFine.visible = _visible

func setDeleteVisible(_visible: bool):
	deleteItem.visible = _visible

func setTestingVisible(_visible: bool):
	returnToEditor.visible = _visible