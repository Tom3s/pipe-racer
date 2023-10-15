extends Node
class_name RaceStateMachine

var nrPlayers: int
var finishedPlayers: int = 0
var readyPlayers: Array[bool] = []
var resettingPlayers: Array[bool] = []
var nrResetPlayers: int = 0

var pausedBy: int = -1

var raceStarted: bool = false

var ranked: bool = false
var online: bool = false

signal allPlayersReady()
signal allPlayersFinished()
signal allPlayersReset()
signal allPlayersSubmittedStats()

func newPlayerFinished():
	finishedPlayers += 1
	if finishedPlayers >= nrPlayers:
		allPlayersFinished.emit()

func setPlayerReset(playerId: int, resetting: bool):
	resettingPlayers[playerId] = resetting
	if areAllPlayersResetting():
		allPlayersReset.emit()


func areAllPlayersResetting():
	for resettingPlayer in resettingPlayers:
		if !resettingPlayer:
			return false
	return true

func setupReadyPlayersList():
	readyPlayers.clear()
	for i in nrPlayers:
		readyPlayers.append(false)

func setupResettingPlayersList():
	resettingPlayers.clear()
	for i in nrPlayers:
		resettingPlayers.append(false)


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
	setupResettingPlayersList()
	raceStarted = false
	pausedBy = -1
