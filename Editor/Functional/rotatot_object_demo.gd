extends Node3D

@onready var rotator: Rotator = %Rotator
@onready var rotatorInputHandler: RotatorInputHandler = %RotatorInputHandler

var capturedGizmo: Node3D = null

var gizmoCenter: Vector2 = Vector2.ZERO
var rotationAxis: Vector3 = Vector3.ZERO

var lastMousePos: Vector2 = Vector2.ZERO

var currentNode: Node3D = null

func _ready():
	rotatorInputHandler.clickStarted.connect(func(newGizmo: Node3D): 
		capturedGizmo = newGizmo
		if capturedGizmo != null && capturedGizmo.has_method("capture"):
			capturedGizmo.capture()
			gizmoCenter = capturedGizmo.getCenterPoint()
			rotationAxis = capturedGizmo.rotationAxis

	)

	rotatorInputHandler.clickEnded.connect(func():
		if capturedGizmo != null && capturedGizmo.has_method("release"):
			capturedGizmo.release()
		gizmoCenter = Vector2.ZERO
		rotationAxis = Vector3.ZERO
		capturedGizmo = null
	)

	rotatorInputHandler.mouseMovedOnScreen.connect(func(mousePos: Vector2):
		# handle mouse movement
		handleMouseMovement(mousePos)
	)
	
	currentNode = %RoadMeshGenerator.startNode

	rotator.rotationChanged.connect(func(newRotation: Vector3):
		if currentNode != null:
			currentNode.rotation = newRotation
	)

@export
var ROTATION_STRENGTH: float = 0.01

const ROTATION_SNAP = deg_to_rad(5)


var rotateTreshold: float = 5


func handleMouseMovement(mousePos: Vector2):
	if capturedGizmo == null:
		return
	
	var delta = mousePos - lastMousePos
	if delta.length() < rotateTreshold:
		return
	
	var angleX = delta.x * ROTATION_STRENGTH
	if mousePos.y < gizmoCenter.y:
		angleX = -angleX
	
	var angleY = delta.y * ROTATION_STRENGTH
	if mousePos.x > gizmoCenter.x:
		angleY = -angleY
	
	var angle = angleX + angleY

	angle = round(angle / ROTATION_SNAP) * ROTATION_SNAP

	capturedGizmo.rotateGizmo(angle)

	lastMousePos = mousePos
