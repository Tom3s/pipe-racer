extends Control
class_name PlayerPanel

@onready var username: LineEdit = %Username
@onready var password: LineEdit	= %Password
@onready var colorPicker: ColorPickerButton = %ColorPicker
@onready var guestLabel: Label = %GuestLabel
@onready var guestTickBox: CheckBox = %GuestTickBox
@onready var loginButton: Button = %LoginButton
@onready var asGuestButton: Button = %AsGuestButton
@onready var logoutButton: Button = %LogoutButton
@onready var randomColorButton: Button = %RandomColorButton

@onready var profilePicture: TextureRect = %ProfilePicture

var isMainPlayer: bool = false

var defaultPicture: Texture

var sessionToken: String = ""
var userId: String = ""

func _ready():
	defaultPicture = profilePicture.texture
	connectSignals()

func connectSignals():
	username.text_changed.connect(onUsername_textChanged)
	password.text_changed.connect(onPassword_textChanged)
	username.text_submitted.connect(onLoginButton_pressed)
	password.text_submitted.connect(onLoginButton_pressed)
	
	colorPicker.color_changed.connect(onColorPicker_colorChanged)
	guestTickBox.toggled.connect(onGuestTickBox_toggled)
	loginButton.pressed.connect(onLoginButton_pressed)
	asGuestButton.pressed.connect(asGuestButton_pressed)
	logoutButton.pressed.connect(onLogoutButton_pressed)
	randomColorButton.pressed.connect(onRandomColorButton_pressed)





func onUsername_textChanged(_newText: String):
	pass

func onPassword_textChanged(_newText: String):
	pass

func onColorPicker_colorChanged(_newColor: Color):
	pass

func onGuestTickBox_toggled(pressed: bool):
	password.visible = !pressed	
	loginButton.visible = !pressed
	asGuestButton.visible = pressed

func onLoginButton_pressed(_sink = null):
	if VersionCheck.versionCheckComplete == false:
		await VersionCheck.fetchedNewestVersion
	if VersionCheck.offline:
		AlertManager.showAlert(self, "Offline mode", "You are in offline mode. Please update the game to play online.")
		return

	setButtonsLoggingIn()

	print("Logging in...")

	var loginData = getLoginData()
	var loginRequest = HTTPRequest.new()
	Network.add_child(loginRequest)
	loginRequest.timeout = 10

	loginRequest.request_completed.connect(onLoginRequestCompleted)

	var httpError = loginRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/auth/login",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(loginData)
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))
		setButtonsLoggedOut()


func asGuestButton_pressed():

	if VersionCheck.offline:
		AlertManager.showAlert(self, "Offline mode", "You are in offline mode. Please update the game to play online.")
		return

	setButtonsLoggingIn()

	var loginData = getLoginData()
	var loginRequest = HTTPRequest.new()
	Network.add_child(loginRequest)
	loginRequest.timeout = 10

	loginRequest.request_completed.connect(onLoginRequestCompleted)

	var httpError = loginRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/auth/guest",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(loginData)
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func onLogoutButton_pressed():
	setButtonsLoggedOut()

	setRandomPlayerData()
	pass

func onLoginRequestCompleted(_result: int, responseCode: int, _headers: PackedStringArray, body: PackedByteArray):

	if responseCode != 200:
		setButtonsLoggedOut()
		print("Error after login request: ", body.get_string_from_utf8())
		if GlobalProperties.playerSelectorNode.visible:
			AlertManager.showAlert(self, "Error logging in", body.get_string_from_utf8())
		print("Result: ", responseCode)
		return
	
	setButtonsLoggedIn()

	var json = JSON.parse_string(body.get_string_from_utf8())
	
	password.text = ""
	sessionToken = json.sessionToken
	userId = json.userId

	if isMainPlayer:
		GlobalProperties.SESSION_TOKEN = sessionToken
		GlobalProperties.USER_ID = userId
	
	var profilePictureUrl = json.profilePictureUrl

	loadProfilePicture(profilePictureUrl)

func onRandomColorButton_pressed():
	colorPicker.color = Color(randf(), randf(), randf(), 1.0)

func setMainPlayerData():
	# while !is_node_ready():
	# 	await get_tree().create_timer(1.0).timeout
	isMainPlayer = true
	username.text = GlobalProperties.PLAYER_NAME
	username.text_changed.connect(onTextChanged)
	password.text = GlobalProperties.PLAYER_PASSWORD
	password.text_changed.connect(onPasswordTextChanged)
	colorPicker.color = GlobalProperties.PLAYER_COLOR
	colorPicker.color_changed.connect(onColorChanged)

	onLoginButton_pressed()


func setRandomPlayerData():
	username.text = "Player" + str(randi() % 1000)
	colorPicker.color = Color(randf(), randf(), randf(), 1.0)
	sessionToken = ""
	userId = ""
	profilePicture.texture = defaultPicture

func onTextChanged(newText: String) -> void:
	if newText != "":
		GlobalProperties.PLAYER_NAME = newText

func onPasswordTextChanged(newText: String) -> void:
	if newText != "":
		GlobalProperties.PLAYER_PASSWORD = newText

func onColorChanged(new_color):
	GlobalProperties.PLAYER_COLOR = new_color

func getPlayerData() -> PlayerData:
	return PlayerData.new(userId, username.text, colorPicker.color, sessionToken)

func getLoginData() -> Dictionary:
	return {
		"username": username.text,
		"password": password.text,
	}

func loadProfilePicture(imageUrl: String):
	var httpRequest = HTTPRequest.new()
	Network.add_child(httpRequest)
	httpRequest.timeout = 15
	httpRequest.request_completed.connect(onLoadProfilePictureRequestCompleted)

	var httpError = httpRequest.request(imageUrl)
	if httpError != OK:
		print("Error: " + str(httpError))

func onLoadProfilePictureRequestCompleted(_result: int, _responseCode: int, _headers: PackedStringArray, body: PackedByteArray):
	var image = Image.new()
	var imageError = image.load_jpg_from_buffer(body)
	if imageError != OK:
		print("Error loading jpg: " + error_string(imageError))
		print("Trying PNG...")
		imageError = image.load_png_from_buffer(body)
		if imageError != OK:
			print("Error loading png: " + error_string(imageError))
			return
		else:
			print("PNG loaded successfully")
	else:
		print("JPG loaded successfully")
	
	# var profileTexture = ImageTexture.new()
	

	profilePicture.texture = ImageTexture.create_from_image(image)

func setButtonsLoggingIn():
	loginButton.disabled = true
	loginButton.text = "Loading"

	asGuestButton.disabled = true
	asGuestButton.text = "Loading"

	username.editable = false
	password.editable = false

	# guestLabel.visible = false
	# guestTickBox.visible = false

func setButtonsLoggedIn():
	loginButton.visible = false
	asGuestButton.visible = false
	logoutButton.visible = true
	username.editable = false
	password.editable = false
	password.visible = false

func setButtonsLoggedOut():
	loginButton.disabled = false
	loginButton.visible = true
	loginButton.text = "Log In"
	asGuestButton.disabled = false
	asGuestButton.visible = true
	asGuestButton.text = "As Guest"

	logoutButton.visible = false
	# guestLabel.visible = true
	# guestTickBox.visible = true
	username.editable = true
	password.editable = true
	password.visible = true

