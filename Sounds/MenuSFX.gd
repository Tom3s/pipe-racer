extends Node
class_name MenuSFX

@onready var menuHover: AudioStreamPlayer = %MenuHover
@onready var menuUnhover: AudioStreamPlayer = %MenuUnhover

func playMenuHover():
	if menuHover != null:
		menuHover.play()

func playMenuUnhover():
	if menuUnhover != null:
		menuUnhover.play()
