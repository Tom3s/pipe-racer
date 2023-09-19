extends Control
class_name ControlsMenu

@onready var closeButton: Button = %CloseButton
@onready var keyboardButton: Button = %KeyboardButton
@onready var controllerButton: Button = %ControllerButton
@onready var keyboardDiagram: TextureRect = %KeyboardDiagram
@onready var controllerDiagram: TextureRect = %ControllerDiagram

func _ready():
	closeButton.pressed.connect(onCloseButton_pressed)
	keyboardButton.pressed.connect(onKeyboardButton_pressed)
	controllerButton.pressed.connect(onControllerButton_pressed)

	onKeyboardButton_pressed()

signal closePressed()

func onCloseButton_pressed():
	closePressed.emit()
	visible = false

func onKeyboardButton_pressed():
	keyboardDiagram.visible = true
	controllerDiagram.visible = false

func onControllerButton_pressed():
	keyboardDiagram.visible = false
	controllerDiagram.visible = true
