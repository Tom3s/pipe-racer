extends Control

var offline = true

var currentVersion = "v1.4.1"

var versionCheckComplete = false

signal fetchedNewestVersion(version: String)

func _ready():
	theme = load("res://DarkTheme/Dark.theme")
	checkVersion()

func checkVersion():
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 15
	request.request_completed.connect(onCheckVersion_requestCompleted)

	var result = request.request(
		"https://api.github.com/repos/Tom3s/pipe-racer/releases/latest"
	)

	if result != OK:
		print("Error: ", result)
		AlertManager.showAlert(
			self,
			"Error",
			"Error while checking for updates. Playing in offline mode."
		)
		fetchedNewestVersion.emit(currentVersion)
		versionCheckComplete = true


func onCheckVersion_requestCompleted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	# print(body.get_string_from_ascii())
	if response_code != 200 || result != OK:
		print("Error: ", error_string(result), " (respone code: ", response_code, ")")
		AlertManager.showAlert(
			self,
			"Error",
			"Error while checking for updates. Playing in offline mode."
		)
		fetchedNewestVersion.emit(currentVersion)
		versionCheckComplete = true
		return

	var bodyString = body.get_string_from_utf8()
	var bodyJson = JSON.parse_string(bodyString)

	# print(bodyString)

	# var versionPos = bodyString.find("releases/tag/v") + 14
	
	var newestVersion = bodyJson["tag_name"]

	print("Newest version: ", newestVersion)
	print("Current version: ", currentVersion)

	offline = newestVersion != currentVersion

	fetchedNewestVersion.emit(newestVersion)

	versionCheckComplete = true

	if offline:
		AlertManager.showAlert(
			self,
			"New version available",
			"New version available: " + newestVersion + \
			"\nDownload it from the website (accessible from the main menu)." + \
			"\nOnline features will be disabled until you update."
		)
