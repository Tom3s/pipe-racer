@tool
extends HBoxContainer
class_name MultiSelectItem

@export
var text: String = "Option":
	set(newValue):
		text = newValue
		if label != null:
			label.text = text

@export
var label: Label
@export
var check: CheckButton

var index: int = -1

signal toggled(index: int, button_pressed: bool)

func _ready():
	# var container := HBoxContainer.new()
	anchors_preset = Control.PRESET_HCENTER_WIDE
	label = Label.new()
	label.text = text
	# label.anchors_preset = Control.PRESET_HCENTER_WIDE
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(label)
	check = CheckButton.new()
	check.size_flags_horizontal = Control.SIZE_SHRINK_END
	add_child(check)
	# add_child(container)

	check.toggled.connect(onCheckToggled)

func onCheckToggled(button_pressed: bool):
	toggled.emit(index, button_pressed)

func isToggled() -> bool:
	return check.button_pressed

func setToggled(toggled: bool):
	check.button_pressed = toggled