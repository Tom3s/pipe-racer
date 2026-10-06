extends Node3D
class_name CuttableWheel

@export
var rim_material: Material

func _ready() -> void:
	for mesh in get_children():
		mesh.material_override = mesh.material_override.duplicate()

func set_cutting_plane(plane_transform: Transform3D, direction: float = 1.0) -> void:
	for mesh in get_children():
		var material: Material = mesh.material_override
		material.set_shader_parameter("cutplane", plane_transform)
		material.set_shader_parameter("cut_direction", direction)
		material.set_shader_parameter("enable_cut", 1.0)

func reset_cutting_plane() -> void:
	for mesh in get_children():
		var material: Material = mesh.material_override
		material.set_shader_parameter("enable_cut", -1.0)

func get_duplicate() -> CuttableCarModel:
	var copy: CuttableCarModel = duplicate()
	for copy_mesh: MeshInstance3D in copy.get_children():
		copy_mesh.material_override = copy_mesh.material_override.duplicate()
	
	if get_parent() != null:
		get_parent().car_copy_model = copy

	# copy.set_frame_color()

	return copy
