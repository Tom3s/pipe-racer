extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	%FollowingCamera.setup(%CarController)
	%FollowingCamera.current = false
