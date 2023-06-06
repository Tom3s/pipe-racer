extends Control

var totalTimes = []
var bestLaps = []

func onVisibilityChanged() -> bool:
	var newValue = visible
	if newValue:
		refreshLists()
	timer.paused = !newValue
	return newValue

func fetchBestTotalTimes():
	Leaderboard.getScoresTotalTimes(onGetScoresTotalTimes_completed)

func fetchBestLaps():
	Leaderboard.getScoresBestLaps(onGetScoresBestLaps_completed)
	

func onGetScoresTotalTimes_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	var result = json["dreamlo"]["leaderboard"]["entry"]
	if result is Array:
		totalTimes = result
	else:
		totalTimes = [result]

	var totalTimesList: ItemList = %TotalTimesList
	totalTimesList.clear()
	for entry in totalTimes:
		# entry = entry["entry"]
		var playerName = entry["name"]
		var score = get_time_string_from_ticks(-(entry["score"]).to_int())
		var date = entry["date"].split(" ")[0]

		var row = playerName + " - " + score + " - " + date
		if entry["text"] != "":
			row += "(" + entry["text"] + ")"
		
		totalTimesList.add_item(row, null, false)

func onGetScoresBestLaps_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	var result = json["dreamlo"]["leaderboard"]["entry"]
	if result is Array:
		bestLaps = result
	else:
		bestLaps = [result]

	var bestLapsList: ItemList = %BestLapsList
	bestLapsList.clear()
	for entry in bestLaps:
		# entry = entry["entry"]
		var playerName = entry["name"]
		var score = get_time_string_from_ticks(-(entry["score"]).to_int())
		var date = entry["date"].split(" ")[0]

		var row = playerName + " - " + score + " - " + date
		if entry["text"] != "":
			row += "(" + entry["text"] + ")"
		
		bestLapsList.add_item(row, null, false)

var timer = null

func _ready():
	visibility_changed.connect(onVisibilityChanged)
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 10
	timer.one_shot = false
	timer.timeout.connect(refreshLists)
	timer.start()
	# refreshLists()

func refreshLists():
	fetchBestTotalTimes()
	fetchBestLaps()




func get_time_string_from_ticks(ticks: int) -> String:
	if ticks == -1:
		return "N/A"
	var seconds: int = ticks / 1000
	var minutes: int = seconds / 60

	return "%02d:%02d:" % [minutes % 60, seconds % 60] + ("%.3f" % ((ticks % 1000) / float(1000))).split(".")[1]
