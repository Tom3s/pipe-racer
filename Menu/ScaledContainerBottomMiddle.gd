@tool
extends Control

var windowSize: Vector2
var inAnimation: bool = false

@export
var offset: Vector2i = Vector2i(0, 0)
@export
var baseScaleFactor: float = 1.0

func _process(delta):

	if inAnimation:
		return

	windowSize = get_viewport_rect().size
	scale = Vector2(windowSize.y / 648.0, windowSize.y / 648.0) * baseScaleFactor
	position.y = offset.y * scale.y + (windowSize.y - size.y * scale.y)
	position.x = (windowSize.x - size.x * scale.x) / 2.0 + offset.x * scale.x
