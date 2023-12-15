extends Node3D
class_name ReplayViewer

@onready var replayViewerUI: ReplayViewerUI = %ReplayViewerUI
@onready var replayGhost: ReplayGhost = %ReplayGhost
@onready var map: Map = %Map
@onready var freeCam: Camera3D = %FreeCam

var camera: FollowingCamera

signal exitPressed()

func setup(
	localReplays: Array[String],
	downloadedReplays: Array[String],
	mapId: String,
):
	for replay in localReplays:
		var path = "user://replays/" + replay
		replayGhost.loadReplay(path, false, false)
	
	for replay in downloadedReplays:
		var path = "user://replays/downloaded/" + replay
		replayGhost.loadReplay(path, false, false)

	map.loadMap("user://tracks/downloaded/" + mapId + ".json")

	replayViewerUI.setup(replayGhost.getNrFrames(), replayGhost.getCar(0).playerName)

	camera = FollowingCamera.new(replayGhost.getCar(0))
	add_child(camera)
	camera.current = true
	freeCam.current = false

	replayViewerUI.changePlayer.connect(func(player: int):
		currentPlayerIndex = (currentPlayerIndex + player) % replayGhost.get_child_count()
		if currentPlayerIndex < 0:
			currentPlayerIndex = replayGhost.get_child_count() - 1
		var newCar = replayGhost.getCar(currentPlayerIndex)
		camera.car = newCar
		replayViewerUI.currentPlayer.text = newCar.playerName
	)

	replayViewerUI.changeCamera.connect(func():
		camera.changeMode()
	)

	replayViewerUI.freeCamSelected.connect(func(freeCamSelected: bool):
		camera.current = !freeCamSelected
		freeCam.current = freeCamSelected
	)

var currentPlayerIndex: int = 0

func _ready():

	replayViewerUI.newSpeedSet.connect(func(speed: float):
		replayGhost.timeScale = speed
	)
	replayViewerUI.playPauseToggled.connect(func(isPaused: bool):
		replayGhost.playing = !isPaused
	)
	replayViewerUI.seekBarChanged.connect(func(frame: int):
		replayGhost.frame = frame
		replayGhost.currentIndex = frame
	)
	replayViewerUI.exitPressed.connect(func():
		exitPressed.emit()
		queue_free()
	)
	replayViewerUI.hideUI.connect(func(visible: bool):
		replayGhost.setLabelVisibility(visible)
	)
		

	set_physics_process(true)

func _physics_process(delta):
	if replayGhost.playing:
		replayViewerUI.setFrame(replayGhost.currentIndex)