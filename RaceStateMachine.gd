extends Node
class_name RaceStateMachine

var nrPlayers: int
var finishedPlayers: int = 0
var readyPlayers: Array[bool] = []

signal allPlayersReady()
signal allPlayersFinished()

func newPlayerFinished():
	finishedPlayers += 1
	if finishedPlayers == nrPlayers:
		allPlayersFinished.emit()

func setupReadyPlayersList():
	for i in nrPlayers:
		readyPlayers.append(false)

func setPlayerReady(playerId: int):
	readyPlayers[playerId] = true
	if areAllPlayersReady():
		allPlayersReady.emit()

func areAllPlayersReady():
	for readyPlayer in readyPlayers:
		if !readyPlayer:
			return false
	return true
