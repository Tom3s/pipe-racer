extends Control

var windowSize: Vector2
var inAnimation: bool = false

func _process(delta):

	if inAnimation:
		return

	windowSize = get_viewport_rect().size
	scale = Vector2(windowSize.y / 648.0, windowSize.y / 648.0)
	position.y = (windowSize.y - size.y * scale.y) / 2.0
	position.x = (windowSize.x) - (size.x * scale.x * 1.05)
