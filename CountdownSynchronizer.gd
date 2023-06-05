extends MultiplayerSynchronizer

@export
var countdownStartTime: float:
	set(newCountdownStartTime):
		if is_multiplayer_authority():
			countdownStartTime = newCountdownStartTime
		else:
			get_parent().countdownStartTime = newCountdownStartTime

@export
var countdownTime: float:
	set(newCountdownTime):
		if is_multiplayer_authority():
			countdownTime = newCountdownTime
		else:
			get_parent().countdownTime = newCountdownTime

@export
var countingDown: bool:
	set(newCountingDown):
		if is_multiplayer_authority():
			countingDown = newCountingDown
		else:
			get_parent().countingDown = newCountingDown
