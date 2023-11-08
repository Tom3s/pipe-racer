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

@onready var leftPanel: PanelContainer = %LeftPanel
@onready var rightPanel: PanelContainer = %RightPanel
@onready var menuTitle: Label = %MenuTitle
@onready var bottomContainer: HBoxContainer = %BottomContainer


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

	nextButton.grab_focus()

	visibility_changed.connect(nextButton.grab_focus)

func _physics_process(delta):
	if (get_viewport().gui_get_focus_owner() == null || !get_viewport().gui_get_focus_owner().is_visible_in_tree()) && visible:
		# playButton.grab_focus()
		if Input.is_action_just_pressed("ui_left") || \
			Input.is_action_just_pressed("ui_right") || \
			Input.is_action_just_pressed("ui_up") || \
			Input.is_action_just_pressed("ui_down") || \
			Input.is_action_just_pressed("ui_accept") || \
			Input.is_action_just_pressed("ui_cancel"):
			nextButton.grab_focus()

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
	# visible = false
	await animateOut()
	nextPressed.emit(players)

func onBackButton_Pressed():
	# visible = false
	await animateOut()
	backPressed.emit()

func setNumberOfPlayers(number: int):
	for i in 4:
		if i < number:
			panels[i].visible = true
		else:
			panels[i].visible = false
	button1.selected = number == 1
	button2.selected = number == 2
	button3.selected = number == 3
	button4.selected = number == 4

func getMainPlayerPanel():
	return panels[0]

const ANIMATION_TIME = 0.3
const ANIMATION_DELAY = 0.05
func animateIn():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	var screenSize = get_viewport_rect().size

	tween.tween_property(leftPanel, "position", Vector2(-screenSize.x, 0), 0.0).as_relative()
	tween.tween_property(rightPanel, "position", Vector2(screenSize.x, 0), 0.0).as_relative()
	tween.tween_property(rightPanel, "inAnimation", true, 0.0)
	tween.tween_property(menuTitle, "position", Vector2(0, -screenSize.y), 0.0).as_relative()
	tween.tween_property(menuTitle, "inAnimation", true, 0.0)
	tween.tween_property(bottomContainer, "position", Vector2(0, screenSize.y), 0.0).as_relative()
	tween.tween_property(bottomContainer, "inAnimation", true, 0.0)

	tween.tween_property(self, "visible", true, 0.0)

	tween.set_parallel(true)

	tween.tween_property(leftPanel, "position", Vector2(screenSize.x, 0), ANIMATION_TIME).as_relative().set_delay(0 * ANIMATION_DELAY)
	tween.tween_property(rightPanel, "position", Vector2(-screenSize.x, 0), ANIMATION_TIME).as_relative().set_delay(1 * ANIMATION_DELAY)
	tween.tween_property(rightPanel, "inAnimation", false, ANIMATION_TIME).set_delay(1 * ANIMATION_DELAY)
	tween.tween_property(menuTitle, "position", Vector2(0, screenSize.y), ANIMATION_TIME).as_relative().set_delay(2 * ANIMATION_DELAY)
	tween.tween_property(menuTitle, "inAnimation", false, ANIMATION_TIME).set_delay(2 * ANIMATION_DELAY)
	tween.tween_property(bottomContainer, "position", Vector2(0, -screenSize.y), ANIMATION_TIME).as_relative().set_delay(3 * ANIMATION_DELAY)
	tween.tween_property(bottomContainer, "inAnimation", false, ANIMATION_TIME).set_delay(3 * ANIMATION_DELAY)
	tween.tween_callback(nextButton.grab_focus).set_delay(3 * ANIMATION_DELAY)

func animateOut():
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	var screenSize = get_viewport_rect().size
	
	tween.set_parallel(true)

	tween.tween_property(bottomContainer, "position", Vector2(0, screenSize.y), ANIMATION_TIME).as_relative().set_delay(0 * ANIMATION_DELAY)
	tween.tween_property(bottomContainer, "inAnimation", true, ANIMATION_TIME).set_delay(0 * ANIMATION_DELAY)
	tween.tween_property(menuTitle, "position", Vector2(0, -screenSize.y), ANIMATION_TIME).as_relative().set_delay(1 * ANIMATION_DELAY)
	tween.tween_property(menuTitle, "inAnimation", true, ANIMATION_TIME).set_delay(1 * ANIMATION_DELAY)
	tween.tween_property(rightPanel, "position", Vector2(screenSize.x, 0), ANIMATION_TIME).as_relative().set_delay(2 * ANIMATION_DELAY)
	tween.tween_property(rightPanel, "inAnimation", true, 0.0).set_delay(2 * ANIMATION_DELAY)
	tween.tween_property(leftPanel, "position", Vector2(-screenSize.x, 0), ANIMATION_TIME).as_relative().set_delay(3 * ANIMATION_DELAY)

	# await tween.finished
	# tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "visible", false, 0.0)


	tween.tween_property(leftPanel, "position", Vector2(screenSize.x, 0), 0.0).as_relative()
	tween.tween_property(rightPanel, "position", Vector2(-screenSize.x, 0), 0.0).as_relative()
	tween.tween_property(rightPanel, "inAnimation", false, 0.0)
	tween.tween_property(menuTitle, "position", Vector2(0, screenSize.y), 0.0).as_relative()
	tween.tween_property(menuTitle, "inAnimation", false, 0.0)
	tween.tween_property(bottomContainer, "position", Vector2(0, -screenSize.y), 0.0).as_relative()
	tween.tween_property(bottomContainer, "inAnimation", false, 0.0)

	return tween.finished