extends Control
class_name ControlsMenu

@onready var closeButton: Button = %CloseButton
@onready var keyboard: TextureRect = %Keyboard
@onready var controller: TextureRect = %Controller

func _ready():
	closeButton.pressed.connect(onCloseButton_pressed)
	closeButton.grab_focus()

	visibility_changed.connect(onVisibilityChanged)

signal closePressed()

func onCloseButton_pressed():
	closePressed.emit()
	visible = false

func onVisibilityChanged():
	if visible:
		closeButton.grab_focus()