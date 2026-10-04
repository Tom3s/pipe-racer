extends Node3D
class_name Portal

@onready var portal_camera: Camera3D = %PortalCamera
@onready var portal_viewport: SubViewport = %PortalViewport
@onready var portal_surface: MeshInstance3D = %PortalSurface
@onready var detection_area: Area3D = %DetectionArea
@onready var csgs: Node3D = %CSGS

@export
var linked_portal: Portal
			

@export
var portal_color: Color

# @export_tool_button()

var travelers: Dictionary[Node3D, Transform3D]

signal passed_portal_surface(body: Node3D)

func _ready() -> void:
	detection_area.body_entered.connect(func (body: Node3D) -> void:
		travelers[body] = body.global_transform
		print("[%s] Body entered portal detection area!" % str(name))

	)

	detection_area.body_exited.connect(func (body: Node3D) -> void:
		if travelers.has(body):
			travelers.erase(body)
		print("[%s] Body exited portal detection area!" % str(name))
	)

	set_colors()

	portal_surface.material_override = portal_surface.material_override.duplicate()

func _physics_process(delta: float) -> void:
	# var marked_to_remove: Array[Node3D] = []

	for traveler: Node3D in travelers.keys():
		var current_transform: Transform3D = traveler.global_transform
		var last_frame_transform: Transform3D = travelers[traveler]

		var current_offset := global_transform.affine_inverse() * current_transform
		var last_offset := global_transform.affine_inverse() * last_frame_transform

		# print(current_offset.origin.z)
		if current_offset.origin.z * last_offset.origin.z < 0:
			print("[%s] Body passed through portal surface" % str(name))
			passed_portal_surface.emit(traveler)

			if traveler.has_method("set_new_transform"):
				# linked_portal.global_transform * relative_transform
				# traveler.set_new_transform(linked_portal.global_transform, current_offset)
				traveler.set_new_transform(global_transform, linked_portal.global_transform, current_offset)

				# marked_to_remove.push_back(traveler)	
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
	var camera_texture := linked_portal.portal_viewport.get_texture()
	portal_surface.material_override.set_shader_parameter("viewport_texture", camera_texture)

func set_colors() -> void:
	for child in csgs.get_children():
		child.material_override = StandardMaterial3D.new()
		child.material_override.albedo_color = portal_color
