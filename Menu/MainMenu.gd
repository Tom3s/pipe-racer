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
	nickname.text = Playerstats.PLAYER_NAME
	colorPicker.color = Playerstats.PLAYER_COLOR
	raceMapLoader.hide()
	editorMapLoader.hide()
	connectSignals()

func connectSignals():
	playButton.pressed.connect(onPlayButton_pressed)
	editButton.pressed.connect(onEditButton_pressed)
	settingsButton.pressed.connect(onSettingsButton_pressed)
	settingsMenu.closePressed.connect(onSettingsMenu_backPressed)
	exitButton.pressed.connect(get_tree().quit)

	nickname.text_changed.connect(onTextChanged)
	colorPicker.color_changed.connect(onColorChanged)

	raceMapLoader.backPressed.connect(onRaceMapLoader_backPressed)
	editorMapLoader.backPressed.connect(onEditorMapLoader_backPressed)
	editorMapLoader.enteredMapEditor.connect(onEditorMapLoader_enteredMapEditor)
	editorMapLoader.exitedMapEditor.connect(onEditorMapLoader_exitedMapEditor)


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
	# settingsMenu.visible = false

func onRaceMapLoader_backPressed():
	mainContent.visible = true
	refreshPlayerData()
	# raceMapLoader.hide()

func onEditorMapLoader_backPressed():
	mainContent.visible = true
	refreshPlayerData()
	# editorMapLoader.hide()

func refreshPlayerData():
	nickname.text = Playerstats.PLAYER_NAME
	colorPicker.color = Playerstats.PLAYER_COLOR

func onTextChanged(newText: String) -> void:
	if newText != "":
		Playerstats.PLAYER_NAME = newText

func onColorChanged(new_color):
	Playerstats.PLAYER_COLOR = new_color

func onEditorMapLoader_enteredMapEditor():
	%Background.visible = false
	musicPlayer.stopMusic()

func onEditorMapLoader_exitedMapEditor():
	%Background.visible = true
	musicPlayer.playMenuMusic()
