extends Control

func _ready():
	%RestartButton.button_up.connect(onRestartButton_pressed)
	%ResumeButton.button_up.connect(onResumeButton_pressed)
	%SettingsButton.button_up.connect(onSettingsButton_pressed)
	%ExitButton.button_up.connect(onExitButton_pressed)


func onRestartButton_pressed():
	var carSpawner = get_parent().get_node("%CarSpawner")
	for car in carSpawner.get_children():
		car.reset()
	carSpawner.finishedCars = 0
	get_parent().get_node("%UniversalCanvas/%Countdown").reset()
	get_parent().get_node("%UniversalCanvas/%Countdown").start_countdown()
	%Buttons.hide()

func onResumeButton_pressed():
	%Buttons.hide()

func onExitButton_pressed():
	for car in get_parent().get_node("%CarSpawner").get_children():
		car.queue_free()
	
	for viewport in get_parent().get_node("%VerticalSplitTop").get_children():
		viewport.queue_free()
	
	for viewport in get_parent().get_node("%VerticalSplitBottom").get_children():
		viewport.queue_free()
	
	%Buttons.hide()

	# get_tree().get_multiplayer().multiplayer_peer = null

	get_parent().get_node("%MainMenu/%SelectMode").show()
	get_parent().get_node("%MusicPlayer").playMenuMusic()

func onSettingsButton_pressed():
	get_parent().get_node("%SettingsMenu/%Elements").show()
