@tool
extends PanelContainer
class_name MultiSelectMenu

@export
var items: Array[String]:
	set(newValue):
		items = newValue
		if container != null:
			updateItems()

var emptyLabel: Label

const padding: int = 10 
const cornerRadius: int = 5

func _ready():

	emptyLabel = Label.new()
	emptyLabel.text = "No items"

	var styleBox = StyleBoxFlat.new()
	styleBox.bg_color = Color(0, 0, 0, 0.4)
	styleBox.content_margin_bottom = padding
	styleBox.content_margin_left = padding
	styleBox.content_margin_right = padding
	styleBox.content_margin_top = padding
	styleBox.corner_radius_bottom_left = cornerRadius
	styleBox.corner_radius_bottom_right = cornerRadius
	styleBox.corner_radius_top_left = cornerRadius
	styleBox.corner_radius_top_right = cornerRadius
	add_theme_stylebox_override("panel", styleBox)
	container = VBoxContainer.new()
	container.layout_mode = 1
	add_child(container)
	updateItems()

signal itemToggled(index: int, button_pressed: bool)

var container: VBoxContainer

func updateItems():
	
	for child in container.get_children():
		if child != emptyLabel:
			container.remove_child(child)
			child.queue_free()
	
	# if items.size() == 0:
	# 	if emptyLabel.get_parent() == null:
	# 		container.add_child(emptyLabel)
	# 	else:
	# 		emptyLabel.reparent(container)
	# 	return
	emptyLabel.visible = items.size() == 0

	var index = 0
	for item in items:
		var listItem = MultiSelectItem.new()
		listItem.text = item
		listItem.index = index
		listItem.toggled.connect(onToggle)
		container.add_child(listItem)
		index += 1

func onToggle(index: int, toggledState: bool):
	itemToggled.emit(index, toggledState)

func getSelectedItems() -> Array[int]:
	var selectedItems: Array[int] = []
	for child in container.get_children():
		if child != emptyLabel: 
			if child.isToggled():
				selectedItems.append(child.index)
	return selectedItems

func setSelectedItems(selectedItems: Array[int]):
	for child in container.get_children():
		if child != emptyLabel:
			child.setToggled(selectedItems.has(child.index))