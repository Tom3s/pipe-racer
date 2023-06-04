extends Label

signal countdownFinished()

var countdownStartTime: float = 0
var countdownTime: float = 5

var countingDown: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if countingDown:
		var timeLeft = countdownStartTime + countdownTime * 1000 - Time.get_ticks_msec()
		if timeLeft <= 0:
			# countdownStartTime = 0
			emit_signal("countdownFinished")
			countingDown = false
		else:
			text = str(ceil(timeLeft / 1000))
	else:
		text = "GO!" if (countdownStartTime + countdownTime * 1000 - Time.get_ticks_msec()) >= -1000 else ""

func _unhandled_input(event):
	if event.is_action_pressed("start_countdown"):
		countdownStartTime = Time.get_ticks_msec()
		countingDown = true
		# text = str(countdownTime)