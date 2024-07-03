extends Camera3D
class_name EditorCamera

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 3.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 80

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false


signal mouseCaptureExited()
signal positionChanged(position: Vector3)

func _ready():
	global_position = Vector3.UP * 128

var inputEnabled = true
func _unhandled_input(event):
	if !inputEnabled:
		return
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.is_action_pressed("editor_look_around") else Input.MOUSE_MODE_VISIBLE)
	mouseCaptured = Input.is_action_pressed("editor_look_around")

	if Input.is_action_just_released("editor_look_around"):
		mouseCaptureExited.emit()

	_w = Input.is_action_pressed("editor_move_forward")
	_s = Input.is_action_pressed("editor_move_backward")
	_a = Input.is_action_pressed("editor_move_left")
	_d = Input.is_action_pressed("editor_move_right")
	# _q = Input.is_action_pressed("editor_up")
	# _e = Input.is_action_pressed("editor_down")
	_shift = Input.is_action_pressed("editor_move_fast")

# Updates mouselook and movement every frame
func _process(delta):
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
var velocityLength = 0.0
var mouseCaptured = false
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(
		(_d as float) - (_a as float), 
		(_e as float) - (_q as float),
		(_s as float) - (_w as float)
	)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		if !mouseCaptured:
			# # Change velocity here to not move on global y axis
			# ...
			# translate(_velocity * delta * speed_multi)
			var globalVelocity = global_transform.basis * _velocity
			globalVelocity.y = 0
			global_position += globalVelocity * delta * speed_multi
			return 

		translate(_velocity * delta * speed_multi)

		positionChanged.emit(global_position)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# _mouse_position *= sensitivity
		_mouse_position *= GlobalProperties.MOUSE_SENSITIVITY / 100

		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))


func getPositionInFrontOfCamera(distance: float) -> Vector3:
	return global_position - global_transform.basis.z * distance

func getGridAlignedBasis() -> Basis:
	var gridAlignedBasis = global_transform.basis
	
	# relative x axis
	gridAlignedBasis.x.y = 0
	if abs(gridAlignedBasis.x.x) > abs(gridAlignedBasis.x.z):
		gridAlignedBasis.x.z = 0
	else:
		gridAlignedBasis.x.x = 0
	gridAlignedBasis.x = gridAlignedBasis.x.normalized()

	# constant y axis
	gridAlignedBasis.y = Vector3.UP

	gridAlignedBasis.z = gridAlignedBasis.x.cross(gridAlignedBasis.y)

	return gridAlignedBasis