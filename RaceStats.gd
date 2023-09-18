extends Node
class_name RaceStats

var track: String
var nrAttempts: int
var nrFinishes: int
var bestLap: int
var bestTime: int

var startTime: int

func _init(trackId: String):
	track = trackId
	nrAttempts = 0
	nrFinishes = 0
	bestLap = 365 * 24 * 60 * 60 * 1000
	bestTime = 365 * 24 * 60 * 60 * 1000

	startTime = floor(Time.get_unix_time_from_system() * 1000)

func getObject() -> Dictionary:
	var playtime = floor((Time.get_unix_time_from_system() * 1000) - startTime)
	var playtimeInMinutes = max(1, floor(playtime / 1000 / 60))
	var obj = {
		"track": track,
		"playtime": playtimeInMinutes,
		"nrAttempts": nrAttempts,
		"nrFinishes": nrFinishes,
		"bestLap": bestLap,
		"bestTime": bestTime,
	}

	print("[RaceStats.gd] Returning object: " + JSON.stringify(obj, "\t"))

	return obj

func increaseAttempts():
	nrAttempts += 1
	print("[RaceStats.gd] Increased attempts to " + str(nrAttempts))

func increaseFinishes():
	nrFinishes += 1
	print("[RaceStats.gd] Increased finishes to " + str(nrFinishes))

func setBestLap(lapTime: int):
	bestLap = min(bestLap, lapTime)
	print("[RaceStats.gd] Set best lap to " + str(bestLap))

func setBestTime(time: int):
	bestTime = min(bestTime, time)
	print("[RaceStats.gd] Set best time to " + str(bestTime))
