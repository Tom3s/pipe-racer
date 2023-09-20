extends Control
class_name PauseMenu

@onready var mainElements: Control = %MainElements

@onready var resumeButton: Button = %ResumeButton
@onready var restartButton: Button = %RestartButton
@onready var settingsButton: Button = %SettingsButton
@onready var controlsButton: Button = %ControlsButton
@onready var editorGuide: Button = %EditorGuide
@onready var exitButton: Button = %ExitButton

@onready var settingsMenu: SettingsMenu = %SettingsMenu
@onready var controlsMenu: ControlsMenu = %ControlsMenu

signal resumePressed()
signal restartPressed()
signal exitPressed()


func _ready():
	# visible = false

	# resumeButton = %ResumeButton
	# restartButton = %RestartButton
	# settingsButton = %SettingsButton
	# exitButton = %ExitButton

	editorGuide.visible = false

	settingsMenu.visible = false
	controlsMenu.visible = false

	resumeButton.grab_focus()

	connectSignals()

func connectSignals():
	resumeButton.pressed.connect(onResumeButton_pressed)
	restartButton.pressed.connect(onRestartButton_pressed)
	settingsButton.pressed.connect(onSettingsButton_pressed)
	controlsButton.pressed.connect(onControlsButton_pressed)
	editorGuide.pressed.connect(editorGuide_pressed)
	exitButton.pressed.connect(onExitButton_pressed)
	settingsMenu.closePressed.connect(onSettingsMenu_closePressed)
	controlsMenu.closePressed.connect(onControlsMenu_closePressed)
	mainElements.visibility_changed.connect(onVisibilityChanged)

func onSettingsButton_pressed():
	mainElements.visible = false
	settingsMenu.visible = true

func onSettingsMenu_closePressed():
	mainElements.visible = true
	settingsButton.grab_focus()

func onResumeButton_pressed():
	visible = false
	resumePressed.emit()

func onRestartButton_pressed():
	visible = false
	restartPressed.emit()

func onExitButton_pressed():
	visible = false
	exitPressed.emit()

func onControlsButton_pressed():
	mainElements.visible = false
	controlsMenu.visible = true

func editorGuide_pressed():
	OS.shell_open("https://github.com/Tom3s/pipe-racer-frontend/blob/main/src/StaticPages/EditorGuideMarkdown.md")

func onControlsMenu_closePressed():
	mainElements.visible = true
	controlsButton.grab_focus()

func onVisibilityChanged():
	if visible:
		resumeButton.grab_focus()
