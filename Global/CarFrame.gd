extends Node
class_name CarFrame

var position: Vector3
var rotation: Vector3
var speed: float
var isBraking: bool
var isDrifting: bool
var isAirborne: bool
var impactTimer: int

func _init(
	initPos: Vector3, 
	initRot: Vector3, 
	initSpeed: float, 
	initIsBraking: bool, 
	initIsDrifting: bool,
	initIsAirborne: bool,
	initImpactTimer: int	
):
	position = initPos
	rotation = initRot
	speed = initSpeed
	isBraking = initIsBraking
	isDrifting = initIsDrifting
	isAirborne = initIsAirborne
	impactTimer = initImpactTimer

func getColor() -> Color:
	# return Color(
	# 	0.5 if isBraking else float(impactTimer) / CarStateMachine.DEFAULT_IMPACT_TIMER,
	# 	1.0 - float(impactTimer) / CarStateMachine.DEFAULT_IMPACT_TIMER,
	# 	1.0 if isBraking else 0.0
	# )

	# if !isBraking and !isDrifting and impactTimer <= 0:
	# 	return lerp(Color.ORANGE_RED, Color.GREEN, speed / 320.0)

	var defColor = lerp(Color.ORANGE_RED, Color.GREEN, speed / 320.0)


	if isBraking || isDrifting:
		defColor = Color.BLACK
		defColor.r = 1.0 if isBraking else 0.0
		defColor.b = 1.0 if isDrifting else 0.0
	if impactTimer > 0:
		defColor.r = min(defColor.r, 1.0 - float(impactTimer) / CarStateMachine.DEFAULT_IMPACT_TIMER)
		defColor.g = min(defColor.g, 1.0 - float(impactTimer) / CarStateMachine.DEFAULT_IMPACT_TIMER)
		defColor.b = min(defColor.b, 1.0 - float(impactTimer) / CarStateMachine.DEFAULT_IMPACT_TIMER)
	
	return defColor