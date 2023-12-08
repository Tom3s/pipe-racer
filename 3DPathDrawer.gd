extends Node3D
class_name PathDrawer3D

static func get3DLine(from: Vector3, to: Vector3, color: Color) -> MeshInstance3D:
	var meshInstance = MeshInstance3D.new()
	var mesh = ImmediateMesh.new()
	var material = ORMMaterial3D.new()

	meshInstance.mesh = mesh
	meshInstance.cast_shadow = false

	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_add_vertex(from)
	mesh.surface_add_vertex(to)
	mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return meshInstance
