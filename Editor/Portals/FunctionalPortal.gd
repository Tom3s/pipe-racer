@tool
extends Node3D
class_name FunctionalPortal

static var idCounter: int = -1
var id: int
var linked_id: int = -1

@onready var portal_camera: Camera3D = %PortalCamera
@onready var portal_viewport: SubViewport = %PortalViewport
# @onready var portal_surface: MeshInstance3D%ProceduralPortal
@onready var procedural_portal: ProceduralPortal = %ProceduralPortal
@onready var detection_area: Area3D = %DetectionArea
@onready var detection_shape: CollisionShape3D = %DetectionShape
@onready var collider: StaticBody3D = %Collider

@onready var frame_left: CollisionShape3D = %FrameLeft
@onready var frame_right: CollisionShape3D = %FrameRight
@onready var frame_top: CollisionShape3D = %FrameTop
@onready var frame_bottom: CollisionShape3D = %FrameBottom

@onready var corner_tl: CollisionShape3D = %CornerTL
@onready var corner_tr: CollisionShape3D = %CornerTR
@onready var corner_bl: CollisionShape3D = %CornerBL
@onready var corner_br: CollisionShape3D = %CornerBR

@onready var base_left: CollisionShape3D = %BaseLeft
@onready var base_right: CollisionShape3D = %BaseRight
@onready var base_left_side: CollisionPolygon3D = %BaseLeftSide
@onready var base_right_side: CollisionPolygon3D = %BaseRightSide

@onready var arrow: CSGPolygon3D = %Arrow

@export
var linked_portal: FunctionalPortal
			


@export_range(8, 128, 1)
var width: int = 16:
	set(value):
		width = value
		if procedural_portal != null:
			procedural_portal.width = value

		set_collision_shape()

		if linked_portal != null && linked_portal.width != value:
			linked_portal.width = value

@export_range(8, 128, 1)
var height: int = 12:
	set(value):
		height = value
		if procedural_portal != null:
			procedural_portal.height = value

		set_collision_shape()

		if linked_portal != null && linked_portal.height != value:
			linked_portal.height = value

@export
var frame_color: Color = Color(0.831, 0.831, 0.831):
	set(value):
		frame_color = value
		if procedural_portal != null:
			procedural_portal.frame_color = value


@export
var rust_color: Color = Color(0.6, 0.212, 0.047):
	set(value):
		rust_color = value
		if procedural_portal != null:
			procedural_portal.rust_color = value


@export_range(0.0, 1.0, 0.1)
var rust_strength: float = 0.4:
	set(value):
		rust_strength = value
		if procedural_portal != null:
			procedural_portal.rust_strength = value


@export
var portal_color: Color = Color(0.0, 0.694, 0.749):
	set(value):
		portal_color = value
		if procedural_portal != null:
			procedural_portal.portal_color = value


@export
var use_bottom_frame: bool = false:
	set(value):
		use_bottom_frame = value
		if procedural_portal != null:
			procedural_portal.use_bottom_frame = value

		set_collision_shape()

@export
var corner_offset: float = 0.395:
	set(value):
		corner_offset = value
		set_collision_shape()

@export
var isPreview: bool = false:
	set(newValue):
		isPreview = newValue
		# arrow.visible
		enable_collision(!isPreview)


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

	# procedural_portal.portal_surface.material_override = procedural_portal.portal_surface.material_override.duplicate()
	# procedural_portal.portal_surface.material_override.next_pass = procedural_portal.portal_surface.material_override.next_pass.duplicate()

	set_collision_shape()
	set_visuals()

	FunctionalPortal.idCounter += 1
	id = FunctionalPortal.idCounter

	enable_collision(!isPreview)


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
	# linked_portal.portal_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	# RenderingServer.force_draw(false) 

	var camera_texture := linked_portal.portal_viewport.get_texture()
	procedural_portal.portal_surface.material_override.set_shader_parameter("viewport_texture", camera_texture)

func set_collision_shape() -> void:
	if !is_node_ready():
		return 
	
	detection_area.position.y = height / 2.0
	detection_shape.shape.size.x = width
	detection_shape.shape.size.y = height

	collider.position.y = height / 2.0

	frame_left.shape.size.y = height - 2
	frame_right.shape.size.y = height - 2

	frame_left.position.x = -width / 2.0 - 0.5
	frame_right.position.x = width / 2.0 + 0.5

	frame_top.shape.size.y = width - 2
	frame_top.position.y = height / 2.0 + 0.5
	
	frame_bottom.shape.size.y = width - 2
	frame_bottom.position.y = -height / 2.0 - 0.5

	corner_tl.position.x = -width / 2.0 + corner_offset
	corner_tl.position.y = height / 2.0 - corner_offset

	corner_tr.position.x =  width / 2.0 - corner_offset
	corner_tr.position.y = height / 2.0 - corner_offset
	
	corner_bl.position.x = -width / 2.0 + corner_offset
	corner_bl.position.y = -height / 2.0 + corner_offset
	
	corner_br.position.x =  width / 2.0 - corner_offset
	corner_br.position.y = -height / 2.0 + corner_offset

	base_left.position.x = -width / 2.0 - 0.5
	base_left.position.y = -height / 2.0 + 1.5

	base_right.position.x = width / 2.0 + 0.5
	base_right.position.y = -height / 2.0 + 1.5

	base_left_side.position.x = -width / 2.0
	base_right_side.position.x = width / 2.0
	base_left_side.position.y = -height / 2.0
	base_right_side.position.y = -height / 2.0

	frame_bottom.disabled = !use_bottom_frame || isPreview
	base_left.disabled = use_bottom_frame || isPreview
	base_right.disabled = use_bottom_frame || isPreview
	base_left_side.disabled = use_bottom_frame || isPreview
	base_right_side.disabled = use_bottom_frame || isPreview

func enable_collision(enabled: bool) -> void:
	if !is_node_ready():
		return 

	for child in collider.get_children():
		child.disabled = !enabled

	frame_bottom.disabled = !use_bottom_frame || !enabled
	base_left.disabled = use_bottom_frame || !enabled
	base_right.disabled = use_bottom_frame || !enabled
	base_left_side.disabled = use_bottom_frame || !enabled
	base_right_side.disabled = use_bottom_frame || !enabled

func set_visuals() -> void:
	procedural_portal.width = width
	procedural_portal.height = height
	procedural_portal.frame_color = frame_color
	procedural_portal.rust_color = rust_color
	procedural_portal.rust_strength = rust_strength
	procedural_portal.portal_color = portal_color
	procedural_portal.use_bottom_frame = use_bottom_frame

func setIngame(ingame: bool = true) -> void:
	%Arrow.visible = !ingame

# Data handling

func getProperties() -> Dictionary:
	return {
		"width": width,
		"height": height,
		"frame_color": frame_color,
		"rust_color": rust_color,
		"rust_strength": rust_strength,
		"portal_color": portal_color,
		"use_bottom_frame": use_bottom_frame,

		"position": global_position,
		"rotation": global_rotation,
	}

func setProperties(properties: Dictionary, setTransform: bool = true) -> void:
	if properties.has("width"):
		width = properties["width"]

	if properties.has("height"):
		height = properties["height"]

	if properties.has("frame_color"):
		frame_color = properties["frame_color"]

	if properties.has("rust_color"):
		rust_color = properties["rust_color"]

	if properties.has("rust_strength"):
		rust_strength = properties["rust_strength"]

	if properties.has("portal_color"):
		portal_color = properties["portal_color"]

	if properties.has("use_bottom_frame"):
		use_bottom_frame = properties["use_bottom_frame"]

	

	if setTransform:
		if properties.has("position"):
			global_position = properties["position"]
		if properties.has("rotation"):
			global_rotation = properties["rotation"]

func getExportData() -> Dictionary:
	var data = {
		"position": var_to_str(global_position),
		"rotation": var_to_str(global_rotation),
		"id": id,
	}

	if linked_portal != null:
		data["linked_id"] = linked_portal.id

	if width != 16:
		data["width"] = width

	if height != 12:
		data["height"] = height

	if frame_color != Color(0.831, 0.831, 0.831):
		data["frame_color"] = frame_color.to_html()

	if rust_color != Color(0.6, 0.212, 0.047):
		data["rust_color"] = rust_color.to_html()

	if rust_strength != 0.4:
		data["rust_strength"] = rust_strength

	if portal_color != Color(0.0, 0.694, 0.749):
		data["portal_color"] = portal_color.to_html()

	if use_bottom_frame != false:
		data["use_bottom_frame"] = use_bottom_frame
	
	return data

func importData(data: Dictionary):
	global_position = str_to_var(data["position"])
	global_rotation = str_to_var(data["rotation"])
	id = data["id"]

	if data.has("linked_id"):
		linked_id = data["linked_id"]

	if data.has("width"):
		width = data["width"]

	if data.has("height"):
		height = data["height"]

	if data.has("frame_color"):
		frame_color = Color.from_string(data["frame_color"], Color.WHITE)

	if data.has("rust_color"):
		rust_color = Color.from_string(data["rust_color"], Color.WHITE)

	if data.has("rust_strength"):
		rust_strength = data["rust_strength"]

	if data.has("portal_color"):
		portal_color = Color.from_string(data["portal_color"], Color.WHITE)

	if data.has("use_bottom_frame"):
		use_bottom_frame = data["use_bottom_frame"]
	
@onready var portalScene: PackedScene = preload("res://Editor/Portals/FunctionalPortal.tscn")

func getCopy() -> FunctionalPortal:
	var newNode: FunctionalPortal = portalScene.instantiate()
	newNode.setProperties(getProperties(), false)

	return newNode
