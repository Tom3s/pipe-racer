extends Node3D
class_name ReplayGhost

# @onready var carController: CarController = %CarController
@onready var carScene := preload("res://CarController.tscn")

var frameData = []

var playing = false

var frame: float = 0.0

@export_range(0.1, 5.0, 0.1)
var timeScale: float = 1.0

var _nrCars: int = 0

func _ready():
	# loadReplay("user://replays/hagyma_mogyi-00-14-686_2023-12-12.replay")
	# loadReplay("user://replays/Flat Circuit_mogyi-02-15-497_2023-12-12.replay")
	# loadReplay("user://replays/Champion's Track_mogyi-02-01-288_2023-12-13.replay")
	# loadReplay("user://replays/Experimental #1_mogyi-00-25-029_2023-12-13.replay")
	# loadReplay("user://replays/Champion's Track_mogyi-02-01-569_2023-12-13.replay")

	# var cam = FollowingCamera.new(carController)
	# cam.current = true
	# add_child(cam)

	# frameData = []

	set_physics_process(true)

# currently: frameData[carIndex][frameIndex][0: position, 1: rotation]
# SOF format: frameData[frameIndex][carIndex][0: position, 1: rotation]

var currentIndex: int = 0
var currentFraction: float = 0.0
func _physics_process(_delta):
	if playing:
		if frameData.size() <= 0:
			return
		# if frame < frameData[0].size() - 1:
		currentIndex = int(frame)
		currentFraction = frame - currentIndex

		for i in get_child_count():
			if frameData.size() <= currentIndex + 2:
				continue
			# var currentFrame = frameData[i][currentIndex]
			# var nextFrame = frameData[i][currentIndex + 1]
			var currentFrame = frameData[currentIndex][i]
			var nextFrame = frameData[currentIndex + 1][i]

			if currentFrame[0] == null || nextFrame[0] == null:
				continue

			var carController = get_child(i)
			carController.global_position = lerp(currentFrame[0], nextFrame[0], currentFraction)
			carController.global_rotation = lerp(currentFrame[1], nextFrame[1], currentFraction)
			carController.linear_velocity = (nextFrame[0] - currentFrame[0]) * (1 / _delta) 
		if frame < getNrFrames() - 1:
			frame += timeScale
	else:
		for i in get_child_count():
			var carController = get_child(i)
			
			if frameData.size() <= currentIndex + 2:
				continue

			carController.linear_velocity = Vector3.ZERO
			# var currentFrame = frameData[i][currentIndex]
			# var nextFrame = frameData[i][currentIndex + 1]
			var currentFrame = frameData[currentIndex][i]
			var nextFrame = frameData[currentIndex + 1][i]

			if currentFrame[0] == null || nextFrame[0] == null:
				continue


			carController.global_position = lerp(currentFrame[0], nextFrame[0], currentFraction)
			carController.global_rotation = lerp(currentFrame[1], nextFrame[1], currentFraction)

		# else:
		# 	frame = 0

func loadReplay(fileName: String, clearReplays: bool = true, ghostMode: bool = true):
	# var path = "user://replays/" + fileName
	var fileHandler = FileAccess.open(fileName, FileAccess.READ)
	if fileHandler == null:
		print("Error opening replay file ", fileName)
		return
	
	var _mapName = fileHandler.get_line()
	# var nrCars = fileHandler.get_32()
	_nrCars = fileHandler.get_line().to_int()

	for i in _nrCars:
		var time = fileHandler.get_line().to_int()

	for i in _nrCars:
		var carMetadata = fileHandler.get_csv_line()
		var playerName = carMetadata[0]
		var playerColor = Color.from_string(carMetadata[1], Color.WHITE)
		var carController: CarController = carScene.instantiate()
		carController.collision_layer = 0
		carController.collision_mask = 1
		carController.continuous_cd = false
		carController.contact_monitor = false
		carController.max_contacts_reported = 6
		add_child(carController)
		carController.playerName = playerName
		carController.frameColor = playerColor
		if ghostMode:
			carController.setGhostMode(true)

	var nrFrames = fileHandler.get_line().to_int()



	var pos: Vector3 = Vector3.ZERO
	var rot: Vector3 = Vector3.ZERO
	if clearReplays:
		print("=================== Clearing replays ===================")
		frameData.clear()
	
	# print("Loading replay: ", frameData)

	for carIndex in _nrCars:
		if fileHandler.get_line() != "REPLAY_BEGIN":
			print("Error reading replay file (no REPLAY_BEGIN) ", fileName, " index ", carIndex)
			return
		# frameData.append([])
		for i in nrFrames:
			pos.x = fileHandler.get_float()
			pos.y = fileHandler.get_float()
			pos.z = fileHandler.get_float()

			rot.x = fileHandler.get_float()
			rot.y = fileHandler.get_float()
			rot.z = fileHandler.get_float()

			# frameData.back().append([pos, rot])

			if frameData.size() <= i:
				frameData.append([])
				if get_child_count() - _nrCars > 0:
					frameData[i].append([null, null])


			frameData[i].append([pos, rot])

		if fileHandler.get_line() != "REPLAY_END":
			print("Error reading replay file (no REPLAY_END) ", fileName, " index ", carIndex)
			return
	
	# adjust for shorter replays:
	var maxDataSize = 0
	for data in frameData:
		if data.size() > maxDataSize:
			maxDataSize = data.size()
		while data.size() < maxDataSize:
			data.append([null, null])			

	
	fileHandler.close()
	print("Replay loaded: ", fileName)
	print("Frames: ", frameData.back().size())

func stopReplay():
	playing = false
	frame = 0
	for i in get_child_count():
		var carController = get_child(i)
		# carController.global_position = frameData[i][0][0]
		# carController.global_rotation = frameData[i][0][1]
		carController.global_position = frameData[0][i][0]
		carController.global_rotation = frameData[0][i][1]
		carController.linear_velocity = Vector3.ZERO



func startReplay():
	playing = true
	frame = 0

func getNrFrames():
	# var maxFrames = 0
	# for i in frameData.size():
	# 	if frameData[i].size() > maxFrames:
	# 		maxFrames = frameData[i].size()
	# return maxFrames
	return frameData.size()

func getCar(index: int):
	if index >= get_child_count():
		return get_child(0)
	return get_child(index)

func clearReplays():
	frameData.clear()
	for i in get_child_count():
		get_child(i).queue_free()
	
func setLabelVisibility(visible: bool):
	for i in get_child_count():
		var car: CarController = get_child(i)
		car.setLabelVisibility(visible)