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
	var shouldWaitForLoad = mapOverviewMenu.init(trackId)
	if shouldWaitForLoad:
		await mapOverviewMenu.loaded
	mapOverviewMenu.animateIn()

func onMapOverviewMenu_backPressed():
	onlineTrackContainer.animateIn()

func onPlayerSelectorMenu_nextPressed(selectedPlayers: Array[PlayerData]):
	players = selectedPlayers
	Network.localData = players
	onlineTrackContainer.animateIn()
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
	playerSelectorMenu.animateIn()
	

func onMapOverviewMenu_trackSelected(trackName: String):
	raceNode = raceIngame.instantiate()
	add_child(raceNode)
	raceNode.exitPressed.connect(onRace_exited)
	var success = raceNode.setup(
		trackName, 
		trackName.begins_with("user://tracks/downloaded"),
		false,
		false,
		mapOverviewMenu.localReplays,
		mapOverviewMenu.downloadedReplays,
		mapOverviewMenu.getTimeMultiplier(),
		mapOverviewMenu.personalBestTime,
		mapOverviewMenu.personalBestLap,
	)
	if !success:
		AlertManager.showAlert(
			self,
			"Error loading map",
			"Try updating the map to the new format, or download it again"
		)
		mapOverviewMenu.show()
		return
	
	# raceNode.addGhosts(mapOverviewMenu.localReplays, mapOverviewMenu.downloadedReplays)


func onPlayerSelectorMenu_backPressed():
	GlobalProperties.returnPlayerSelectorMenu(
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	backPressed.emit()

func onRace_exited():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	raceNode.queue_free()
	mapOverviewMenu.refreshMenu()
	mapOverviewMenu.animateIn()

func show():
	playerSelectorMenu = GlobalProperties.borrowPlayerSelectorMenu(
		self,
		onPlayerSelectorMenu_backPressed,
		onPlayerSelectorMenu_nextPressed
	)
	playerSelectorMenu.animateIn()


func hide():
	mapOverviewMenu.visible = false
	onlineTrackContainer.visible = false
	if playerSelectorMenu != null:
		await playerSelectorMenu.animateOut()
		GlobalProperties.returnPlayerSelectorMenu(
			onPlayerSelectorMenu_backPressed,
			onPlayerSelectorMenu_nextPressed
		)

func getMainPlayerPanel() -> PlayerPanel:
	return playerSelectorMenu.getMainPlayerPanel()
