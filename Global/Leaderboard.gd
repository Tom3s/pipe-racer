extends Node

func submitTime(
	recordingFile: String,
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

	var recordingRequest = HTTPRequest.new()
	add_child(recordingRequest)
	recordingRequest.timeout = 10
	recordingRequest.request_completed.connect(func(_result, response_code, _headers, _body):
		if response_code != 200:
			print(_body.get_string_from_utf8())
			return

		var replayId = JSON.parse_string(_body.get_string_from_utf8())._id

		var submitData = {
			"track": trackId,
			"splits": splits,
			"time": totalTime,
			"bestLap": bestLap,
			"replay": replayId,
		}

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
	)

	var recordingFileData = FileAccess.open(recordingFile, FileAccess.READ)
	var recordingFileBytes = recordingFileData.get_buffer(recordingFileData.get_length())
	recordingFileData.close()

	var httpError = recordingRequest.request_raw(
		Backend.BACKEND_IP_ADRESS + "/api/replays",
		[
			"Content-Type: application/octet-stream",
			"Session-Token: " + sessionToken,
		],
		HTTPClient.METHOD_POST,
		recordingFileBytes
	)

	if httpError != OK:
		print("Error submitting replay: " + error_string(httpError))


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
