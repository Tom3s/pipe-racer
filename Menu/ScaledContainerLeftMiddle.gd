extends Control

var windowSize: Vector2

func _process(delta):
	windowSize = get_viewport_rect().size
	scale = Vector2(windowSize.y / 648.0, windowSize.y / 648.0)
	position.y = (windowSize.y - size.y * scale.y) / 2.0
	# position.x = 0
