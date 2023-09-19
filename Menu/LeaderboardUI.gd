extends Control
class_name LeaderboardUI

@onready var trackName: Label = %TrackName
@onready var bestLapsList: ItemList = %BestLapsList
@onready var bestTimesList: ItemList = %BestTimesList
@onready var closeButton: Button = %CloseButton

signal closePressed()

func _ready():
	closeButton.pressed.connect(onCloseButton_Pressed)
	visibility_changed.connect(closeButton.grab_focus)

func setHeader(newTrackName: String, author: String):
	trackName.text = newTrackName + " - by " + author

func onCloseButton_Pressed():
	visible = false
	closePressed.emit()

func fetchTimes(trackId: String):
	fetchBestLaps(trackId)
	fetchBestTimes(trackId)

func fetchBestLaps(trackId: String):
	bestLapsList.clear()
	bestLapsList.add_item("Loading...")
	var bestLapsRequest = HTTPRequest.new()
	add_child(bestLapsRequest)
	bestLapsRequest.timeout = 25
	bestLapsRequest.request_completed.connect(onBestLaps_RequestCompleted)

	var httpError = bestLapsRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/leaderboard/" + trackId + "?sortByLap=true"
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func fetchBestTimes(trackId: String):
	bestTimesList.clear()
	bestTimesList.add_item("Loading...")
	var bestTimesRequest = HTTPRequest.new()
	add_child(bestTimesRequest)
	bestTimesRequest.timeout = 25
	bestTimesRequest.request_completed.connect(onBestTimes_RequestCompleted)

	var httpError = bestTimesRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/leaderboard/" + trackId + "?sortByLap=false"
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onBestLaps_RequestCompleted(result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != OK:
		print("Error: " + error_string(result))
		return

	var data = JSON.parse_string(body.get_string_from_utf8())

	bestLapsList.clear()
	if data.size() == 0:
		bestLapsList.add_item("No records yet")
		return
	var placement = 1
	for record in data:
		var item: String = str(placement) + ". "
		item +=  record["user"]["username"] + " - " 
		item += IngameHUD.getTimeStringFromTicks(record["bestLap"])
		item += " (" + record["date"].split("T")[0] + ")"
		bestLapsList.add_item(item)
		placement += 1
	

func onBestTimes_RequestCompleted(result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != OK:
		print("Error: " + error_string(result))
		return

	var data = JSON.parse_string(body.get_string_from_utf8())

	bestTimesList.clear()
	if data.size() == 0:
		bestTimesList.add_item("No records yet")
		return
	var placement = 1
	for record in data:
		var item: String = str(placement) + ". "
		item +=  record["user"]["username"] + " - " 
		item += IngameHUD.getTimeStringFromTicks(record["time"])
		item += " (" + record["date"].split("T")[0] + ")"
		bestTimesList.add_item(item)
		placement += 1
