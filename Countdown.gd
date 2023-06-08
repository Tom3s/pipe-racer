extends Label

signal countdownFinished()

@export
var countdownStartTime: float = 0
@export
var countdownTime: float = 3

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
	if get_tree().get_multiplayer().is_server():
		if event.is_action_pressed("start_countdown") && countdownStartTime == 0:
			start_countdown()
		if event.is_action_pressed("reset_race"):
			get_parent().get_parent().get_node("%PauseMenu").onRestartButton_pressed()
	if event.is_action_pressed("pause"):
		var pauseMenuButtons = get_parent().get_parent().get_node("%PauseMenu/%Buttons")
		pauseMenuButtons.visible = !pauseMenuButtons.visible

# @rpc
func start_countdown():
	countdownStartTime = Time.get_ticks_msec()
	countingDown = true

func reset():
	countdownStartTime = 0
	countingDown = false
	text = ""
