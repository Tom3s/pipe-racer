extends Control

var windowSize: Vector2
var inAnimation: bool = false

var scaleX: float
var scaleY: float

func _process(delta):

	if inAnimation:
		return

	windowSize = get_viewport_rect().size
	scaleX = windowSize.x / 1152.0
	scaleY = windowSize.y / 648.0
	scale = Vector2(min(scaleX, scaleY), min(scaleX, scaleY))
	position.y = (windowSize.y - size.y * scale.y) / 2.0
	position.x = (windowSize.x - size.x * scale.x) / 2.0