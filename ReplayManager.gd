extends Node
class_name ReplayManager

var recording: bool = false

var cars: Array[CarController] = []

var frames: Array = []

func _ready():
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("user://replays"):
		dir.make_dir("user://replays")

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
# mapId
# nrCars
# CarMetaData (name, color) x nrCars
# times (ticks) x nrCars
# FrameData ('REPLAY_BEGIN', position.xyz, rotation.xyz, 'REPLAY_END') x nrFrames

func saveRecording(times: Array[int], mapId: String, mapName: String):
	stopRecording()
	var path = "user://replays/" + mapName + "_"
	for i in cars.size():
		path += cars[i].playerName + '-' + IngameHUD.getTimeStringFromTicks(times[i]).replace(":", "-") + '_'
	path += str(Time.get_datetime_string_from_system()).split("T")[0]
	path += ".replay"

	print("Saving replay to " + path)

	var fileHandler = FileAccess.open(path, FileAccess.WRITE)
	if fileHandler == null:
		print("Error opening replay file to save into")
		return
	
	fileHandler.store_line(mapId)
	fileHandler.store_line(str(cars.size()))

	for i in cars.size():
		fileHandler.store_csv_line([cars[i].playerName, cars[i].frameColor.to_html()])

	for i in cars.size():
		fileHandler.store_line(str(times[i]))
	
	fileHandler.store_line(str(frames[0].size()))

	for replay in frames:
		fileHandler.store_line("REPLAY_BEGIN")
		for frame in replay:
# 			fileHandler.store_csv_line([
# 				frame.position.x,
# 				frame.position.y,
# 				frame.position.z,
# 				frame.rotation.x,
# 				frame.rotation.y,
# 				frame.rotation.z
# 			])
			fileHandler.store_float(frame.position.x)
			fileHandler.store_float(frame.position.y)
			fileHandler.store_float(frame.position.z)
			fileHandler.store_float(frame.rotation.x)
			fileHandler.store_float(frame.rotation.y)
			fileHandler.store_float(frame.rotation.z)
		fileHandler.store_line("REPLAY_END")
	
	fileHandler.close()

		