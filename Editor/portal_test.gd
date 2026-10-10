extends Node3D

var current_camera: Camera3D

@onready var portals_parent: Node3D = %Portals
@onready var car_controller: CarController = %CarController
@onready var free_fly_camera: Camera3D = %Camera3D
@onready var car_copies_parent: Node3D = %CarCopies

var carCamera: FollowingCamera
var state: bool = false

var car_copy: CuttableCarModel

func _ready() -> void:
	set_physics_process(true)
	carCamera = FollowingCamera.new(car_controller)
	add_child(carCamera)
	move_child(carCamera, 0)

	car_copy = car_controller.car_model.get_duplicate()
	car_copies_parent.add_child(car_copy)
	car_copy.set_frame_color(Color.PINK)
	car_copy.visible = false


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
	for portal: FunctionalPortal in portals_parent.get_children():
		portal.set_remote_camera(current_camera)
	pass
