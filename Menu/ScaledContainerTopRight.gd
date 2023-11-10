extends Control

var windowSize: Vector2
var inAnimation: bool = false

var scaleX: float
var scaleY: float

@export
var overscale: float = 1.0

@export
var offset: Vector2i = Vector2i(0, 0)

func _ready():
	size = overscale * Vector2(1152, 648)

func _process(delta):

	if inAnimation:
		return

	windowSize = get_viewport_rect().size
	# scaleX = windowSize.x / (1152.0 * overscale)
	scaleY = windowSize.y / (648.0 * overscale)
	scale = Vector2(scaleY, scaleY)
	position.y = offset.y * scale.y
	position.x = (windowSize.x - size.x * scale.x) + offset.x * scale.x