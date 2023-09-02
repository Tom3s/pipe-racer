extends Node
class_name RaceStateMachine

var nrPlayers: int
var finishedPlayers: int = 0
var readyPlayers: Array[bool] = []

var pausedBy: int = -1

var raceStarted: bool = false

signal allPlayersReady()
signal allPlayersFinished()

func newPlayerFinished():
	finishedPlayers += 1
	if finishedPlayers == nrPlayers:
		allPlayersFinished.emit()

func setupReadyPlayersList():
	readyPlayers.clear()
	for i in nrPlayers:
		readyPlayers.append(false)

func setPlayerReady(playerId: int):
	if readyPlayers[playerId]:
		return
	readyPlayers[playerId] = true
	if areAllPlayersReady():
		allPlayersReady.emit()

func areAllPlayersReady():
	for readyPlayer in readyPlayers:
		if !readyPlayer:
			return false
	return true
func reset():
	finishedPlayers = 0
	setupReadyPlayersList()
	raceStarted = false
	pausedBy = -1