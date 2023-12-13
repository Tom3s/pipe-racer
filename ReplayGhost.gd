extends Node3D
class_name ReplayGhost

@onready var carController: CarController = %CarController

var frameData = []

var playing = false

var frame: float = 0.0

@export_range(0.1, 5.0, 0.1)
var timeScale: float = 1.0

func _ready():
	# loadReplay("user://replays/hagyma_mogyi-00-14-686_2023-12-12.replay")
	# loadReplay("user://replays/Flat Circuit_mogyi-02-15-497_2023-12-12.replay")
	# loadReplay("user://replays/Champion's Track_mogyi-02-01-288_2023-12-13.replay")
	# loadReplay("user://replays/Experimental #1_mogyi-00-25-029_2023-12-13.replay")
	# loadReplay("user://replays/Champion's Track_mogyi-02-01-569_2023-12-13.replay")

	# var cam = FollowingCamera.new(carController)
	# cam.current = true
	# add_child(cam)

	set_physics_process(true)

var currentIndex: int = 0
var currentFraction: float = 0.0
func _physics_process(_delta):
	if playing:
		if frame < frameData.size() - 1:
			currentIndex = int(frame)
			currentFraction = frame - currentIndex

			var currentFrame = frameData[currentIndex]
			var nextFrame = frameData[currentIndex + 1]

			carController.global_position = lerp(currentFrame[0], nextFrame[0], currentFraction)
			carController.global_rotation = lerp(currentFrame[1], nextFrame[1], currentFraction)
			carController.linear_velocity = (currentFrame[0] - nextFrame[0]) * (1 / _delta) 
			frame += timeScale
	else:
		carController.linear_velocity = Vector3.ZERO
		var currentFrame = frameData[currentIndex]
		var nextFrame = frameData[currentIndex + 1]

		carController.global_position = lerp(currentFrame[0], nextFrame[0], currentFraction)
		carController.global_rotation = lerp(currentFrame[1], nextFrame[1], currentFraction)

		# else:
		# 	frame = 0

func loadReplay(fileName: String):
	var path = "user://replays/" + fileName
	var fileHandler = FileAccess.open(path, FileAccess.READ)
	if fileHandler == null:
		print("Error opening replay file ", path)
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

	var nrFrames = fileHandler.get_line().to_int()

	if fileHandler.get_line() != "REPLAY_BEGIN":
		print("Error reading replay file ", path)
		return
	# var replayPosRot = fileHandler.get_csv_line()
	var pos: Vector3 = Vector3.ZERO
	var rot: Vector3 = Vector3.ZERO
	frameData.clear()
	for i in nrFrames:
		# frameData.append([
		# 	Vector3(
		# 		fileHandler.get_float(),
		# 		fileHandler.get_float(),
		# 		fileHandler.get_float()
		# 	),
		# 	Vector3(
		# 		fileHandler.get_float(),
		# 		fileHandler.get_float(),
		# 		fileHandler.get_float()
		# 	)
		# ])
		pos.x = fileHandler.get_float()
		pos.y = fileHandler.get_float()
		pos.z = fileHandler.get_float()

		rot.x = fileHandler.get_float()
		rot.y = fileHandler.get_float()
		rot.z = fileHandler.get_float()

		frameData.append([pos, rot])
	# while replayPosRot[0] != "REPLAY_END":
	# 	frameData.append([
	# 		Vector3(
	# 			replayPosRot[0].to_float(),
	# 			replayPosRot[1].to_float(),
	# 			replayPosRot[2].to_float()
	# 		),
	# 		Vector3(
	# 			replayPosRot[3].to_float(),
	# 			replayPosRot[4].to_float(),
	# 			replayPosRot[5].to_float()
	# 		)
	# 	])
	if fileHandler.get_line() != "REPLAY_END":
		print("Error reading replay file ", fileName)
		return
	# 	replayPosRot = fileHandler.get_csv_line()
	# playing = true
	
	fileHandler.close()

func stopReplay():
	playing = false
	frame = 0
	carController.global_position = frameData[0][0]
	carController.global_rotation = frameData[0][1]
	carController.linear_velocity = Vector3.ZERO
	# carController.setGhostMode(false)

func startReplay():
	playing = true
	frame = 0
