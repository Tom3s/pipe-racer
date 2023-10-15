extends Node
class_name CarStateMachine

var groundedTires: Array[bool] = [false, false, false, false]
var collectedCheckpoints: Array[bool]
var collectedCheckpointCount: int = 0

@export
var hasControl: bool = false

var currentLap: int = -1
var nrLaps: int

var placement: int = 0

var isReady: bool = false

var isResetting: bool = false

var groundedTireCount: int = 0
func getGroundedTireCount() -> int:
	# return groundedTires[0] + groundedTires[1] + groundedTires[2] + groundedTires[3]
	groundedTireCount = 0
	groundedTireCount += int(groundedTires[0])
	groundedTireCount += int(groundedTires[1])
	groundedTireCount += int(groundedTires[2])
	groundedTireCount += int(groundedTires[3])

	return groundedTireCount


func isAirborne() -> bool:
	return !(groundedTires[0] || groundedTires[1] || groundedTires[2] || groundedTires[3])

# declaring variables to avoid reallocating memory
var aboutToJumpForward: bool = false
var aboutToJumpBackward: bool = false
func aboutToJump() -> bool:
	# return false
	
	aboutToJumpForward = !groundedTires[0] && !groundedTires[1] && (groundedTires[2] || groundedTires[3])
	aboutToJumpBackward = (groundedTires[0] || groundedTires[1]) && !groundedTires[2] && !groundedTires[3]
	return aboutToJumpForward || aboutToJumpBackward

func prepareCheckpointList(count: int):
	collectedCheckpoints.clear()
	for i in range(count):
		collectedCheckpoints.append(false)
	collectedCheckpointCount = 0

func clearCollectedCheckpoints():
	for i in range(collectedCheckpoints.size()):
		collectedCheckpoints[i] = false
	collectedCheckpointCount = 0

func collectCheckpoint(index: int) -> bool:
	var oldCheckpoint = collectedCheckpoints[index]
	collectedCheckpoints[index] = true
	if oldCheckpoint == false:
		collectedCheckpointCount += 1
	return oldCheckpoint

func hasCollectedAllCheckpoints() -> bool:
	return collectedCheckpointCount >= collectedCheckpoints.size()

func finishLap():
	currentLap += 1
	clearCollectedCheckpoints()
	if finisishedRacing():
		hasControl = false
		get_parent().resetInputs()
		get_parent().finishedRace.emit(get_parent().playerIndex)

func finisishedRacing() -> bool:
	return currentLap >= nrLaps

func setReadyTrue():
	isReady = true
	get_parent().isReady.emit(get_parent().playerIndex)

func reset(checkpointCount: int, playerIndex: int):
	prepareCheckpointList(checkpointCount)
	placement = playerIndex + 1
	isReady = false
	isResetting = false
	# hasControl = true

func setResetting():
	if !isReady:
		return
	isResetting = !isResetting
	get_parent().isResetting.emit(get_parent().playerIndex, isResetting)