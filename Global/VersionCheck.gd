extends Control

var offline = true

var debug_version = "v1.5"

var currentVersion = "v1.4.1"

var current_build = "277"

var versionCheckComplete = false

signal fetchedNewestVersion(version: String, build: String)

func _ready():
	theme = load("res://DarkTheme/Dark.theme")
	checkVersion()

func checkVersion():
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 30.0
	# request.timeout = 0.0
	request.request_completed.connect(onCheckVersion_requestCompleted)

	var result = request.request(
		"https://api.github.com/repos/Tom3s/pipe-racer/releases/latest"
	)

	if result != OK:
		MogyiLogger.log(self, "Error while checking for updates: %s" % error_string(result), MogyiLogger.Severity.ERROR)
		AlertManager.showAlert(
			self,
			"Error",
			"Error while checking for updates. Playing in offline mode."
		)
		fetchedNewestVersion.emit(currentVersion, current_build)
		versionCheckComplete = true


func onCheckVersion_requestCompleted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code != 200 || result != HTTPRequest.RESULT_SUCCESS:
		MogyiLogger.log(self, "Error checking version: %s (response code: %d)" % [error_string(result), response_code])
		AlertManager.showAlert(
			self,
			"Error",
			"Error while checking for updates. Playing in offline mode."
		)
		fetchedNewestVersion.emit(currentVersion, current_build)
		versionCheckComplete = true
		return

	var bodyString = body.get_string_from_utf8()
	var bodyJson = JSON.parse_string(bodyString)

	var newestVersion = bodyJson["tag_name"]

	MogyiLogger.log(self, "Newest version: %s" % newestVersion)
	MogyiLogger.log(self, "Current version: %s.%s" % [currentVersion, current_build])
	if OS.is_debug_build():
		MogyiLogger.log(self, "Displayed (in dev) version: %s.%s" % [debug_version, current_build])

	offline = newestVersion != currentVersion

	fetchedNewestVersion.emit(newestVersion, current_build)

	versionCheckComplete = true

	if offline:
		AlertManager.showAlert(
			self,
			"New version available",
			"New version available: " + newestVersion + \
			"\nDownload it from the website (accessible from the main menu)." + \
			"\nOnline features will be disabled until you update."
		)
