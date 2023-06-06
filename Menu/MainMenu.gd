extends Control


func _ready():
	%PlayOnline.button_up.connect(onPlayOnlinePressed)
	%PlayLocal.button_up.connect(onPlayLocalPressed)

func onPlayLocalPressed():
	var spawner: CarSpawner = get_parent().get_node("%CarSpawner")
	var nrPlayers: int = %SelectNrPlayers.selected + 1
	spawner.spawnForLocalGame(nrPlayers)
	%SelectMode.hide()

func onPlayOnlinePressed():
	get_parent().get_node("%NetworkSetup/%MultiplayerConfig").show()
	%SelectMode.hide()