extends Control


func _ready():
	%PlayOnline.button_up.connect(onPlayOnlinePressed)
	%PlayLocal.button_up.connect(onPlayLocalPressed)
	%ViewScores.button_up.connect(onViewScoresPressed)
	%Settings.button_up.connect(onSettingsPressed)

func onPlayLocalPressed():
	var spawner: CarSpawner = get_parent().get_node("%CarSpawner")
	var nrPlayers: int = %SelectNrPlayers.selected + 1
	spawner.spawnForLocalGame(nrPlayers)
	%SelectMode.hide()

func onPlayOnlinePressed():
	get_parent().get_node("%NetworkSetup/%MultiplayerConfig").show()
	%SelectMode.hide()

func onViewScoresPressed():
	get_parent().get_node("%LeaderboardUI/%List").show()

func onSettingsPressed():
	get_parent().get_node("%SettingsMenu/%Elements").show()
