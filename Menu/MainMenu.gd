extends Control

@onready var mainContent: Control = %MainContent
@onready var playButton: Button = %PlayButton
@onready var editButton: Button = %EditButton
@onready var playOnlineButton: Button = %PlayOnlineButton
@onready var websiteButton: Button = %WebsiteButton
@onready var settingsButton: Button = %SettingsButton
@onready var exitButton: Button = %ExitButton
@onready var nickname: LineEdit = %Nickname
@onready var colorPicker: ColorPickerButton = %ColorPicker
@onready var settingsMenu: SettingsMenu = %SettingsMenu

@onready var raceMapLoader: RaceMapLoader = %RaceMapLoader
@onready var editorMapLoader: EditorMapLoader = %EditorMapLoader

@onready var musicPlayer: MusicPlayer = %MusicPlayer

func _ready():
	nickname.text = GlobalProperties.PLAYER_NAME
	colorPicker.color = GlobalProperties.PLAYER_COLOR
	raceMapLoader.hide()
	editorMapLoader.hide()

	playButton.grab_focus()

	connectSignals()

func connectSignals():
	playButton.pressed.connect(onPlayButton_pressed)
	editButton.pressed.connect(onEditButton_pressed)
	settingsButton.pressed.connect(onSettingsButton_pressed)
	settingsMenu.closePressed.connect(onSettingsMenu_backPressed)
	exitButton.pressed.connect(get_tree().quit)

	websiteButton.pressed.connect(onWebsiteButton_pressed)

	nickname.text_changed.connect(onTextChanged)
	colorPicker.color_changed.connect(onColorChanged)

	raceMapLoader.backPressed.connect(onRaceMapLoader_backPressed)
	editorMapLoader.backPressed.connect(onEditorMapLoader_backPressed)
	editorMapLoader.enteredMapEditor.connect(onEditorMapLoader_enteredMapEditor)
	editorMapLoader.exitedMapEditor.connect(onEditorMapLoader_exitedMapEditor)

	# mainContent.visibility_changed.connect(race)


func onPlayButton_pressed():
	raceMapLoader.show()
	mainContent.visible = false

func onEditButton_pressed():
	editorMapLoader.show()
	mainContent.visible = false

func onSettingsButton_pressed():
	mainContent.visible = false
	settingsMenu.visible = true

func onSettingsMenu_backPressed():
	mainContent.visible = true
	settingsButton.grab_focus()
	# settingsMenu.visible = false

func onRaceMapLoader_backPressed():
	mainContent.visible = true
	playButton.grab_focus()
	refreshPlayerData()
	# raceMapLoader.hide()

func onEditorMapLoader_backPressed():
	mainContent.visible = true
	editButton.grab_focus()
	refreshPlayerData()
	# editorMapLoader.hide()

func refreshPlayerData():
	nickname.text = GlobalProperties.PLAYER_NAME
	colorPicker.color = GlobalProperties.PLAYER_COLOR

func onWebsiteButton_pressed():
	OS.shell_open(Backend.FRONTEND_IP_ADRESS)

func onTextChanged(newText: String) -> void:
	if newText != "":
		GlobalProperties.PLAYER_NAME = newText

func onColorChanged(new_color):
	GlobalProperties.PLAYER_COLOR = new_color

func onEditorMapLoader_enteredMapEditor():
	%Background.visible = false
	musicPlayer.stopMusic()

func onEditorMapLoader_exitedMapEditor():
	%Background.visible = true
	musicPlayer.playMenuMusic()
