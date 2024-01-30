extends Control
class_name PlayerStatsUI

@onready var totalPlaytime: Label = %TotalPlaytime
@onready var ingamePlaytime: Label = %IngamePlaytime
@onready var editorPlaytime: Label = %EditorPlaytime

@onready var chronoMedals: Label = %ChronoMedals
@onready var totalGoldMedals: Label = %TotalGoldMedals
@onready var totalSilverMedals: Label = %TotalSilverMedals
@onready var totalBronzeMedals: Label = %TotalBronzeMedals

@onready var blitzMedals: Label = %BlitzMedals
@onready var lapGoldMedals: Label = %LapGoldMedals
@onready var lapSilverMedals: Label = %LapSilverMedals
@onready var lapBronzeMedals: Label = %LapBronzeMedals

@onready var nrAttempts: Label = %NrAttempts
@onready var nrFinishes: Label = %NrFinishes
@onready var nrTracksPlayed: Label = %NrTracksPlayed

@onready var nrObjectsPlaced: Label = %NrObjectsPlaced
@onready var nrTracksUploaded: Label = %NrTracksUploaded
@onready var nrTracksRated: Label = %NrTracksRated

@onready var closeButton: Button = %CloseButton

signal closePressed()

func _ready():
	closeButton.pressed.connect(func():
		hide()
		closePressed.emit()
	)

	visibility_changed.connect(func():
		if is_visible_in_tree():
			fetchPlayerStats()
			closeButton.grab_focus()
	)

	# fetchPlayerStats()
	GlobalProperties.loginStatusChanged.connect(func(newStatus: bool):
		if newStatus:
			fetchPlayerStats()
	)

func getHourStringFromMinutes(playetimeMinutes: int) -> String:
	var hours = playetimeMinutes / 60
	var minutes = playetimeMinutes % 60

	return str(hours) + "h " + str(minutes) + "m"


func fetchPlayerStats():
	if VersionCheck.offline:
		AlertManager.showAlert(self, "You are offline", "You can't view your stats while offline.")
		return
	
	if GlobalProperties.loggedIn == false:
		AlertManager.showAlert(self, "Not logged in", "You can't view your stats while not logged in.")
		return

	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 15
	request.request_completed.connect(onFetchPlayerStats_completed)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/stats/user/" + GlobalProperties.USER_ID,
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN
		],
		HTTPClient.METHOD_GET
	)

	if httpError != OK:
		print("[PlayerStatsUI.gd] Error sending request: " + error_string(httpError))


func onFetchPlayerStats_completed(result: int, responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	if responseCode != 200:
		print("[PlayerStatsUI.gd] Error ", responseCode, ": ", body.get_string_from_utf8())
		return

	var data = JSON.parse_string(body.get_string_from_utf8())

	totalPlaytime.text = getHourStringFromMinutes(data.totalPlaytime)
	ingamePlaytime.text = getHourStringFromMinutes(data.ingamePlaytime)
	editorPlaytime.text = getHourStringFromMinutes(data.editorPlaytime)

	chronoMedals.text = str(data.chronoMedals)
	totalGoldMedals.text = str(data.totalGoldMedals)
	totalSilverMedals.text = str(data.totalSilverMedals)
	totalBronzeMedals.text = str(data.totalBronzeMedals)

	blitzMedals.text = str(data.blitzMedals)
	lapGoldMedals.text = str(data.lapGoldMedals)
	lapSilverMedals.text = str(data.lapSilverMedals)
	lapBronzeMedals.text = str(data.lapBronzeMedals)

	nrAttempts.text = str(data.totalAttempts)
	nrFinishes.text = str(data.totalFinishes)
	nrTracksPlayed.text = str(data.tracksPlayed)
	
	nrObjectsPlaced.text = str(data.placedAll)
	nrTracksUploaded.text = str(data.tracksUploaded)
	nrTracksRated.text = str(data.tracksRated)
