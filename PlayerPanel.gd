extends Control

@onready var username: LineEdit = %Username
@onready var password: LineEdit	= %Password
@onready var colorPicker: ColorPickerButton = %ColorPicker
@onready var guestTickBox: CheckBox = %GuestTickBox
@onready var loginButton: Button = %LoginButton
@onready var randomColorButton: Button = %RandomColorButton

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
