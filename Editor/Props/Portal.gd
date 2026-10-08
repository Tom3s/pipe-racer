extends Node3D
class_name Portal

@onready var portal_camera: Camera3D = %PortalCamera
@onready var portal_viewport: SubViewport = %PortalViewport
# @onready var portal_surface: MeshInstance3D%ProceduralPortal
@onready var procedural_portal: ProceduralPortal = %ProceduralPortal
@onready var detection_area: Area3D = %DetectionArea
@onready var csgs: Node3D = %CSGS

@onready var light1: AreaLight3D = %Light1
@onready var light2: AreaLight3D = %Light2
@onready var omni_light_3d: OmniLight3D = %OmniLight3D

@export
var linked_portal: Portal
			

@export
var portal_color: Color

# var portal_sur
# @export_tool_button()

var travelers: Dictionary[Node3D, Transform3D]

signal passed_portal_surface(body: Node3D)

func _ready() -> void:
	set_physics_process(true)

	detection_area.body_entered.connect(func (body: Node3D) -> void:
		travelers[body] = body.global_transform
		var offset := global_transform.affine_inverse() * body.global_transform
		body.car_model.set_cutting_plane(global_transform, -sign(offset.origin.z))
		body.car_copy_model.visible = true
		body.car_copy_model.set_cutting_plane(linked_portal.global_transform, sign(offset.origin.z))
		print("[%s] Body entered portal detection area!" % str(name))

	)

	detection_area.body_exited.connect(func (body: Node3D) -> void:
		if travelers.has(body):
			travelers.erase(body)
			if !linked_portal.travelers.has(body):
				body.car_model.reset_cutting_plane()
				body.car_copy_model.reset_cutting_plane()
				body.car_copy_model.visible = false
		print("[%s] Body exited portal detection area!" % str(name))
	)

	set_colors()

	procedural_portal.portal_surface.material_override = procedural_portal.portal_surface.material_override.duplicate()
	procedural_portal.portal_surface.material_override.next_pass = procedural_portal.portal_surface.material_override.next_pass.duplicate()


func _physics_process(delta: float) -> void:
	# var marked_to_remove: Array[Node3D] = []

	for traveler: Node3D in travelers.keys():
		var current_transform: Transform3D = traveler.global_transform
		var last_frame_transform: Transform3D = travelers[traveler]

		var current_offset := global_transform.affine_inverse() * current_transform
		var last_offset := global_transform.affine_inverse() * last_frame_transform

		traveler.car_copy_model.global_transform = linked_portal.global_transform * current_offset
		# print(current_offset.origin.z)
		if current_offset.origin.z * last_offset.origin.z < 0:
			print("[%s] Body passed through portal surface" % str(name))
			passed_portal_surface.emit(traveler)

			if traveler.has_method("set_new_transform"):
				# linked_portal.global_transform * relative_transform
				# traveler.set_new_transform(linked_portal.global_transform, current_offset)
				traveler.set_new_transform(global_transform, linked_portal.global_transform, current_offset)
				# marked_to_remove.push_back(traveler)	
				# traveler.car_model.reset_cutting_plane()
				# traveler.car_copy_model.reset_cutting_plane()
				# traveler.car_copy_model.visible = false
				traveler.car_model.set_cutting_plane(linked_portal.global_transform, -sign(current_offset.origin.z))
				traveler.car_copy_model.set_cutting_plane(global_transform, sign(current_offset.origin.z))
				travelers.erase(traveler)
				continue
		

		travelers[traveler] = traveler.global_transform
	
	# for marked in marked_to_remove:
	# 	travelers.erase(marked)

func set_remote_camera(camera: Camera3D) -> void:
	if linked_portal == null:
		print("Portal has no linked portal. Aborting set camera")
		return
	
	portal_camera.fov = camera.fov
	# var offset_position: Vector3 = camera.global_position - global_position
	# linked_portal.portal_camera.position = offset_position
	var relative_transform := global_transform.affine_inverse() * camera.global_transform
	linked_portal.portal_camera.global_transform = linked_portal.global_transform * relative_transform

	# portal_viewport.update

	# update the linked portals viewport, as that was moved by us
	# updating our own would delay the portal by 1 frame

	# await RenderingServer.frame_post_draw
	# linked_portal.portal_viewport.force_draw
	linked_portal.portal_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	RenderingServer.force_draw(false) 

	var camera_texture := linked_portal.portal_viewport.get_texture()
	procedural_portal.portal_surface.material_override.set_shader_parameter("viewport_texture", camera_texture)

func set_colors() -> void:
	# for child in csgs.get_children():
	# 	child.material_override = StandardMaterial3D.new()
	# 	child.material_override.albedo_color = portal_color
	procedural_portal.portal_color = portal_color

	procedural_portal.portal_surface.material_override.next_pass.set_shader_parameter("swirl_color", portal_color)

	light1.light_color = portal_color
	light2.light_color = portal_color
	omni_light_3d.light_color = portal_color

# func set_cutting_plane(car_controller: CarController, direction: float) -> void:
# 	car_controller.car_model.set_cutting_plane(global_transform, direction)

# func reset_cutting_plane(car_controller: CarController) -> void:
# 	car_controller.car_model.reset_cutting_plane()
