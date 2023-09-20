extends Node
class_name EditorStats

	# user: Types.ObjectId;
	# editorTime: number;
	# placedTrackPieces: number;
	# placedCheckpoints: number;
	# placedProps: number;
	# placedAll?: number;

var placedTrackPieces: int
var placedCheckpoints: int
var placedProps: int
var nrTests: int

var startTime: int

func _init():
	placedTrackPieces = 0
	placedCheckpoints = 0
	placedProps = 0
	nrTests = 0

	startTime = floor(Time.get_unix_time_from_system() * 1000)

func getObject() -> Dictionary:
	var editorTime = floor((Time.get_unix_time_from_system() * 1000) - startTime)
	var editorTimeInMinutes = max(1, floor(editorTime / 1000 / 60))

	var obj = {
		"editorTime": editorTimeInMinutes,
		"placedTrackPieces": placedTrackPieces,
		"placedCheckpoints": placedCheckpoints,
		"placedProps": placedProps,
		"nrTests": nrTests,
	}

	return obj

func increasePlacedTrackPieces():
	placedTrackPieces += 1
	print("[EditorStats.gd] Incresed placedTrackPieces to ", placedTrackPieces)

func increasePlacedCheckpoints():
	placedCheckpoints += 1
	print("[EditorStats.gd] Incresed placedCheckpoints to ", placedCheckpoints)

func increasePlacedProps():
	placedProps += 1
	print("[EditorStats.gd] Incresed placedProps to ", placedProps)

func increaseNrTests():
	nrTests += 1
	print("[EditorStats.gd] Incresed nrTests to ", nrTests)