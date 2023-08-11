extends Area3D

signal bodyEnteredCheckpoint(body: Node3D, checkpoint: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(onBodyEntered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func onBodyEntered(body):
	# emit_signal("bodyEnteredCheckpoint", body, self)
	bodyEnteredCheckpoint.emit(body, self)

var placements: Array = []

func getPlacement(lapNumber: int) -> int:
	if placements.size() <= lapNumber:
		placements.push_back(0)
	
	placements[lapNumber] += 1
	return placements[lapNumber]

func reset():
	placements = []
	
