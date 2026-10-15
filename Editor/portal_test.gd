extends Node3D

var current_camera: Camera3D

@onready var portals_parent: Node3D = %Portals
@onready var car_controller: CarController = %CarController
@onready var free_fly_camera: Camera3D = %Camera3D
@onready var car_copies_parent: Node3D = %CarCopies

@onready var skid_mark_placer: SkidMarkPlacer = %SkidMarkPlacer

var carCamera: FollowingCamera
var state: bool = false

var car_copy: CuttableCarModel

func _ready() -> void:
	set_physics_process(true)
	carCamera = FollowingCamera.new(car_controller)
	add_child(carCamera)
	move_child(carCamera, 0)

	car_controller.camera = carCamera

	free_fly_camera.manual_update = true
	carCamera.manual_update = true

	car_copy = car_controller.car_model.get_duplicate()
	car_copies_parent.add_child(car_copy)
	car_copy.set_frame_color(Color.PINK)
	car_copy.visible = false

	for skid_mark: SkidMark in car_controller.get_skidmarks():
		skid_mark_placer.init_skidmark(skid_mark)
		
		skid_mark.new_contact_point.connect(func(last_l: Vector3, last_r: Vector3, left: Vector3, right: Vector3) -> void:
			var should_draw: bool = car_controller.slidingFactor > 0.1 && car_controller.getSpeed() > 15

			# if should_draw && !skid_mark.drawing:
			# 	skid_mark_placer.begin_new_skidmark(skid_mark, left, right)
			# 	skid_mark.drawing = true
			# elif should_draw && skid_mark.drawing:
			# 	skid_mark_placer.continue_skidmark(skid_mark, left, right)
			# elif !should_draw && skid_mark.drawing:
			# 	skid_mark_placer.end_skidmark(skid_mark)
			# 	skid_mark.drawing = false
			if should_draw:
				skid_mark_placer.add_quad(skid_mark, last_l, last_r, left, right)

		)


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
	free_fly_camera._update_mouselook()
	free_fly_camera._update_movement(delta)
	carCamera.update_camera(delta)
	current_camera = get_viewport().get_camera_3d()
	for portal: FunctionalPortal in portals_parent.get_children():
		portal.set_remote_camera(current_camera)
	pass
