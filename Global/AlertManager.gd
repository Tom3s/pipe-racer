extends Control

func _ready():
	theme = load("res://DarkTheme/Dark.theme")

func showAlert(parent: Node, title: String, text: String, response: String = ""):
	var alert = AcceptDialog.new()
	alert.title = title
	alert.dialog_text = text + "\n"
	alert.dialog_text += response
	alert.canceled.connect(alert.queue_free)
	parent.add_child(alert)
	alert.popup_centered()