extends Node3D

@onready var scenery: EditableScenery = %EditableScenery
@onready var dynamicSky: DynamicSky = %DynamicSky

@onready var sceneryEditorInputHandler: SceneryEditorInputHandler = %SceneryEditorInputHandler

@onready var sceneryEditorUI: SceneryEditorUI = %SceneryEditorUI

var lastVertexIndex: Vector2i = Vector2i(-1, -1)

@export_range(1, 15, 1)
var selectionSize: int = 1

var carCamera: FollowingCamera

var state: bool = false

var direction: int = 1

var mode: int = SceneryEditorUI.NORMAL_MODE

var flattenHeight: float = 0.0

func _ready():
	sceneryEditorInputHandler.mouseMovedTo.connect(func(pos: Vector3, placePressed: bool):
		if pos != Vector3.INF:
			var newVertexIndex = scenery.getClosestVertex(pos)

			if newVertexIndex != lastVertexIndex && placePressed:
				if mode == SceneryEditorUI.NORMAL_MODE:
					scenery.moveVertex(newVertexIndex, direction, selectionSize)
				elif mode == SceneryEditorUI.FLATTEN_MODE:
					scenery.flattenAtVertex(newVertexIndex, flattenHeight, selectionSize)
					

			lastVertexIndex = newVertexIndex
			scenery.setSelection(true, lastVertexIndex, selectionSize)
		else:
			lastVertexIndex = Vector2i(-1, -1)
			scenery.setSelection(false, lastVertexIndex, selectionSize)
	)

	# sceneryEditorInputHandler.moveUpGrid.connect(func():
	# 	if lastVertexIndex != Vector2i(-1, -1):
	# 		scenery.moveVertex(lastVertexIndex, 1, selectionSize)
	# )

	# sceneryEditorInputHandler.moveDownGrid.connect(func():
	# 	if lastVertexIndex != Vector2i(-1, -1):
	# 		scenery.moveVertex(lastVertexIndex, -1, selectionSize)
	# )

	sceneryEditorInputHandler.placePressed.connect(func():
		if lastVertexIndex != Vector2i(-1, -1):
			# scenery.moveVertex(lastVertexIndex, direction, selectionSize)
			if mode == SceneryEditorUI.NORMAL_MODE:
				scenery.moveVertex(lastVertexIndex, direction, selectionSize)
			elif mode == SceneryEditorUI.FLATTEN_MODE:
				flattenHeight = scenery.vertexHeights.getHeight(lastVertexIndex.y, lastVertexIndex.x)
				scenery.flattenAtVertex(lastVertexIndex, flattenHeight, selectionSize)
	)

	# %CarCamera.setup(%Car)
	carCamera = FollowingCamera.new(%Car)
	add_child(carCamera)
	
	sceneryEditorInputHandler.pausePressed.connect(func(_paused):
		state = !state
		if state:
			carCamera.current = true
			%Car.state.hasControl = true
			%Car.state.isReady = true
			sceneryEditorUI.hide()
		else:
			%Camera3D.current = true
			%Car.state.hasControl = false
			sceneryEditorUI.show()
	)

	sceneryEditorUI.timeChanged.connect(func(time: float):
		dynamicSky.day_time = time
	)

	sceneryEditorUI.brushSizeChanged.connect(func(size: int):
		selectionSize = size
		if lastVertexIndex != Vector2i(-1, -1):
			scenery.setSelection(true, lastVertexIndex, selectionSize)
	)

	sceneryEditorUI.directionChanged.connect(func(dir: int):
		direction = dir
	)

	sceneryEditorUI.modeChanged.connect(func(_mode: int):
		mode = _mode
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
