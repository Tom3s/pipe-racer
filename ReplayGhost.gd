extends Node3D

@onready var carController: CarController = %CarController

var frameData = []

func _ready():
	carController.gravity_scale = 0
	loadReplay("user://replays/hagyma_mogyi-00-14-686_2023-12-12.replay")

func loadReplay(fileName: String):
	var fileHandler = FileAccess.open(fileName, FileAccess.READ)
	if fileHandler == null:
		print("Error opening replay file ", fileName)
		return
	
	var _mapName = fileHandler.get_line()
	# var nrCars = fileHandler.get_32()
	var _nrCars = fileHandler.get_line().to_int()

	var carMetadata = fileHandler.get_csv_line()
	var playerName = carMetadata[0]
	var playerColor = Color.from_string(carMetadata[1], Color.WHITE)

	carController.playerName = playerName
	carController.frameColor = playerColor
	print("Player color: ", playerColor.to_html())
	carController.setGhostMode(true)

	var time = fileHandler.get_line().to_int()

	if fileHandler.get_line() != "REPLAY_BEGIN":
		print("Error reading replay file ", fileName)
		return

	while fileHandler.get_line() != "REPLAY_END":
		var replayPos = fileHandler.get_csv_line()
		var replayRot = fileHandler.get_csv_line()

		frameData.append([
			Vector3(
				replayPos[0].to_float(),
				replayPos[1].to_float(),
				replayPos[2].to_float()
			),
			Vector3(
				replayRot[0].to_float(),
				replayRot[1].to_float(),
				replayRot[2].to_float()
			)
		])
	
	fileHandler.close()

