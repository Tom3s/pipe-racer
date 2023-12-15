extends Node3D

@onready var replayViewerUI: ReplayViewerUI = %ReplayViewerUI
@onready var replayGhost: ReplayGhost = %ReplayGhost
@onready var map: Map = %Map

var camera: FollowingCamera

func setup(
	localReplays: Array[String],
	downloadedReplays: Array[String],
	mapId: String,
):
	for replay in localReplays:
		var path = "user://replays/" + replay
		replayGhost.loadReplay(path, false)
	
	for replay in downloadedReplays:
		var path = "user://replays/downloaded/" + replay
		replayGhost.loadReplay(path, false)

	map.loadMap("user://tracks/downloaded/" + mapId + ".json")

	replayViewerUI.setup(replayGhost.getNrFrames(), replayGhost.getCar(0).playerName)

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

	setup(
		[
			# "hagyma_ghoster2-00-14-972_2023-12-15.replay",
			# "hagyma_Nyomor-00-14-701_2023-12-15.replay",
			"Champion's Track_Nyomor-02-12-327_2023-12-15.replay",
		],
		[
			# "657c3a65e7e7cb41b065894c.replay",
			# "657c61f0e7e7cb41b0658a95.replay",
		],
		# "65018d2f76dbc79627323b22", # hagyma
		"650c73d0c3b8efa6383dde32", # Champion's Track
	)

	camera = FollowingCamera.new(replayGhost.getCar(0))
	add_child(camera)

	set_physics_process(true)

func _physics_process(delta):
	if replayGhost.playing:
		replayViewerUI.setFrame(replayGhost.currentIndex)
