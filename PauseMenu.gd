extends Control
class_name PauseMenu

@onready var mainElements: Control = %MainElements

@onready var resumeButton: Button = %ResumeButton
@onready var restartButton: Button = %RestartButton
@onready var settingsButton: Button = %SettingsButton
@onready var controlsButton: Button = %ControlsButton
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

	settingsMenu.visible = false
	controlsMenu.visible = false

	connectSignals()

func connectSignals():
	resumeButton.pressed.connect(onResumeButton_pressed)
	restartButton.pressed.connect(onRestartButton_pressed)
	settingsButton.pressed.connect(onSettingsButton_pressed)
	controlsButton.pressed.connect(onControlsButton_pressed)
	exitButton.pressed.connect(onExitButton_pressed)
	settingsMenu.closePressed.connect(onSettingsMenu_closePressed)
	controlsMenu.closePressed.connect(onControlsMenu_closePressed)

func onSettingsButton_pressed():
	settingsMenu.visible = true
	mainElements.visible = false

func onSettingsMenu_closePressed():
	mainElements.visible = true

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
	controlsMenu.visible = true
	mainElements.visible = false

func onControlsMenu_closePressed():
	mainElements.visible = true