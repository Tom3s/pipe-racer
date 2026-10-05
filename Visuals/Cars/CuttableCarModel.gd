extends Node3D
class_name CuttableCarModel

var rollcage_material: StandardMaterial3D

func _ready() -> void:
	var rollcage_mesh: MeshInstance3D = %Rollcage
	rollcage_material = rollcage_mesh.get_surface_override_material(0).next_pass.duplicate()
	rollcage_mesh.get_surface_override_material(0).next_pass = rollcage_material

func set_frame_color(new_color: Color) -> void:
	rollcage_material.albedo_color = new_color

func setGhostMode(color: Color):
	push_error("func 'setGhostMode' uninmplemented on [CuttableCarModel.gd]!!")
	print("func 'setGhostMode' uninmplemented on [CuttableCarModel.gd]!!")

func set_cutting_plane(plane_transform: Transform3D, direction: float = 1.0) -> void:
	for mesh: MeshInstance3D in get_children():
		var material: Material = mesh.get_surface_override_material(0)
		material.set_shader_parameter("cutplane", plane_transform)
		material.set_shader_parameter("cut_direction", direction)
		material.set_shader_parameter("enable_cut", 1.0)

func reset_cutting_plane() -> void:
	for mesh: MeshInstance3D in get_children():
		var material: Material = mesh.get_surface_override_material(0)
		material.set_shader_parameter("enable_cut", -1.0)

func get_duplicate() -> CuttableCarModel:
	var copy: CuttableCarModel = duplicate()
	for copy_mesh: MeshInstance3D in copy.get_children():
		copy_mesh.set_surface_override_material(0, copy_mesh.get_surface_override_material(0).duplicate())
	
	if get_parent() != null:
		get_parent().car_copy_model = copy

	# copy.set_frame_color()

	return copy
