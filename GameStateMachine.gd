extends Node
class_name GameStateMachine

var nrPlayers: int
var nrLocalPlayers: int
var finishedPlayers: int = 0
var readyPlayers: Dictionary = {}
var resettingPlayers: Dictionary = {}

var pausedBy: int = -1

var raceStarted: bool = false

var ranked: bool = false
var online: bool = false

signal allPlayersReady()
signal allPlayersFinished()
signal allPlayersReset()
signal allPlayersSubmittedStats()

func reset(newNrPlayers: int):
	nrPlayers = newNrPlayers
	finishedPlayers = 0
	setupReadyPlayersList()
	setupResettingPlayersList()
	raceStarted = false
	pausedBy = -1

func setPlayerReady(playerIndex: int):
	if readyPlayers[playerIndex]:
		return
	readyPlayers[playerIndex] = true
	if areAllPlayersReady():
		allPlayersReady.emit()

func areAllPlayersReady():
	for key in readyPlayers:
		if !readyPlayers[key]:
			return false
	return true

func newPlayerFinished():
	finishedPlayers += 1
	if finishedPlayers >= nrPlayers:
		allPlayersFinished.emit()

func setPlayerReset(playerIndex: int, resetting: bool):
	resettingPlayers[playerIndex] = resetting
	if areAllPlayersResetting():
		allPlayersReset.emit()

func areAllPlayersResetting():
	for key in resettingPlayers:
		if !resettingPlayers[key]:
			return false
	return true

func setupReadyPlayersList():
	readyPlayers.clear()
	for i in nrPlayers:
		readyPlayers[i] = false

func setupResettingPlayersList():
	resettingPlayers.clear()
	for i in nrPlayers:
		resettingPlayers[i] = false