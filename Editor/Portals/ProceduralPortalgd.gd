@tool
extends Node3D
class_name ProceduralPortal

@onready var portal_parent: Node3D = %PortalParent
@onready var portal_surface: MeshInstance3D = %PortalSurface

@onready var core_left: CSGBox3D = %CoreLeft
@onready var core_right: CSGBox3D = %CoreRight
@onready var core_top: CSGBox3D = %CoreTop

@onready var corner_tl: MeshInstance3D = %CornerTL
@onready var corner_tr: MeshInstance3D = %CornerTR

@onready var base_left: MeshInstance3D = %BaseLeft
@onready var base_right: MeshInstance3D = %BaseRight

@onready var left_frame: CSGCombiner3D = %LeftFrame
@onready var right_frame: CSGCombiner3D = %RightFrame
@onready var top_frame: CSGCombiner3D = %TopFrame

var core_material: ShaderMaterial = preload("res://Editor/Portals/PortalCoreMaterial.tres")
var portal_material: ShaderMaterial = preload("res://Editor/Portals/PortalSurfaceMaterial.tres")

var applied_core_material: ShaderMaterial
var applied_portal_material: ShaderMaterial

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
var frame_color: Color = Color.ORANGE:
	set(value):
		frame_color = value
		refresh_model()

@export
var portal_color: Color = Color.ORANGE:
	set(value):
		portal_color = value
		set_colors()

@export
var bottom_frame: bool = false:
	set(value):
		bottom_frame = value
		set_colors()

func _ready() -> void:
	portal_surface.mesh = portal_surface.mesh.duplicate()

	applied_core_material = core_material.duplicate()
	core_left.material_override = applied_core_material
	core_right.material_override = applied_core_material
	core_top.material_override = applied_core_material

	applied_portal_material = portal_material.duplicate()

	set_colors()
	refresh_model()

func refresh_model() -> void:
	if !is_node_ready():
		print("Aborting procedural portal model refresh!")
		return

	portal_parent.position.y = height / 2.0;
	portal_surface.mesh.size = Vector2(width, height)

	core_left.size.y = height - 2
	core_right.size.y = height - 2

	core_left.position.x = -width / 2.0 - 0.5
	core_right.position.x = width / 2.0 + 0.5

	core_top.size.y = width - 4
	core_top.position.y = height / 2.0 + 0.5

	corner_tl.position.x = -width / 2.0
	corner_tr.position.x =  width / 2.0
	corner_tl.position.y = height / 2.0
	corner_tr.position.y = height / 2.0

	base_left.position.x = -width / 2.0 - 0.5
	base_right.position.x =  width / 2.0 + 0.5
	base_left.position.y = -height / 2.0
	base_right.position.y = -height / 2.0

	left_frame.position.x = -width / 2.0 - 0.5
	# y - 5
	left_frame.get_child(0).size.y = height - 5
	# y - 5
	left_frame.get_child(1).height = height - 5
	# y - 5
	left_frame.get_child(2).size.y = height - 5
	# y - 9
	left_frame.get_child(3).size.y = max(3, height - 9)
	
	right_frame.position.x = width / 2.0 + 0.5
	# y - 5
	right_frame.get_child(0).size.y = height - 5
	# y - 5
	right_frame.get_child(1).height = height - 5
	# y - 5
	right_frame.get_child(2).size.y = height - 5
	# y - 9
	right_frame.get_child(3).size.y = max(3, height - 9)
	
	top_frame.position.y = height / 2.0 + 0.5
	# y - 6
	top_frame.get_child(0).size.y = width - 6
	# y - 6
	top_frame.get_child(1).height = width - 6
	# y - 6
	top_frame.get_child(2).size.y = width - 6
	# y - 9
	top_frame.get_child(3).size.y = max(3, width - 9)

func set_colors() -> void:
	if !is_node_ready():
		print("Aborting procedural portal color refresh!")
		return

	applied_core_material.set_shader_parameter("core_color", portal_color)
	applied_portal_material.next_pass.set_shader_parameter("swirl_color", portal_color)
	pass
