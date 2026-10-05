extends Node3D

var current_camera: Camera3D

@onready var portals_parent: Node3D = %Portals
@onready var car_controller: CarController = %CarController
@onready var free_fly_camera: Camera3D = %Camera3D

var carCamera: FollowingCamera
var state: bool = false

func _ready() -> void:
	carCamera = FollowingCamera.new(car_controller)
	add_child(carCamera)

func _physics_process(delta: float) -> void:
	# sceneryEditorInputHandler.pausePressed.connect(func(_paused):
	if Input.is_action_just_pressed("p1_pause"):
		state = !state
		if state:
			carCamera.current = true
			free_fly_camera.current = false
			car_controller.state.hasControl = true
			car_controller.state.isReady = true
		else:
			free_fly_camera.current = true
			carCamera.current = false
			car_controller.state.hasControl = false
	# )

func _process(delta: float) -> void:
	current_camera = get_viewport().get_camera_3d()

	for portal: Portal in portals_parent.get_children():
		portal.set_remote_camera(current_camera)