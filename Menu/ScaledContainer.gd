extends Control

var windowSize: Vector2

func _process(delta):
	windowSize = get_viewport_rect().size
	scale = Vector2(windowSize.x / 1152.0, windowSize.x / 1152.0)
	position.y = (windowSize.y - size.y * scale.y) / 2.0
