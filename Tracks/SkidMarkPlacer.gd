extends Node3D
class_name SkidMarkPlacer

var skid_material: ShaderMaterial = preload("res://Visuals/SkidMarkMateril.tres")

var skid_dictionary: Dictionary[SkidMark, MeshInstance3D]
var skid_array: Dictionary[MeshInstance3D, PackedVector3Array]

func init_skidmark(skid: SkidMark) -> void:
	var skid_mesh: MeshInstance3D = MeshInstance3D.new()

	skid_array[skid_mesh] = []

	add_child(skid_mesh)

	# var material: StandardMaterial3D = skid_material

	# material.cull_mode = BaseMaterial3D.CULL_DISABLED

	skid_mesh.material_override = skid_material
	

	skid_dictionary[skid] = skid_mesh

	skid_mesh.mesh = ImmediateMesh.new()

func add_quad(skid: SkidMark, last_l: Vector3, last_r: Vector3, left: Vector3, right: Vector3) -> void:
	var mesh: ImmediateMesh = skid_dictionary[skid].mesh

	var array: PackedVector3Array = skid_array[skid_dictionary[skid]]

	array.append(last_l)
	array.append(last_r)
	array.append(left)
	array.append(right)

	mesh.clear_surfaces()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	var current_uv: Vector2 = Vector2.ZERO
	for vertex in array:
		mesh.surface_set_uv(current_uv)

		if current_uv.x == 0:
			current_uv.x = 1
		else:
			current_uv.x = 0
			current_uv.y += 1

		mesh.surface_add_vertex(vertex)

	mesh.surface_end()
		
