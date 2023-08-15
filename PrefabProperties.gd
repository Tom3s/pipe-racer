extends MeshInstance3D
class_name PrefabProperties

var prefabData: Dictionary = {}
# var friction: float = 1.0

var selected: bool = false:
	set(value):
		selected = selectionChanged(value)

@onready
var selectedMaterial = preload("res://Tracks/trackPrefabSelected.tres")

func _init(data):
	prefabData = data

func selectionChanged(value):
	if value:
		set_surface_override_material(0, selectedMaterial)
	else:
		set_surface_override_material(0, null)

	return value

func select():
	selected = true
	print(name, "selected")

func deselect():
	selected = false
	print(name, "deselected")
