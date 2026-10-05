extends Node3D
class_name CuttableCarModel

@onready var chassis_parent: Node3D = %CarChassis

var rollcage_material: StandardMaterial3D

var wheels: Array[Node3D]


func _ready() -> void:
	var rollcage_mesh: MeshInstance3D = get_node("CarChassis/Rollcage")
	# rollcage_mesh.material_override = rollcage_mesh.material_override.duplicate()

	wheels = [
		get_node("Wheels/FL"),
		get_node("Wheels/FR"),
		get_node("Wheels/BL"),
		get_node("Wheels/BR"),
	]

	for mesh: MeshInstance3D in chassis_parent.get_children():
		mesh.material_override = mesh.material_override.duplicate()

	rollcage_material = rollcage_mesh.material_override.next_pass.duplicate()
	rollcage_mesh.material_override.next_pass = rollcage_material

	set_frame_color(Color.BLACK)

func set_frame_color(new_color: Color) -> void:
	rollcage_material.albedo_color = new_color

func setGhostMode(color: Color):
	push_error("func 'setGhostMode' uninmplemented on [CuttableCarModel.gd]!!")
	print("func 'setGhostMode' uninmplemented on [CuttableCarModel.gd]!!")

func set_cutting_plane(plane_transform: Transform3D, direction: float = 1.0) -> void:
	for mesh: MeshInstance3D in chassis_parent.get_children():
		var material: Material = mesh.material_override
		material.set_shader_parameter("cutplane", plane_transform)
		material.set_shader_parameter("cut_direction", direction)
		material.set_shader_parameter("enable_cut", 1.0)
	
	for wheel in wheels:
		wheel.get_child(0).get_child(0).get_child(0)\
			.set_cutting_plane(plane_transform, direction)

func reset_cutting_plane() -> void:
	for mesh: MeshInstance3D in chassis_parent.get_children():
		var material: Material = mesh.material_override
		material.set_shader_parameter("enable_cut", -1.0)
	
	for wheel in wheels:
		wheel.get_child(0).get_child(0).get_child(0)\
			.reset_cutting_plane()

func get_duplicate() -> CuttableCarModel:
	var copy: CuttableCarModel = duplicate()
	# for copy_mesh: MeshInstance3D in copy.chassis_parent.get_children():
	# 	copy_mesh.material_override = copy_mesh.material_override.duplicate()
	
	copy.chassis_parent = copy.get_node("CarChassis")
	copy.wheels = [
		copy.get_node("Wheels/FL"),
		copy.get_node("Wheels/FR"),
		copy.get_node("Wheels/BL"),
		copy.get_node("Wheels/BR"),
	]

	if get_parent() != null:
		get_parent().car_copy_model = copy

	# # copy.set_frame_color()
	# copy.set_frame_color(Color.BLACK)

	return copy


# wheel_turn -> attachmentpoint.y
# rotation -> wheel_offset.x

func rotate_wheels(rotation: float, wheel_turn: float) -> void:
	pass

func place_wheels() -> void:
	pass

# attachment_point.y = -raycast.length
