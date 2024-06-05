extends Node3D

func getGhostMaterial(color: Color) -> Material:
	var mat = StandardMaterial3D.new()
	mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = color
	mat.albedo_color.a = 0.45
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED

	return mat

func setGhostMode(color: Color):
	print("[GhostModeMesh.gd] setGhostMode")
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = getGhostMaterial(color)
		elif child.has_method("setGhostMode"):
			child.setGhostMode(color)
