extends Node
class_name RaceMapLoader

var raceIngame = preload("res://GameScene.tscn")

var raceNode: GameScene

@onready var onlineTrackContainer: OnlineTracksContainer = %OnlineTracksContainer
@onready var playerSelectorMenu: PlayerSelectorMenu # = %PlayerSelectorMenu
@onready var mapOverviewMenu: MapOverviewMenu = %MapOverviewMenu

var players: Array[PlayerData] = []

signal backPressed()

func _ready():
	# playerSelectorMenu.visible = true
	# mapLoader.visible = false
	# mapLoader.setEditorSelect(false)
	onlineTrackContainer.visible = false
	mapOverviewMenu.visible = false
	connectSignals()

func connectSignals():
	# playerSelectorMenu.backPressed.connect(onPlayerSelectorMenu_backPressed)
	# playerSelectorMenu.nextPressed.connect(onPlayerSelectorMenu_nextPressed)
	# mapLoader.backPressed.connect(onMapLoader_backPressed)
	# mapLoader.trackSelected.connect(onMapLoader_trackSelected)
	onlineTrackContainer.viewPressed.connect(onOnlineTrackContainer_viewPressed)
	onlineTrackContainer.backPressed.connect(onOnlineTrackContainer_backPressed)
	mapOverviewMenu.backPressed.connect(onMapOverviewMenu_backPressed)
	mapOverviewMenu.playPressed.connect(onMapOverviewMenu_trackSelected)

func onOnlineTrackContainer_viewPressed(trackId: String):
	mapOverviewMenu.visible = true
	mapOverviewMenu.init(trackId)

func onMapOverviewMenu_backPressed():
	mapOverviewMenu.visible = false
	onlineTrackContainer.visible = true

func onPlayerSelectorMenu_nextPressed(selectedPlayers: Array[PlayerData]):
	players = selectedPlayers
	Network.localData = players
	onlineTrackContainer.visible = true
	GlobalProperties.returnPlayerSelectorMenu(
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)

func onOnlineTrackContainer_backPressed():
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	# playerSelectorMenu.visible = true
	playerSelectorMenu.animateIn()
	

func onMapOverviewMenu_trackSelected(trackName: String):
	# var raceSettins = RaceSettings.new(trackName, trackName.begins_with("user://tracks/downloaded"))

	# for player in players:
		# raceSettins.addPlayer(player)
	
	# startRace(raceSettins)

	raceNode = raceIngame.instantiate()
	add_child(raceNode)
	raceNode.exitPressed.connect(onRace_exited)
	var success = raceNode.setup(trackName, trackName.begins_with("user://tracks/downloaded"))
	if !success:
		AlertManager.showAlert(
			self,
			"Error loading map",
			"Try updating the map to the new format, or download it again"
		)
		mapOverviewMenu.show()
	# raceNode.initializePlayers()

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
	# mapLoader.visible = true
	mapOverviewMenu.show()

func show():
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	# playerSelectorMenu.visible = true
	playerSelectorMenu.animateIn()


func hide():
	# mapLoader.visible = false
	mapOverviewMenu.visible = false
	onlineTrackContainer.visible = false
	if playerSelectorMenu != null:
		# playerSelectorMenu.visible = false
		await playerSelectorMenu.animateOut()
		GlobalProperties.returnPlayerSelectorMenu(
			onPlayerSelectorMenu_backPressed,
			onPlayerSelectorMenu_nextPressed
		)

func getMainPlayerPanel() -> PlayerPanel:
	return playerSelectorMenu.getMainPlayerPanel()
