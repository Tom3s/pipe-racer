extends Node
class_name RaceMapLoader

var raceIngame = preload("res://RaceIngame.tscn")

var raceNode: RaceIngame

@onready var mapLoader: MapLoader = %MapLoader
@onready var playerSelectorMenu: PlayerSelectorMenu = %PlayerSelectorMenu

var players: Array[PlayerData] = []

signal backPressed()

func _ready():
	playerSelectorMenu.visible = true
	mapLoader.visible = false
	mapLoader.showNewButton(false)
	connectSignals()

func connectSignals():
	playerSelectorMenu.nextPressed.connect(onPlayerSelectorMenu_nextPressed)
	mapLoader.backPressed.connect(onMapLoader_backPressed)
	mapLoader.trackSelected.connect(onMapLoader_trackSelected)
	playerSelectorMenu.backPressed.connect(onPlayerSelectorMenu_backPressed)

func onPlayerSelectorMenu_nextPressed(selectedPlayers: Array[PlayerData]):
	players = selectedPlayers
	mapLoader.visible = true

func onMapLoader_backPressed():
	playerSelectorMenu.visible = true

func onMapLoader_trackSelected(trackName: String):
	var raceSettins = RaceSettings.new(trackName)
	for player in players:
		raceSettins.addPlayer(player)
	
	startRace(raceSettins)

func onPlayerSelectorMenu_backPressed():
	backPressed.emit()

func startRace(settings: RaceSettings):
	raceNode = raceIngame.instantiate()
	add_child(raceNode)
	raceNode.setup(settings)
	raceNode.exitPressed.connect(onRace_exited)


func onRace_exited():
	raceNode.queue_free()
	# playerSelectorMenu.visible = true
	mapLoader.visible = true

func show():
	playerSelectorMenu.visible = true

func hide():
	mapLoader.visible = false
	playerSelectorMenu.visible = false