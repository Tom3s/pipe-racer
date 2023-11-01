extends Button

var label: Label

var labelOriginalPosition: Vector2

func _ready():
	label = get_child(0)
	labelOriginalPosition = label.position
	set_physics_process(true)

var inAnimation: bool = false

func _physics_process(delta):
	if is_hovered() && !inAnimation:
		label.position = lerp(label.position, labelOriginalPosition + Vector2(0, -8), .2)
	elif !inAnimation:
		label.position = lerp(label.position, labelOriginalPosition, .2)