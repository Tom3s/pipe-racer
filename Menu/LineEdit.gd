extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	text = Playerstats.PLAYER_NAME
	text_changed.connect(onTextChanged)

func onTextChanged(newText: String) -> void:
	if newText != "" && newText != "Tom3s":
		Playerstats.PLAYER_NAME = newText
