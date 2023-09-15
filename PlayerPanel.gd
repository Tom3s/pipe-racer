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

func onLoginButton_pressed():
	setButtonsLoggingIn()

	var loginData = getLoginData()
	var loginRequest = HTTPRequest.new()
	add_child(loginRequest)

	loginRequest.request_completed.connect(onLoginRequestCompleted)

	var httpError = loginRequest.request(
		Backend.BACKEND_IP_ADRESS + "/api/auth/login",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(loginData)
	)
	if httpError != OK:
		print("Error: " + error_string(httpError))

func asGuestButton_pressed():
	setButtonsLoggingIn()

	var loginData = getLoginData()
	var loginRequest = HTTPRequest.new()
	add_child(loginRequest)

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
		print("Error: " + body.get_string_from_utf8())
		return
	
	setButtonsLoggedIn()

	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# loginButton.text = "Log Out"
	password.text = ""
	sessionToken = json.sessionToken
	userId = json.userId

	if isMainPlayer:
		Playerstats.SESSION_TOKEN = sessionToken
		Playerstats.USER_ID = userId

	loadProfilePicture(json.profilePictureUrl)

func onRandomColorButton_pressed():
	colorPicker.color = Color(randf(), randf(), randf(), 1.0)

func setMainPlayerData():
	isMainPlayer = true
	username.text = Playerstats.PLAYER_NAME
	username.text_changed.connect(onTextChanged)
	password.text = Playerstats.PLAYER_PASSWORD
	password.text_changed.connect(onPasswordTextChanged)
	colorPicker.color = Playerstats.PLAYER_COLOR
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
		Playerstats.PLAYER_NAME = newText

func onPasswordTextChanged(newText: String) -> void:
	if newText != "":
		Playerstats.PLAYER_PASSWORD = newText

func onColorChanged(new_color):
	Playerstats.PLAYER_COLOR = new_color

func getPlayerData() -> PlayerData:
	return PlayerData.new(userId, username.text, colorPicker.color, sessionToken)

func getLoginData() -> Dictionary:
	return {
		"username": username.text,
		"password": password.text,
	}

func loadProfilePicture(imageUrl: String):
	var httpRequest = HTTPRequest.new()
	add_child(httpRequest)
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

	guestLabel.visible = false
	guestTickBox.visible = false

func setButtonsLoggedIn():
	loginButton.visible = false
	asGuestButton.visible = false
	logoutButton.visible = true
	username.editable = false
	password.editable = false
	password.visible = false

func setButtonsLoggedOut():
	loginButton.disabled = false
	loginButton.visible = !guestTickBox.button_pressed
	loginButton.text = "Log In"
	asGuestButton.disabled = false
	asGuestButton.visible = guestTickBox.button_pressed
	asGuestButton.text = "As Guest"

	logoutButton.visible = false
	guestLabel.visible = true
	guestTickBox.visible = true
	username.editable = true
	password.editable = true
	password.visible = !guestTickBox.button_pressed

