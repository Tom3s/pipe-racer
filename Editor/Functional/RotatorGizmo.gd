extends CSGTorus3D
class_name RotatorGizmo

@export
var originalColor: Color = Color(1, 1, 1, 0)

@export
var rotationAxis: Vector3 = Vector3(0, 1, 0)

signal rotationChanged()

func capture():
	var mesh: CSGTorus3D = get_parent().get_child(0)

	var meshMaterial: StandardMaterial3D = mesh.material
	if originalColor.a == 0:
		originalColor = meshMaterial.albedo_color

	meshMaterial.albedo_color = Color(1, 1, 1)


func release():
	var mesh: CSGTorus3D = get_parent().get_child(0)

	var meshMaterial: StandardMaterial3D = mesh.material
	meshMaterial.albedo_color = originalColor

func getCenterPoint() -> Vector2:
	var mesh: CSGTorus3D = get_parent().get_child(0)

	var camera = get_viewport().get_camera_3d()
	var posOnScreen = camera.unproject_position(mesh.global_position)

	return posOnScreen


func rotateGizmo(angle: float):
	var pivot: Node3D = get_parent()

	var camera := get_viewport().get_camera_3d()
	var cameraForward := camera.global_basis.z

	var globalAxis := pivot.global_basis.y
	if rotationAxis == Vector3(1, 0, 0):
		globalAxis = pivot.global_basis.x
	elif rotationAxis == Vector3(0, 0, 1):
		globalAxis = pivot.global_basis.z

	if globalAxis.dot(cameraForward) < 0:
		angle = -angle 

	pivot.rotate(rotationAxis, angle)

	rotationChanged.emit()