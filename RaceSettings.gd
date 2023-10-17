extends Node
class_name RaceSettings

var mapName: String

var ranked: bool

var online: bool

var nrLaps: int

func _init(initialMapName, initialRanked = false, initialOnline = false, initialNrLaps = -1):
	mapName = initialMapName
	nrLaps = initialNrLaps
	ranked = initialRanked
	online = initialOnline

