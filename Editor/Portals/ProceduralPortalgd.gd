@tool
extends Node3D
class_name ProceduralPortal

@onready var portal_parent: Node3D = %PortalParent
@onready var portal_surface: MeshInstance3D = %PortalSurface

@onready var core_left: CSGBox3D = %CoreLeft
@onready var core_right: CSGBox3D = %CoreRight
@onready var core_top: CSGBox3D = %CoreTop
@onready var core_bottom: CSGBox3D = %CoreBottom

@onready var corner_tl: MeshInstance3D = %CornerTL
@onready var corner_tr: MeshInstance3D = %CornerTR
@onready var corner_bl: MeshInstance3D = %CornerBL
@onready var corner_br: MeshInstance3D = %CornerBR

@onready var base_left: MeshInstance3D = %BaseLeft
@onready var base_right: MeshInstance3D = %BaseRight

@onready var left_frame: CSGCombiner3D = %LeftFrame
@onready var right_frame: CSGCombiner3D = %RightFrame
@onready var top_frame: CSGCombiner3D = %TopFrame
@onready var bottom_frame: CSGCombiner3D = %BottomFrame

@onready var light1: AreaLight3D = %Light1
@onready var light2: AreaLight3D = %Light2


var core_material: ShaderMaterial = preload("res://Editor/Portals/PortalCoreMaterial.tres")
var portal_material: ShaderMaterial = preload("res://Editor/Portals/PortalSurfaceMaterial.tres")
var frame_material: ShaderMaterial = preload("res://Editor/Portals/PortalFrameMaterial.tres")

var applied_core_material: ShaderMaterial
var applied_portal_material: ShaderMaterial
var applied_frame_material: ShaderMaterial

@export_range(8, 128, 1)
var width: int = 16:
	set(value):
		width = value
		refresh_model()

@export_range(8, 128, 1)
var height: int = 12:
	set(value):
		height = value
		refresh_model()

@export
var frame_color: Color = Color(0.831, 0.831, 0.831):
	set(value):
		frame_color = value
		set_colors()

@export
var rust_color: Color = Color(0.6, 0.212, 0.047):
	set(value):
		rust_color = value
		set_colors()

@export_range(0.0, 1.0, 0.1)
var rust_strength: float = 0.4:
	set(value):
		rust_strength = value
		set_colors()

@export
var portal_color: Color = Color(0.0, 0.694, 0.749):
	set(value):
		portal_color = value
		set_colors()

@export
var use_bottom_frame: bool = false:
	set(value):
		use_bottom_frame = value
		refresh_model()

func _ready() -> void:
	portal_surface.mesh = portal_surface.mesh.duplicate()

	applied_core_material = core_material.duplicate()
	core_left.material_override = applied_core_material
	core_right.material_override = applied_core_material
	core_top.material_override = applied_core_material
	core_bottom.material_override = applied_core_material

	applied_portal_material = portal_material.duplicate()
	applied_portal_material.next_pass = applied_portal_material.next_pass.duplicate()
	portal_surface.material_override = applied_portal_material

	applied_frame_material = frame_material.duplicate()

	corner_tl.material_override = applied_frame_material
	corner_tr.material_override = applied_frame_material
	corner_bl.material_override = applied_frame_material
	corner_br.material_override = applied_frame_material
	base_left.material_override = applied_frame_material
	base_right.material_override = applied_frame_material
	left_frame.material_override = applied_frame_material
	right_frame.material_override = applied_frame_material
	top_frame.material_override = applied_frame_material
	bottom_frame.material_override = applied_frame_material

	set_colors()
	refresh_model()

func refresh_model() -> void:
	if !is_node_ready():
		print("Aborting procedural portal model refresh!")
		return

	portal_parent.position.y = height / 2.0;
	portal_surface.mesh.size = Vector2(width, height)

	core_left.size.y = height - 4
	core_right.size.y = height - 4

	core_left.position.x = -width / 2.0 - 0.5
	core_right.position.x = width / 2.0 + 0.5

	core_top.size.y = width - 4
	core_top.position.y = height / 2.0 + 0.5
	
	core_bottom.size.y = width - 4
	core_bottom.position.y = -height / 2.0 - 0.5


	corner_tl.position.x = -width / 2.0
	corner_tr.position.x =  width / 2.0
	corner_tl.position.y = height / 2.0
	corner_tr.position.y = height / 2.0
	
	corner_bl.visible = use_bottom_frame
	corner_br.visible = use_bottom_frame
	base_left.visible = !use_bottom_frame
	base_right.visible = !use_bottom_frame
	core_bottom.visible = use_bottom_frame
	bottom_frame.visible = use_bottom_frame

	if use_bottom_frame:
		corner_bl.position.x = -width / 2.0
		corner_br.position.x =  width / 2.0
		corner_bl.position.y = -height / 2.0
		corner_br.position.y = -height / 2.0

	else:
		base_left.position.x = -width / 2.0 - 0.5
		base_right.position.x =  width / 2.0 + 0.5
		base_left.position.y = -height / 2.0
		base_right.position.y = -height / 2.0

	left_frame.position.x = -width / 2.0 - 0.5	
	right_frame.position.x = width / 2.0 + 0.5
	set_side_frame_parameters(left_frame)
	set_side_frame_parameters(right_frame)
	
	top_frame.position.y = height / 2.0 + 0.5
	# y - 6
	top_frame.get_child(0).size.y = width - 6
	# y - 6
	top_frame.get_child(1).height = width - 6
	# y - 6
	top_frame.get_child(2).size.y = width - 6
	# y - 9
	top_frame.get_child(3).size.y = max(3, width - 9)
	
	bottom_frame.position.y = -height / 2.0 - 0.5
	# y - 6
	bottom_frame.get_child(0).size.y = width - 6
	# y - 6
	bottom_frame.get_child(1).height = width - 6
	# y - 6
	bottom_frame.get_child(2).size.y = width - 6
	# y - 9
	bottom_frame.get_child(3).size.y = max(3, width - 9)

	light1.area_size = Vector2(width, height)
	light2.area_size = Vector2(width, height)

func set_side_frame_parameters(parent: Node3D) -> void:
	if !use_bottom_frame:
		parent.position.y = 1.0

		parent.get_child(0).size.y = height - 5
		# y - 5
		parent.get_child(1).height = height - 5
		# y - 5
		parent.get_child(2).size.y = height - 5
		# y - 9
		parent.get_child(3).size.y = max(3, height - 9)
		parent.get_child(3).position.y = -0.5
	else:
		parent.position.y = 0.0

		parent.get_child(0).size.y = height - 4
		# y - 4
		parent.get_child(1).height = height - 4
		# y - 4
		parent.get_child(2).size.y = height - 4
		# y - 9
		parent.get_child(3).size.y = max(3, height - 8)
		parent.get_child(3).position.y = 0.0

func set_colors() -> void:
	if !is_node_ready():
		print("Aborting procedural portal color refresh!")
		return

	applied_core_material.set_shader_parameter("core_color", portal_color)
	applied_portal_material.next_pass.set_shader_parameter("swirl_color", portal_color)
	applied_frame_material.set_shader_parameter("base_color", frame_color)
	applied_frame_material.set_shader_parameter("rust_color", rust_color)
	applied_frame_material.set_shader_parameter("rust_strength", rust_strength)

	light1.light_color = portal_color
	light2.light_color = portal_color
