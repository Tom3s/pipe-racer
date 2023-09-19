extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	text = GlobalProperties.PLAYER_NAME
	text_changed.connect(onTextChanged)

func onTextChanged(newText: String) -> void:
	if newText != "" && newText != "Tom3s":
		GlobalProperties.PLAYER_NAME = newText
