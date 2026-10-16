extends Node3D

@onready var translator: Translator = %Translator
@onready var translatorInputHandler: TranslatorInputHandler = %TranslatorInputHandler

var capturedGizmo: Node3D = null

var gizmoCenter: Vector2 = Vector2.ZERO
var moveAxis: Vector3 = Vector3.ZERO

var lastMousePos: Vector2 = Vector2.ZERO

var currentNode: Node3D = null

func _ready():
	translatorInputHandler.clickStarted.connect(func(newGizmo: Node3D):
		capturedGizmo = newGizmo
		if capturedGizmo != null && capturedGizmo.has_method("capture"):
			capturedGizmo.capture()
			gizmoCenter = capturedGizmo.getCenterPoint()
			moveAxis = capturedGizmo.moveAxis
			lastMousePos = get_viewport().get_mouse_position()
	)

	translatorInputHandler.clickEnded.connect(func():
		if capturedGizmo != null && capturedGizmo.has_method("release"):
			capturedGizmo.release()
		gizmoCenter = Vector2.ZERO
		moveAxis = Vector3.ZERO
		capturedGizmo = null
	)

	translatorInputHandler.mouseMovedOnScreen.connect(func(mousePos: Vector2):
		# handle mouse movement
		handleMouseMovement(mousePos)
	)
	
	currentNode = %RoadMeshGenerator.startNode

	translator.positionChanged.connect(func(newPos: Vector3):
		if currentNode != null:
			currentNode.global_position = newPos
	)


@export
var MOVE_SPEED: float = 1

const MOVE_SNAP = PrefabConstants.GRID_SIZE

var moveTreshold: float = 5


func handleMouseMovement(mousePos: Vector2):
	if capturedGizmo == null:
		return
	
	var delta = mousePos - lastMousePos
	if delta.length() < moveTreshold:
		return
	
	# var angleX = delta.x * ROTATION_STRENGTH
	# if mousePos.y < gizmoCenter.y:
	# 	angleX = -angleX
	
	# var angleY = delta.y * ROTATION_STRENGTH
	# if mousePos.x > gizmoCenter.x:
	# 	angleY = -angleY
	
	# var angle = angleX + angleY

	# angle = round(angle / ROTATION_SNAP) * ROTATION_SNAP

	# capturedGizmo.rotateGizmo(angle)

	var move = delta * MOVE_SPEED

	if moveAxis.y == 1:
		move.x = 0
	else:
		move.y = 0
	
	move = round(move / MOVE_SNAP) * MOVE_SNAP

	capturedGizmo.moveGizmo(move.x - move.y)

	lastMousePos = mousePos