extends Control
class_name PlayerSelectorMenu

var playerPanel = preload("res://PlayerPanel.tscn")

var panels: Array = []
var nrPlayers: int = 1

@onready var button1: Button = %Button1
@onready var button2: Button = %Button2
@onready var button3: Button = %Button3
@onready var button4: Button = %Button4

@onready var nextButton: Button = %NextButton
@onready var backButton: Button = %BackButton

@onready var panelHolder: VBoxContainer = %PanelHolder


signal nextPressed(players: Array[PlayerData])
signal backPressed()


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 4:
		var panel = playerPanel.instantiate()
		panels.append(panel)
		panelHolder.add_child(panel)
		panel.setRandomPlayerData()

	panels[0].setMainPlayerData()

	setNumberOfPlayers(1)

	button1.pressed.connect(onButton1_Pressed)
	button2.pressed.connect(onButton2_Pressed)
	button3.pressed.connect(onButton3_Pressed)
	button4.pressed.connect(onButton4_Pressed)

	nextButton.pressed.connect(onNextButton_Pressed)
	backButton.pressed.connect(onBackButton_Pressed)

func onButton1_Pressed():
	setNumberOfPlayers(1)
	# nrPlayers = 1

func onButton2_Pressed():
	setNumberOfPlayers(2)
	# nrPlayers = 2

func onButton3_Pressed():
	setNumberOfPlayers(3)
	# nrPlayers = 3

func onButton4_Pressed():
	setNumberOfPlayers(4)
	# nrPlayers = 4

func onNextButton_Pressed():
	var players: Array[PlayerData] = []
	for panel in panels:
		if panel.visible:
			players.append(panel.getPlayerData())
	visible = false
	nextPressed.emit(players)

func onBackButton_Pressed():
	visible = false
	backPressed.emit()
	pass

func setNumberOfPlayers(number: int):
	for i in 4:
		if i < number:
			panels[i].visible = true
		else:
			panels[i].visible = false

func getMainPlayerPanel():
	return panels[0]