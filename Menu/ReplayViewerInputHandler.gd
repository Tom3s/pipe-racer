extends Node
class_name ReplayViewerInputHandler

signal playPausePressed()
signal halfSpeedPressed()
signal doubleSpeedPressed()
signal resetSpeedPressed()
signal nextPlayerPressed()
signal prevPlayerPressed()
signal changeCamPressed()
signal freecamPressed()
signal seekForwardPressed()
signal seekBackwardPressed()


func _ready():
	set_physics_process(true)


func _physics_process(_delta):
	if Input.is_action_just_pressed("replay_pause"):
		playPausePressed.emit()
	if Input.is_action_just_pressed("replay_half_speed"):
		halfSpeedPressed.emit()
	if Input.is_action_just_pressed("replay_double_speed"):
		doubleSpeedPressed.emit()
	if Input.is_action_just_pressed("replay_reset_speed"):
		resetSpeedPressed.emit()
	if Input.is_action_just_pressed("replay_next_player"):
		nextPlayerPressed.emit()
	if Input.is_action_just_pressed("replay_prev_player"):
		prevPlayerPressed.emit()
	if Input.is_action_just_pressed("replay_change_cam"):
		changeCamPressed.emit()
	if Input.is_action_just_pressed("replay_free_cam"):
		freecamPressed.emit()
	if Input.is_action_just_pressed("replay_seek_forward"):
		seekForwardPressed.emit()
	if Input.is_action_just_pressed("replay_seek_backward"):
		seekBackwardPressed.emit()