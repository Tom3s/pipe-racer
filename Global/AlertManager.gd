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

func showDeleteAlert(
	parent: Node,
	text: String,
	onDeleteConfirmed: Callable = func(): return,
	extraText: String = "",
):
	var alert = AcceptDialog.new()
	alert.title = "Confirm Delete"
	alert.dialog_text = text + "\n"
	if extraText != "":
		alert.dialog_text += extraText + "\n"
	alert.dialog_text += "This action cannot be undone"

	alert.add_cancel_button("No")
	alert.ok_button_text = "Yes"

	alert.confirmed.connect(onDeleteConfirmed)
	alert.close_requested.connect(alert.queue_free)

	parent.add_child(alert)
	alert.popup_centered()