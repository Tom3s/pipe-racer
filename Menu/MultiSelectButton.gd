@tool
extends Button
class_name MultiSelectButton

var multiSelectMenu: MultiSelectMenu

@export
var items: Array[String]:
	set(newValue):
		items = newValue
		if multiSelectMenu != null:
			multiSelectMenu.items = newValue

signal itemToggled(index: int, toggled: bool)

func _ready():
	toggle_mode = true
	multiSelectMenu = MultiSelectMenu.new()
	multiSelectMenu.position = Vector2(size.x, 0)
	multiSelectMenu.items = items
	multiSelectMenu.hide()
	multiSelectMenu.itemToggled.connect(onItemToggled)
	add_child(multiSelectMenu)

	toggled.connect(onToggle)

	resized.connect(onResized)

func onToggle(toggledState: bool):
	multiSelectMenu.visible = toggledState

func onItemToggled(index: int, toggledState: bool):
	itemToggled.emit(index, toggledState)

func addItem(item: String):
	items.append(item)
	multiSelectMenu.items = items

func clear():
	items.clear()
	multiSelectMenu.items = items

func getSelectedItems() -> Array[int]:
	return multiSelectMenu.getSelectedItems()

func onResized():
	multiSelectMenu.position = Vector2(size.x, 0)

func setSelectedItems(selectedItems: Array[int]):
	multiSelectMenu.setSelectedItems(selectedItems)