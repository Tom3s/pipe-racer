extends Label

class_name DebugLabel

var debugRows: Array[Callable]

@export
var enabled: bool = false

func _ready():
	addFunctionToDisplay(Callable(%CarController, "getDebugContactPointString"))
	addFunctionToDisplay(Callable(%CarController, "getDebugTireDirectionsString"))	

func _process(delta):
	if not enabled:
		text = ''
		return
	var debugText: String = 'FPS: ' + str(Engine.get_frames_per_second()) + '\n'
	for function in debugRows:
		debugText += function.call() + '\n'
	text = debugText

func addFunctionToDisplay(textFunction: Callable):
	debugRows.append(textFunction)

func toggleDebugScreen():
	enabled = !enabled
