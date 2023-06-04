extends Label

class_name DebugLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	pass # Replace with function body.


var timeTrialStart: int = -1
var timeTrialEnd: int = -1

var times: Array = []

func _physics_process(delta: float) -> void:
	# set_text("FPS " + str(Engine.get_frames_per_second()))
	# text = "FPS " + str(Engine.get_frames_per_second()) + "\n"
	text = ""
	if timeTrialStart != -1:
		text += "Lap: " + (str(currentLap) + "/5\n" if currentLap <= 5 else "Finished\n")
		text += "Time: " + get_time_string_from_ticks((Time.get_ticks_msec() - timeTrialStart)) + "\n"
		text += "Last Lap: " + get_time_string_from_ticks(-1 if times.is_empty() else times[-1]) + "\n"
		text += "Best Lap: " + get_time_string_from_ticks(-1 if times.is_empty() else times.min()) + "\n"
			

func set_start_time(time: int) -> void:
	timeTrialStart = time

func set_end_time(time: int) -> void:
	timeTrialEnd = time
	times.append(timeTrialEnd - timeTrialStart)
	timeTrialStart = timeTrialEnd

const TICK_RATE: int = 1000

func get_time_string_from_ticks(ticks: int) -> String:
	if ticks == -1:
		return "N/A"
	var seconds: int = ticks / TICK_RATE
	var minutes: int = seconds / 60

	return "%02d:%02d:" % [minutes % 60, seconds % 60] + ("%.3f" % ((ticks % TICK_RATE) / float(TICK_RATE))).split(".")[1]

var currentLap: int = 0

func set_lap(lap: int) -> void:
	currentLap = lap