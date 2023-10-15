extends MultiplayerSynchronizer
class_name CarSynchronizer
# linear_velocity
# angular_velocity
# global_position
# global_rotation

@export
var linear_velocity: Vector3:
	set(newValue):
		if get_parent().is_multiplayer_authority():
			linear_velocity = newValue
		else:
			get_parent().linear_velocity = lerp(get_parent().linear_velocity, newValue, Network.LAG_COMPENSATION)

@export
var angular_velocity: Vector3:
	set(newValue):
		if get_parent().is_multiplayer_authority():
			angular_velocity = newValue
		else:
			get_parent().angular_velocity = lerp(get_parent().angular_velocity, newValue, Network.LAG_COMPENSATION)

@export
var global_position: Vector3:
	set(newValue):
		if get_parent().is_multiplayer_authority():
			global_position = newValue
		else:
			get_parent().global_position = lerp(get_parent().global_position, newValue, Network.LAG_COMPENSATION)

@export
var global_rotation: Vector3:
	set(newValue):
		if get_parent().is_multiplayer_authority():
			global_rotation = newValue
		else:
			get_parent().global_rotation = lerp(get_parent().global_rotation, newValue, Network.LAG_COMPENSATION)

@export
var networkId: int = 0:
	set(newValue):
		networkId = newValue
		get_parent().networkId = newValue
	
@export
var respawnPosition: Vector3 = Vector3(0, 0, 0):
	set(newValue):
		respawnPosition = newValue
		get_parent().respawnPosition = newValue

@export
var respawnRotation: Vector3 = Vector3(0, 0, 0):
	set(newValue):
		respawnRotation = newValue
		get_parent().respawnRotation = newValue