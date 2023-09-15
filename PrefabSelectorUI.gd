extends Control
class_name PrefabSelectorUI

@onready var prefabIconGenerator: PrefabIconGenerator = %PrefabIconGenerator
@onready var straight: ItemList = %Straight
@onready var curve: ItemList = %Curve

var prefabs: Array = []
var icons: Array = []

signal prefabSelected(data: Dictionary)
signal done()

func _ready():
	prefabIconGenerator.newPrefab.connect(addNewPrefab)
	straight.item_selected.connect(onStraightSelected)
	curve.item_selected.connect(onCurveSelected)
	prefabIconGenerator.done.connect(onDone)

func addNewPrefab(_category: int, name: String, data: Dictionary, icon: Texture):
	prefabs.append(data)
	icons.append(icon)
	# prefabSelector.add_item(name, icon)
	if _category == 0:
		straight.add_item("", icon)
	elif _category == 1:
		curve.add_item("", icon)

func onStraightSelected(index: int):
	var data = prefabs[index]

	prefabSelected.emit(data)

func onCurveSelected(index: int):
	var data = prefabs[index + straight.get_item_count()]

	prefabSelected.emit(data)

func onDone():
	done.emit()