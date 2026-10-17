@tool
extends HBoxContainer
class_name EngineGUI

@onready var name_label: Label = %Name
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var value_label: Label = %Value

@export
var ui_name: String:
	set(val):
		if name_label != null:
			name_label.text = val
		ui_name = val

@export
var bounds: Vector2 = Vector2(0, 1):
	set(val):
		if progress_bar != null:
			progress_bar.min_value = val.x
			progress_bar.max_value = val.y
		bounds = val

@export
var value: float = 0:
	set(val):
		if progress_bar != null:
			progress_bar.value = val
		if value_label != null:
			value_label.text = str(val)
		value = val

var call_function: Callable = func() -> float: return 1.0

func _ready() -> void:
	name_label.text = ui_name
	progress_bar.min_value = bounds.x
	progress_bar.max_value = bounds.y
	progress_bar.value = value
	value_label.text = str(value)


func _process(_delta: float) -> void:
	if call_function == null || !is_node_ready():
		return
	
	progress_bar.value = call_function.call()
	value_label.text = str(call_function.call())
	
