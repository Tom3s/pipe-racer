extends Label

signal countdownFinished(timestamp: int)
signal shouldReset()

@export
var countdownStartTime: float = 0
@export
var countdownTime: float = 3

@export
var countingDown: bool = false

@onready
var synchronizer = %MultiplayerSynchronizer

var musicPlayer: MusicPlayer = null
var ingameSFX: IngameSFX = null

var shouldCountdown: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	musicPlayer = get_parent().get_parent().get_node("%MusicPlayer")
	ingameSFX = get_parent().get_parent().get_node("%IngameSFX")
	set_physics_process(true)

func _physics_process(delta):
	if shouldCountdown:
		startCountdown()
		shouldCountdown = false

func _unhandled_input(event):
	if get_tree().get_multiplayer().is_server() || get_parent().get_parent().get_node("%CarSpawner").get_child_count() == 1:
		if event.is_action_pressed("start_countdown") && countdownStartTime == 0:
			# startCountdown()
			shouldCountdown = true
		if event.is_action_pressed("reset_race"):
			get_parent().get_parent().get_node("%PauseMenu").onRestartButton_pressed()
			get_parent().get_parent().get_node("%CheckPointSystem").reset()
			shouldReset.emit()
	if event.is_action_pressed("pause"):
		var pauseMenuButtons = get_parent().get_parent().get_node("%PauseMenu/%Buttons")
		pauseMenuButtons.visible = !pauseMenuButtons.visible

@export_range(0.0, 1.0, 0.05)
var COUNTDOWN_INBETWEEN_TIME: float = 0.75

@export_range(0.0, 3.0, 0.05)
var COUNTDOWN_GO_TIME: float = 1.0

@export_range(0.0, 3.0, 0.05)
var COUNTDOWN_GO_FADE_TIME: float = 0.3

# @rpc
func startCountdown():
	modulate = Color(1, 1, 1, 1)

	musicPlayer.playMenuMusic()

	var tween = create_tween()

	tween.tween_property(self, "text", "3", 0.0).finished.connect(ingameSFX.playCountdownSFX)
	tween.tween_interval(COUNTDOWN_INBETWEEN_TIME)
	tween.tween_property(self, "text", "2", 0.0).finished.connect(ingameSFX.playCountdownSFX)
	tween.tween_interval(COUNTDOWN_INBETWEEN_TIME)
	tween.tween_property(self, "text", "1", 0.0).finished.connect(ingameSFX.playCountdownSFX)
	tween.tween_interval(COUNTDOWN_INBETWEEN_TIME)
	tween.tween_property(self, "text", "GO!", 0.0).finished.connect(onCountdownFinished)
	tween.tween_interval(COUNTDOWN_GO_TIME)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), COUNTDOWN_GO_FADE_TIME)

func reset():
	countdownStartTime = 0
	countingDown = false
	text = ""

func onCountdownFinished():
	musicPlayer.playIngameMusic()
	ingameSFX.playStartRaceSFX()
	countdownFinished.emit(floor(Time.get_unix_time_from_system() * 1000))
