extends Node3D


func _ready():
	var carSpawner = %CarSpawner


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	for child in get_children():
		child.reset()
