extends Control
class_name ReplayViewerUI

@onready var currentFrame: Label = %CurrentFrame
@onready var seekBar: HSlider = %SeekBar
@onready var totalFrames: Label = %TotalFrames

@onready var playPauseButton: Button = %PlayPauseButton
@onready var halfSpeedButton: Button = %HalfSpeedButton
@onready var doubleSpeedButton: Button = %DoubleSpeedButton
@onready var resetSpeedButton: Button = %ResetSpeedButton
@onready var playbackSpeedLabel: Label = %PlaybackSpeedLabel
@onready var playbackSpeedSlider: HSlider = %PlaybackSpeedSlider

@onready var exitButton: Button = %ExitButton
@onready var prevPlayerButton: Button = %PrevPlayerButton
@onready var nextPlayerButton: Button = %NextPlayerButton
@onready var currentPlayer: Label = %CurrentPlayer
@onready var changeCameraButton: Button = %ChangeCameraButton
@onready var freeCamButton: Button = %FreeCamButton

signal playPauseToggled(toggled: bool)
signal newSpeedSet(speed: float)
signal seekBarChanged(newFrame: int)
signal changePlayer(player: int)
signal changeCamera()
signal freeCamSelected(freeCam: bool)
signal exitPressed()
signal hideUI(visible: bool)

func setup(
	totalFramrCount: int,
	initPlayerName: String,
):
	totalFrames.text = str(totalFramrCount)
	setFrame(0)
	playPauseButton.button_pressed = true
	currentPlayer.text = initPlayerName

func _ready():
	seekBar.value_changed.connect(func(value: float):
		var newFrame = floori((value * totalFrames.text.to_float()) / 100)
		seekBarChanged.emit(newFrame)
	)
	playPauseButton.toggled.connect(func(toggled: bool):
		playPauseToggled.emit(toggled)
	)
	playbackSpeedSlider.value_changed.connect(func(speed: float):
		playbackSpeedLabel.text = str(speed)
		newSpeedSet.emit(speed)
	)
	halfSpeedButton.pressed.connect(func():
		playbackSpeedSlider.value = playbackSpeedSlider.value / 2
	)
	doubleSpeedButton.pressed.connect(func():
		playbackSpeedSlider.value = playbackSpeedSlider.value * 2
	)
	resetSpeedButton.pressed.connect(func():
		playbackSpeedSlider.value = 1
	)
	prevPlayerButton.pressed.connect(func():
		changePlayer.emit(-1)
	)
	nextPlayerButton.pressed.connect(func():
		changePlayer.emit(1)
	)
	changeCameraButton.pressed.connect(func():
		changeCamera.emit()
	)
	exitButton.pressed.connect(func():
		exitPressed.emit()
	)
	freeCamButton.toggled.connect(func(toggled: bool):
		freeCamSelected.emit(toggled)
	)

	set_physics_process(true)

func _physics_process(delta: float):
	if Input.is_action_just_pressed("replay_hide_ui"):
		visible = !visible
		hideUI.emit(visible)


func setFrame(frame: int) -> void:
	currentFrame.text = str(frame)
	seekBar.set_value_no_signal((frame * 100) / totalFrames.text.to_float())