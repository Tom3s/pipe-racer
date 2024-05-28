extends Area3D

class_name StartLineOld

enum StartLineState { 
	START_LINE_STATE_WAITING,
	START_LINE_STATE_TIMING,
	START_LINE_STATE_FINISHED
}

var state = StartLineState.START_LINE_STATE_WAITING

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	pass # Replace with function body.

