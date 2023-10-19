extends Node
class_name RaceMapLoader

var raceIngame = preload("res://GameScene.tscn")

var raceNode: GameScene

@onready var mapLoader: MapLoader = %MapLoader
@onready var playerSelectorMenu: PlayerSelectorMenu # = %PlayerSelectorMenu

var players: Array[PlayerData] = []

signal backPressed()

func _ready():
	# playerSelectorMenu.visible = true
	mapLoader.visible = false
	mapLoader.setEditorSelect(false)
	connectSignals()

func connectSignals():
	# playerSelectorMenu.backPressed.connect(onPlayerSelectorMenu_backPressed)
	# playerSelectorMenu.nextPressed.connect(onPlayerSelectorMenu_nextPressed)
	mapLoader.backPressed.connect(onMapLoader_backPressed)
	mapLoader.trackSelected.connect(onMapLoader_trackSelected)

func onPlayerSelectorMenu_nextPressed(selectedPlayers: Array[PlayerData]):
	players = selectedPlayers
	Network.localData = players
	mapLoader.visible = true
	GlobalProperties.returnPlayerSelectorMenu(
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)

func onMapLoader_backPressed():
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	playerSelectorMenu.visible = true
	

func onMapLoader_trackSelected(trackName: String):
	# var raceSettins = RaceSettings.new(trackName, trackName.begins_with("user://tracks/downloaded"))

	# for player in players:
		# raceSettins.addPlayer(player)
	
	# startRace(raceSettins)

	raceNode = raceIngame.instantiate()
	add_child(raceNode)
	raceNode.setup(trackName, trackName.begins_with("user://tracks/downloaded"))
	# raceNode.initializePlayers()
	raceNode.exitPressed.connect(onRace_exited)

func onPlayerSelectorMenu_backPressed():
	GlobalProperties.returnPlayerSelectorMenu(
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	backPressed.emit()

# func startRace(settings: RaceSettings):
# 	raceNode = raceIngame.instantiate()
# 	add_child(raceNode)
# 	raceNode.setup(settings)
# 	raceNode.exitPressed.connect(onRace_exited)


func onRace_exited():
	raceNode.queue_free()
	# playerSelectorMenu.visible = true
	mapLoader.visible = true

func show():
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	playerSelectorMenu.visible = true


func hide():
	mapLoader.visible = false
	if playerSelectorMenu != null:
		playerSelectorMenu.visible = false
		GlobalProperties.returnPlayerSelectorMenu(
			onPlayerSelectorMenu_backPressed,
			onPlayerSelectorMenu_nextPressed
		)

func getMainPlayerPanel() -> PlayerPanel:
	return playerSelectorMenu.getMainPlayerPanel()
