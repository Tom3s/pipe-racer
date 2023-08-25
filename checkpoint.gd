extends Area3D

signal bodyEnteredCheckpoint(body: Node3D, checkpoint: Node3D)

func _ready():
	body_entered.connect(onBodyEntered)

func onBodyEntered(body):
	bodyEnteredCheckpoint.emit(body, self)

var placements: Array = []

func getPlacement(lapNumber: int) -> int:
	if placements.size() <= lapNumber:
		placements.push_back(0)
	
	placements[lapNumber] += 1
	return placements[lapNumber]

func reset():
	placements = []

func isCheckPoint():
	pass
