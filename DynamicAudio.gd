extends AudioStreamPlayer

var targetVolume = -60.0
var changeSpeed = 0.2

func _process(_delta):
	if abs(targetVolume - volume_db) > changeSpeed:
		volume_db += changeSpeed * sign(targetVolume - volume_db)
	else:
		volume_db = targetVolume

func fadeTo(newVolumeDB, speed):
	targetVolume = newVolumeDB
	changeSpeed = speed
