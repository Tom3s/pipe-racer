extends Node3D

@onready var carController: CarController = %CarController

var frameData = []

var playing = false

var frame = 0

func _ready():
	carController.gravity_scale = 0
	# loadReplay("user://replays/hagyma_mogyi-00-14-686_2023-12-12.replay")
	loadReplay("user://replays/Flat Circuit_mogyi-02-15-497_2023-12-12.replay")

	var cam = FollowingCamera.new(carController)
	cam.current = true
	add_child(cam)

	set_physics_process(true)

func _physics_process(_delta):
	if playing:
		if frame < frameData.size() - 1:
			carController.global_position = frameData[frame][0]
			carController.global_rotation = frameData[frame][1]
			carController.linear_velocity = (frameData[frame + 1][0] - frameData[frame][0]) * (1 / _delta) 
			frame += 1
		else:
			frame = 0

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
	var replayPosRot = fileHandler.get_csv_line()
	while replayPosRot[0] != "REPLAY_END":
		frameData.append([
			Vector3(
				replayPosRot[0].to_float(),
				replayPosRot[1].to_float(),
				replayPosRot[2].to_float()
			),
			Vector3(
				replayPosRot[3].to_float(),
				replayPosRot[4].to_float(),
				replayPosRot[5].to_float()
			)
		])
			
		replayPosRot = fileHandler.get_csv_line()
	playing = true
	
	fileHandler.close()

