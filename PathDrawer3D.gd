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

	# don't render on portal cams
	meshInstance.layers = 0
	meshInstance.set_layer_mask_value(16, true)

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return meshInstance

static func get3DPath(path: Array) -> MeshInstance3D:
	if path.size() < 2:
		return null
	
	var offset: Vector3 = Vector3(0, 0.6, 0)

	var meshInstance := MeshInstance3D.new()
	var mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	meshInstance.mesh = mesh
	meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)

	# mesh.surface_add_vertex(from)

	# var length = path.size()
	# for i in length - 1:
	# 	if i <= 2:
	# 		continue
	# 	carPath.add_child(PathDrawer3D.get3DLine(
	# 		path[i].position + Vector3(0, 0.6, 0),
	# 		path[i + 1].position + Vector3(0, 0.6, 0),
	# 		path[i].getColor()
	# 		)
	# 	)
	for frame: CarFrame in path:
		mesh.surface_set_color(frame.getColor())
		mesh.surface_add_vertex(frame.position + offset)
		


	# mesh.surface_add_vertex(from)
	# mesh.surface_add_vertex(to)

	mesh.surface_end()
	# don't render on portal cams
	meshInstance.layers = 0
	meshInstance.set_layer_mask_value(16, true)

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# material.albedo_color = color
	material.vertex_color_use_as_albedo = true

	return meshInstance