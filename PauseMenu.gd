extends Control
class_name PauseMenu

@onready
var mainElements: Control = %MainElements

@onready
var resumeButton: Button = %ResumeButton
@onready
var restartButton: Button = %RestartButton
@onready
var settingsButton: Button = %SettingsButton
@onready
var exitButton: Button = %ExitButton

@onready
var settingsMenu: SettingsMenu = %SettingsMenu

signal resumePressed()
signal restartPressed()
signal exitPressed()


func _ready():
	visible = false

	# resumeButton = %ResumeButton
	# restartButton = %RestartButton
	# settingsButton = %SettingsButton
	# exitButton = %ExitButton

	settingsMenu.visible = false

	connectSignals()

func connectSignals():
	resumeButton.pressed.connect(onResumeButton_pressed)
	restartButton.pressed.connect(onRestartButton_pressed)
	settingsButton.pressed.connect(onSettingsButton_pressed)
	exitButton.pressed.connect(onExitButton_pressed)
	settingsMenu.closePressed.connect(onSettingsMenu_closePressed)

func onSettingsButton_pressed():
	settingsMenu.visible = true
	mainElements.visible = false

func onSettingsMenu_closePressed():
	settingsMenu.visible = false
	mainElements.visible = true

func onResumeButton_pressed():
	visible = false
	resumePressed.emit()

func onRestartButton_pressed():
	restartPressed.emit()

func onExitButton_pressed():
	exitPressed.emit()
	visible = false