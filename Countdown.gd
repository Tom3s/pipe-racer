extends Label

signal countdownFinished()

@export
var countdownStartTime: float = 0
@export
var countdownTime: float = 1

@export
var countingDown: bool = false

@onready
var synchronizer = %MultiplayerSynchronizer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if countingDown:
		var timeLeft = countdownStartTime + countdownTime * 1000 - Time.get_ticks_msec()
		if timeLeft <= 0:
			# countdownStartTime = 0
			countdownFinished.emit()
			countingDown = false
		else:
			text = str(ceil(timeLeft / 1000))
	else:
		# countdownFinished.emit()
		text = "GO!" if (countdownStartTime + countdownTime * 1000 - Time.get_ticks_msec()) >= -1000 else ""


func _unhandled_input(event):
	# if synchronizer.is_multiplayer_authority():
	if get_tree().get_multiplayer().is_server():
		if event.is_action_pressed("start_countdown"):
			start_countdown()

# @rpc
func start_countdown():
	countdownStartTime = Time.get_ticks_msec()
	countingDown = true
