extends Node

class_name TimeTrialManager

var timeTrialLapEnd: int = -1

var paused: bool = false

var times: Array = []

var splits: Array = []

var ingameSFX: IngameSFX = null

var nrLaps: int


func _init(ingameSFXNode: IngameSFX, initnrLaps: int) -> void:
	ingameSFX = ingameSFXNode
	nrLaps = initnrLaps

func _ready() -> void:
	ingameSFX = get_parent().get_parent().get_node("%IngameSFX")

func startTimeTrial(startTime: int) -> void:
	timeTrialLapEnd = startTime
	paused = false

func finishedLap() -> void:
	var lapFinishTime = floor(Time.get_unix_time_from_system() * 1000) 
	collectCheckpoint(lapFinishTime, splits.size() - 1)
	times.append(lapFinishTime - timeTrialLapEnd)
	timeTrialLapEnd = lapFinishTime
	ingameSFX.playFinishLapSFX()

func getTime() -> int:
	return times.reduce(func(accum, number): return accum + number, 0)

func getTotalTime() -> int:
	return getTime() + getCurrentLapTime()

func getLastLap() -> int:
	if times.size() <= 0:
		return 0
	return times[-1]

func getBestLap() -> int:
	if times.size() <= 0:
		return 0
	return times.min()

func getCurrentLapTime() -> int:
	if paused:
		return timeTrialLapEnd
	if times.size() == nrLaps:
		return 0
	return floor(Time.get_unix_time_from_system() * 1000) - timeTrialLapEnd

func pauseTimeTrial(timestamp: int) -> void:
	paused = true
	timeTrialLapEnd = timestamp - timeTrialLapEnd

func resumeTimeTrial(timestamp: int) -> void:
	paused = false
	timeTrialLapEnd = timestamp - timeTrialLapEnd

func collectCheckpoint(timestamp: int, lap: int) -> void:
	if splits.size() <= lap:
		splits.append([])
	splits[lap].append(timestamp - timeTrialLapEnd)

func reset() -> void:
	times = []
	timeTrialLapEnd = -1
	for splitList in splits:
		splitList.clear()
	splits.clear()
