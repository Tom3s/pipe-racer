extends Control

@onready var username: LineEdit = %Username
@onready var password: LineEdit	= %Password
@onready var colorPicker: ColorPickerButton = %ColorPicker
@onready var guestTickBox: CheckBox = %GuestTickBox
@onready var loginButton: Button = %LoginButton
@onready var randomColorButton: Button = %RandomColorButton

@onready var profilePicture: TextureRect = %ProfilePicture

func _ready():
	connectSignals()

func connectSignals():
	username.text_changed.connect(onUsername_textChanged)
	password.text_changed.connect(onPassword_textChanged)
	colorPicker.color_changed.connect(onColorPicker_colorChanged)
	guestTickBox.toggled.connect(onGuestTickBox_toggled)
	loginButton.pressed.connect(onLoginButton_pressed)
	randomColorButton.pressed.connect(onRandomColorButton_pressed)



func onUsername_textChanged(newText: String):
	pass

func onPassword_textChanged(newText: String):
	pass

func onColorPicker_colorChanged(newColor: Color):
	pass

func onGuestTickBox_toggled(pressed: bool):
	pass

func onLoginButton_pressed():
	pass

func onRandomColorButton_pressed():
	colorPicker.color = Color(randf(), randf(), randf(), 1.0)

func setMainPlayerData():
	username.text = Playerstats.PLAYER_NAME
	# password.text = Playerstats.PLAYER_PASSWORD
	username.text_changed.connect(onTextChanged)

	colorPicker.color = Playerstats.PLAYER_COLOR
	colorPicker.color_changed.connect(onColorChanged)

	loadProfilePicture("https://yt3.googleusercontent.com/ytc/AOPolaT2pQVPhbomlBCkncISGhpcanMpzdHJOQz5XI6_qA=s176-c-k-c0x00ffffff-no-rj")
	# loadProfilePicture("https://via.placeholder.com/500")


func setRandomPlayerData():
	username.text = "Player" + str(randi() % 1000)
	colorPicker.color = Color(randf(), randf(), randf(), 1.0)

func onTextChanged(newText: String) -> void:
	if newText != "":
		Playerstats.PLAYER_NAME = newText

func onColorChanged(new_color):
	Playerstats.PLAYER_COLOR = new_color

func getPlayerData() -> PlayerData:
	return PlayerData.new(0, username.text, colorPicker.color)

func loadProfilePicture(imageUrl: String):
	var httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.request_completed.connect(onHttpRequestCompleted)

	var httpError = httpRequest.request(imageUrl)
	if httpError != OK:
		print("Error: " + str(httpError))

func onHttpRequestCompleted(result: int, responseCode: int, headers: PackedStringArray, body: PackedByteArray):
	var image = Image.new()
	var imageError = image.load_jpg_from_buffer(body)
	if imageError != OK:
		print("Error loading jpg: " + str(imageError))
		print("Trying PNG...")
		imageError = image.load_png_from_buffer(body)
		if imageError != OK:
			print("Error loading png: " + str(imageError))
			return
		else:
			print("PNG loaded successfully")
	else:
		print("JPG loaded successfully")
	
	# var profileTexture = ImageTexture.new()
	

	profilePicture.texture = ImageTexture.create_from_image(image)


