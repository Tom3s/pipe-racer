extends Node

func submitTime(
	splits: Array, 
	bestLap: int, 
	totalTime: int, 
	trackId: String,
	sessionToken: String,
	requestCompletedCallback: Callable,
) -> void:
	if trackId == "":
		print("Can't submit record on a non-downloaded track")
		return
	var submitData = {
		"track": trackId,
		"splits": splits,
		"time": totalTime,
		"bestLap": bestLap,
	}

	print(JSON.stringify(submitData, "\t"))

	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 10
	request.request_completed.connect(requestCompletedCallback)

	
	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/leaderboard",
		[
			"Content-Type: application/json",
			"Session-Token: " + sessionToken,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(submitData)
	)
	if httpError != OK:
		print("Error submitting time: " + error_string(httpError))

func submitRaceStats(
	stats: Dictionary, 
	sessionToken: String,
) -> void:
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 5

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/stats/track",
		[
			"Content-Type: application/json",
			"Session-Token: " + sessionToken,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(stats)
	)
	if httpError != OK:
		print("Error submitting time: " + error_string(httpError))