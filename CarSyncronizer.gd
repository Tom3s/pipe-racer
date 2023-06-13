extends MultiplayerSynchronizer

@export
var position: Vector3:
	set(newPosition):
		if is_multiplayer_authority():
			position = newPosition
		else:
			get_parent().position = lerp(get_parent().position, newPosition, Network.LAG_COMPENSATION)

@export
var rotation: Vector3:
	set(newRotation):
		if is_multiplayer_authority():
			rotation = newRotation
		else:
			get_parent().rotation = lerp(get_parent().rotation, newRotation, Network.LAG_COMPENSATION)

@export
var linear_velocity: Vector3:
	set(newLinearVelocity):
		if is_multiplayer_authority():
			linear_velocity = newLinearVelocity
		else:
			get_parent().linear_velocity = lerp(get_parent().linear_velocity, newLinearVelocity, Network.LAG_COMPENSATION)

@export 
var angular_velocity: Vector3:
	set(newAngularVelocity):
		if is_multiplayer_authority():
			angular_velocity = newAngularVelocity
		else:
			get_parent().angular_velocity = lerp(get_parent().angular_velocity, newAngularVelocity, Network.LAG_COMPENSATION)

@export
var frameColor: Color:
	set(newFrameColor):
		if is_multiplayer_authority():
			frameColor = newFrameColor
		else:
			get_parent().frameColor = newFrameColor

@export
var timeTrialState: int:
	set(newTimeTrialState):
		if is_multiplayer_authority():
			timeTrialState = newTimeTrialState
		else:
			get_parent().timeTrialState = newTimeTrialState

@export
var respawnPosition: Vector3:
	set(newRespawnPosition):
		if is_multiplayer_authority():
			respawnPosition = newRespawnPosition
		else:
			get_parent().respawnPosition = newRespawnPosition

@export
var driftInput: float:
	set(newDriftInput):
		if is_multiplayer_authority():
			driftInput = newDriftInput
		else:
			get_parent().driftInput = newDriftInput

func _ready():
	set_physics_process(true)