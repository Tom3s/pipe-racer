extends Node
class_name MenuSFX

@onready var menuHover: AudioStreamPlayer = %MenuHover
@onready var menuUnhover: AudioStreamPlayer = %MenuUnhover

func playMenuHover():
	menuHover.play()

func playMenuUnhover():
	menuUnhover.play()
