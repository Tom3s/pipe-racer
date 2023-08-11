extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready():
	var camera = FollowingCamera.new(%CarController)
	add_child(camera)
