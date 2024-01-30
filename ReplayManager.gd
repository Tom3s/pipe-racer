extends Node
class_name ReplayManager

var recording: bool = false

var cars: Array[CarController] = []

var frames: Array = []

func _ready():
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("user://replays"):
		dir.make_dir("user://replays")
	if !dir.dir_exists("user://replays/downloaded"):
		dir.make_dir("user://replays/downloaded")

	set_physics_process(true)

func _physics_process(delta):
	if recording:
		for i in cars.size():
			frames[i].append(cars[i].getCurrentFrame())

func setCars(newCars: Array[CarController]):
	cars.clear()
	frames.clear()
	for car in newCars:
		cars.append(car)
		frames.append([])
	recording = false

func startRecording():
	recording = true
	for i in cars.size():
		frames[i].clear()

func stopRecording():
	recording = false

# Replay File Format:
# replayFormatVersion
# mapId, nrLaps, nrCheckpoints
# nrCars
# time (ms) x nrCars
# CarMetaData (name, color) x nrCars
# nrFrames x nrCars
# splitdata ('SPLIT_BEGIN', ('LAP_BEGIN', timestamp x nrCheckpoints, 'LAP_END') x nrLaps,'SPLIT_END') x nrCars
# FrameData ('REPLAY_BEGIN', (position.xyz, rotation.xyz) x nrFrames, 'REPLAY_END') x nrCars
const REPLAY_FORMAT_VERSION: int = 1
func saveRecording(
	car: CarController, 
	mapId: String,
	nrLaps: int,
	nrCheckpoints: int,
	time: int,
	splits: Array, 
	mapName: String
) -> String:
	# stopRecording()
	var path = "user://replays/" + mapName + "_"
	# for i in cars.size():
	path += car.playerName + '-' + IngameHUD.getTimeStringFromTicks(time).replace(":", "-") + '_'
	path += str(Time.get_datetime_string_from_system()).split("T")[0]
	path += ".replay"

	print("Saving replay to " + path)

	var fileHandler = FileAccess.open(path, FileAccess.WRITE)
	if fileHandler == null:
		print("Error opening replay file to save into")
		return ""
	
	fileHandler.store_8(REPLAY_FORMAT_VERSION)

	fileHandler.store_csv_line([mapId, nrLaps, nrCheckpoints])

	# fileHandler.store_16(cars.size())
	fileHandler.store_16(1)

	fileHandler.store_32(time)
	
	fileHandler.store_csv_line([car.playerName, car.frameColor.to_html()])
	
	fileHandler.store_32(frames[car.playerIndex].size())
	
	fileHandler.store_line("SPLIT_BEGIN")
	for lap in splits:
		fileHandler.store_line("LAP_BEGIN")
		for timestamp in lap:
			fileHandler.store_32(timestamp)
		fileHandler.store_line("LAP_END")
	fileHandler.store_line("SPLIT_END")

	# for replay in frames:
	fileHandler.store_line("REPLAY_BEGIN")
	for frame in frames[car.playerIndex]:
		fileHandler.store_float(frame.position.x)
		fileHandler.store_float(frame.position.y)
		fileHandler.store_float(frame.position.z)
		fileHandler.store_float(frame.rotation.x)
		fileHandler.store_float(frame.rotation.y)
		fileHandler.store_float(frame.rotation.z)
	fileHandler.store_line("REPLAY_END")
	
	fileHandler.close()

	return path

		
