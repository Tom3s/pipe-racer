extends Control

@onready var mainContent: Control = %MainContent
@onready var playButton: Button = %PlayButton
@onready var editButton: Button = %EditButton
@onready var playOnlineButton: Button = %PlayOnlineButton
@onready var websiteButton: Button = %WebsiteButton
@onready var settingsButton: Button = %SettingsButton
# @onready var controlsButton: Button = %ControlsButton
@onready var exitButton: Button = %ExitButton
@onready var settingsMenu: SettingsMenu = %SettingsMenu

@onready var raceMapLoader: RaceMapLoader = %RaceMapLoader
@onready var editorMapLoader: EditorMapLoader = %EditorMapLoader
@onready var onlineMapLoader: OnlineMapLoader = %OnlineMapLoader
@onready var controlsMenu: ControlsMenu = %ControlsMenu

@onready var musicPlayer: MusicPlayer = %MusicPlayer

@onready var buttonContainer: VBoxContainer = %ButtonContainer

var buttons: Array = []

func _ready():
	raceMapLoader.hide()
	editorMapLoader.hide()
	onlineMapLoader.hide()

	controlsMenu.visible = false

	playButton.grab_focus()

	connectSignals()

	GlobalProperties.setOriginalSettingsMenu(self, settingsMenu, onSettingsMenu_backPressed)

	%VersionLabel.text = "Version: " + VersionCheck.currentVersion

	set_physics_process(true)
	

func connectSignals():
	playButton.pressed.connect(onPlayButton_pressed)
	editButton.pressed.connect(onEditButton_pressed)
	playOnlineButton.pressed.connect(onPlayOnlineButton_pressed)
	settingsButton.pressed.connect(onSettingsButton_pressed)
	settingsMenu.closePressed.connect(onSettingsMenu_backPressed)
	exitButton.pressed.connect(get_tree().quit)

	websiteButton.pressed.connect(onWebsiteButton_pressed)

	raceMapLoader.backPressed.connect(onRaceMapLoader_backPressed)
	editorMapLoader.backPressed.connect(onEditorMapLoader_backPressed)
	editorMapLoader.enteredMapEditor.connect(onEditorMapLoader_enteredMapEditor)
	editorMapLoader.exitedMapEditor.connect(onEditorMapLoader_exitedMapEditor)
	onlineMapLoader.backPressed.connect(onOnlineMapLoader_backPressed)

func _physics_process(delta):
	if (get_viewport().gui_get_focus_owner() == null || !get_viewport().gui_get_focus_owner().is_visible_in_tree()) && mainContent.visible:
		# playButton.grab_focus()
		if Input.is_action_just_pressed("ui_left") || \
			Input.is_action_just_pressed("ui_right") || \
			Input.is_action_just_pressed("ui_up") || \
			Input.is_action_just_pressed("ui_down") || \
			Input.is_action_just_pressed("ui_accept") || \
			Input.is_action_just_pressed("ui_cancel"):
			playButton.grab_focus()

func onPlayButton_pressed():
	await hideMainContentsAnimated()
	raceMapLoader.show()

func onEditButton_pressed():
	await hideMainContentsAnimated()
	editorMapLoader.show()

func onPlayOnlineButton_pressed():
	await hideMainContentsAnimated()
	onlineMapLoader.show()

func onSettingsButton_pressed():
	await hideMainContentsAnimated()
	# settingsMenu.visible = true
	settingsMenu.animateIn()

func onSettingsMenu_backPressed():
	# mainContent.visible = true
	await showMainContentsAnimated()
	settingsButton.grab_focus()

func onRaceMapLoader_backPressed():
	# mainContent.visible = true
	await showMainContentsAnimated()
	playButton.grab_focus()

func onEditorMapLoader_backPressed():
	# mainContent.visible = true
	await showMainContentsAnimated()
	editButton.grab_focus()


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
	if musicPlayer != null:
		musicPlayer.playMenuMusic()

func onOnlineMapLoader_backPressed():
	# mainContent.visible = true
	playOnlineButton.grab_focus()
	await showMainContentsAnimated()


const MOVE_TIME = 0.2
const INBETWEEN_TIME = 0.05
# var originalButtonPositions: Array = []
func animateMainContentsOut():
	var tween = create_tween()
	tween.set_parallel(true)

	var windowSize = get_viewport_rect().size


	var index = 1
	for child in buttonContainer.get_children():
		# child.get_child(0).inAnimation = true
		var button: Button = child.get_child(0)
		button.disabled = true
		button.inAnimation = true
		var label: Label = child.get_child(0).get_child(0)

		# originalButtonPositions.append(label.position)

		# tween.tween_interval(INBETWEEN_TIME)
		# await create_tween().tween_interval(INBETWEEN_TIME).finished
		tween.tween_property(label, "position", Vector2(-windowSize.x, 0), MOVE_TIME)\
			.as_relative()\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_delay(INBETWEEN_TIME * index)
		index += 1
	
	return tween.finished
	# var children = buttonContainer.get_children()
	# await tween.chain().tween_interval(0.01).finished
	# mainContent.visible = false
	# for i in children.size():
	# 	var label: Label = children[i].get_child(0).get_child(0)
	# 	# label.position = Vector2(windowSize.x/2.0, 0.0)
	# 	tween.chain().tween_property(label, "position", originalButtonPositions[i], 0)
	
	# return tween.finished

func animateMainContentsIn():
	var tween = create_tween()

	var windowSize = get_viewport_rect().size

	for child in buttonContainer.get_children():
		# child.get_child(0).inAnimation = true
		var button: Button = child.get_child(0)
		button.disabled = true
		button.inAnimation = true
		var label: Label = child.get_child(0).get_child(0)
		tween.tween_property(label, "position", Vector2(-windowSize.x, 0), 0)\
			.as_relative()
	# await tween.finished
	# mainContent.visible = true
	tween.tween_property(mainContent, "visible", true, 0)
	tween = create_tween()
	tween.set_parallel(true)
	var index = 1
	for child in buttonContainer.get_children():
		# child.get_child(0).inAnimation = true
		# var button: Button = child.get_child(0)
		# button.disabled = true
		# button.inAnimation = true
		var label: Label = child.get_child(0).get_child(0)

		# originalButtonPositions.append(label.position)

		# tween.tween_interval(INBETWEEN_TIME)
		# await create_tween().tween_interval(INBETWEEN_TIME).finished
		

		tween.tween_property(label, "position", Vector2(windowSize.x, 0), MOVE_TIME)\
			.as_relative()\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_delay(INBETWEEN_TIME * index)
		index += 1
	
	return tween.finished

func resetButtons():
	for child in buttonContainer.get_children():
		# child.get_child(0).inAnimation = true
		var button: Button = child.get_child(0)
		button.disabled = false
		button.inAnimation = false

func hideMainContentsAnimated():
	await animateMainContentsOut()
	mainContent.visible = false
	resetButtons()

func showMainContentsAnimated():
	# mainContent.visible = true
	await animateMainContentsIn()
	resetButtons()