extends Node

class_name TimeTrialManager

var timeTrialLapEnd: int = -1

var paused: bool = false

var times: Array = []

var splits: Array = []

var ingameSFX: IngameSFX = null

var nrLaps: int

var playerId: String = ""
var trackId: String = ""

var isPB: bool = false

var timeMultiplier: float = 1.0

signal checkPointCollected(timestamp: int, lastTimestamp: int, currentLapTime: int)



func _init(ingameSFXNode: IngameSFX, initnrLaps: int, initplayerId: String, inittrackId: String, loadPB: bool, initTimeMultiplier: float = 1.0) -> void:
	ingameSFX = ingameSFXNode
	nrLaps = initnrLaps
	playerId = initplayerId
	trackId = inittrackId
	timeMultiplier = initTimeMultiplier
	if loadPB:
		loadPersonalBest()
		loadPersonalBestLap()

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
	# ingameSFX.playFinishLapSFX()
	if times.size() >= nrLaps:
		replaceSplitsIfBetter()

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

var bestSplits: Array = []
var bestLapSplits: Array = []

func collectCheckpoint(timestamp: int, lap: int) -> void:
	# =====
	if splits.size() <= lap:
		splits.append([])
	var currentSplit = timestamp - timeTrialLapEnd
	splits[lap].append(currentSplit)
	# =====
	# ^ this is required anyways

	# Save lap only time
	var currentLapTime = currentSplit

	# Save pb split in lastTimestamp
	var lastTimestamp = currentSplit
	# Set lastTimestamp to bestSplit if it exists
	if GlobalProperties.COMPARE_AGAINST_BEST_LAP:
		if bestLapSplits.size() >= splits[lap].size():
			lastTimestamp = bestLapSplits[splits[lap].size() - 1] * timeMultiplier
	else:
		if bestSplits.size() >= lap + 1 && bestSplits[lap].size() >= splits[lap].size():
			lastTimestamp = bestSplits[lap][splits[lap].size() - 1] * timeMultiplier

		# Adjust for total lap times
		for i in lap:
			if bestSplits.size() >= i + 1:
				currentSplit += splits[i].back() # * timeMultiplier
				lastTimestamp += bestSplits[i].back() * timeMultiplier

	checkPointCollected.emit(currentSplit, lastTimestamp, currentLapTime)

func reset() -> void:
	times = []
	timeTrialLapEnd = -1
	for splitList in splits:
		splitList.clear()
	splits.clear()
	isPB = false
	newTimeMultiplier = false

func loadPersonalBest() -> void:
	var pbRequest = HTTPRequest.new()
	Leaderboard.add_child(pbRequest)
	pbRequest.timeout = 5
	pbRequest.request_completed.connect(onPersonalBestLoaded)

	var httpError = pbRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/leaderboard/" + trackId,
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))


func onPersonalBestLoaded(result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if _responseCode != 200:
		print("Response: ", _responseCode)
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())

	for time in data:
		if time["user"]["_id"] == playerId:
			bestSplits = time["splits"]
			print("[TimeTrialManager.gd] Loaded PB")
			return

	
	if data.size() > 0:
		bestSplits = data.back()["splits"]
	
	print("[TimeTrialManager.gd] Loaded PB")

func loadPersonalBestLap() -> void:
	var pbRequest = HTTPRequest.new()
	Leaderboard.add_child(pbRequest)
	pbRequest.timeout = 5
	pbRequest.request_completed.connect(onPersonalBestLapLoaded)

	var httpError = pbRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/leaderboard/" + trackId + "?sortByLap=true",
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onPersonalBestLapLoaded(result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if _responseCode != 200:
		print("Response: ", _responseCode)
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())

	for time in data:
		if time["user"]["_id"] == playerId:
			setBestLapSplits(time["splits"])
			print("[TimeTrialManager.gd] Loaded PB lap")
			return

	
	if data.size() > 0:
		# bestSplits = data.back()["splits"]
		setBestLapSplits(data.back()["splits"])
	print("[TimeTrialManager.gd] Loaded PB lap")

func setBestLapSplits(loadedBestSplits):
	# var bestLapTime = loadedBestSplits[0].back()
	var bestLapTime = 9223372036854775807 # max int64
	# bestLapSplits.clear()
	# bestLapSplits.append_array(loadedBestSplits[0])
	if bestLapSplits.size() > 0:
		bestLapTime = bestLapSplits.back()
	for array in loadedBestSplits:
		if array.back() < bestLapTime:
			bestLapTime = array.back()
			bestLapSplits.clear()
			bestLapSplits.append_array(array)

var newTimeMultiplier: bool = false

func replaceSplitsIfBetter(totalTimeData = null, splitData = null):
	if timeMultiplier != 1.0:
		var totalTime = getTotalTime()
		var bestTime = bestSplits.reduce(func(accum, lap): return accum + lap.back(), 0)

		if totalTime <= bestTime:
			timeMultiplier = 1.0
			newTimeMultiplier = true
		elif totalTime <= bestTime * MedalMenu.GOLD_MULTIPLIER:
			timeMultiplier = 1.0
			newTimeMultiplier = true
		elif totalTime <= bestTime * MedalMenu.SILVER_MULTIPLIER:
			timeMultiplier = MedalMenu.GOLD_MULTIPLIER
			newTimeMultiplier = true
			return
		elif totalTime <= bestTime * MedalMenu.BRONZE_MULTIPLIER:
			timeMultiplier = MedalMenu.SILVER_MULTIPLIER
			newTimeMultiplier = true
			return


	if totalTimeData == null && splitData == null:
		var totalTime = getTotalTime()
		var bestTime = bestSplits.reduce(func(accum, lap): return accum + lap.back(), 0)

		if bestTime >= totalTime || bestSplits.size() == 0:
			# bestSplits = splits
			print("Setting new PB splits")
			isPB = true
			bestSplits.clear()
			for array in splits:
				var copyArray = []
				copyArray.append_array(array)
				bestSplits.append(copyArray)
		setBestLapSplits(splits)
	elif totalTimeData != null && splitData != null:
		# while !loadedPBLap || !loadedPBTime:
		# 	print("[TimeTrialManager.gd] waiting for PB to load")
		# 	await get_tree().create_timer(1.0).timeout
		
		print("[TimeTrialManager.gd] trying to replace splits with ghost splits")

		var totalTime = totalTimeData
		var bestTime = bestSplits.reduce(func(accum, lap): return accum + lap.back(), 0)

		if bestTime >= totalTime || bestSplits.size() == 0:
			# bestSplits = splits
			print("Setting new PB splits")
			bestSplits.clear()
			for array in splitData:
				var copyArray = []
				copyArray.append_array(array)
				bestSplits.append(copyArray)
		setBestLapSplits(splitData)
	else:
		print("[TimeTrialManager.gd] replaceSplitsIfBetter: invalid arguments")
		return

