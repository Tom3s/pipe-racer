extends ColorPickerButton


# Called when the node enters the scene tree for the first time.
func _ready():
	color = Playerstats.PLAYER_COLOR
	color_changed.connect(onColorChanged)

func onColorChanged(new_color):
	Playerstats.PLAYER_COLOR = new_color
