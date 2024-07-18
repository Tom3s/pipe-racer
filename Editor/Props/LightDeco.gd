@tool
extends Node3D
class_name LightDeco

@onready var omniLight: OmniLight3D = %OmniLight3D
@onready var spotLight: SpotLight3D = %SpotLight3D

@onready var omniPreview: MeshInstance3D = %OmniPreview
@onready var spotPreview: MeshInstance3D = %SpotPreview

@export
var color: Color = Color(1, 1, 1, 1):
	set(value):
		if omniLight != null:
			omniLight.light_color = value
			spotLight.light_color = value

			material.albedo_color = value
			material.emission = value
		color = value

@export
var spotlightMode: bool = false:
	set(value):
		if omniLight != null:
			omniLight.visible = !value
			spotLight.visible = value

			omniPreview.visible = !value
			spotPreview.visible = value

		spotlightMode = value

# omnilight
@export_range(1, 512, 1)
var lightSize: float = 32:
	set(value):
		if omniLight != null:
			omniLight.omni_range = value
		lightSize = value


# spotlight
@export_range(1, 512, 1)
var spotSize: float = 128:
	set(value):
		if spotLight != null:
			spotLight.spot_range = value

			if spotSize <= 64:
				spotLight.light_energy = 2
			else:
				spotLight.light_energy = remap(value, 64, 512, 2, 4)
			
			spotLight.spot_attenuation = remap(value, 1, 512, 0.5, 0.1)

		spotSize = value

@export_range(1, 180, 1)
var spotAngle: float = 35:
	set(value):
		if spotLight != null:
			spotLight.spot_angle = value
		spotAngle = value

var material: StandardMaterial3D = preload("res://Editor/Props/LightDeco.tres")

func _ready():
	omniLight.light_color = color
	spotLight.light_color = color
	omniLight.visible = !spotlightMode
	spotLight.visible = spotlightMode

	omniPreview.visible = !spotlightMode
	spotPreview.visible = spotlightMode

	omniLight.shadow_enabled = GlobalProperties.REAL_TIME_SHADOWS
	spotLight.shadow_enabled = GlobalProperties.REAL_TIME_SHADOWS

	GlobalProperties.shadowsChanged.connect(func(newShadows: bool):
		omniLight.shadow_enabled = newShadows
		spotLight.shadow_enabled = newShadows
	)

	# material = omniPreview.get_surface_override_material(0)
	material = material.duplicate()
	material.albedo_color = color
	material.emission = color
	omniPreview.set_surface_override_material(0, material)
	spotPreview.set_surface_override_material(0, material)

func setIngame(ingame: bool = true) -> void:
	%Collider.use_collision = !ingame
	# %Arrow.visible = !ingame
	omniPreview.visible = !ingame && !spotlightMode
	spotPreview.visible = !ingame && spotlightMode

func setCollision(enabled: bool) -> void:
	# if !isPreviewNode:
	%Collider.use_collision = enabled

func getProperties() -> Dictionary:
	var properties = {
		"color": color,

		"spot": spotlightMode,

		"omniSize": lightSize,
		
		"spotlightSize": spotSize,
		"spotlightAngle": spotAngle,
		
		"position": global_position,
		"rotation": global_rotation,
	}

	return properties

func setProperties(properties: Dictionary, setTransform: bool = true) -> void:
	if properties.has("color"):
		color = properties["color"]

	if properties.has("spot"):
		spotlightMode = properties["spot"]
	
	if properties.has("omniSize"):
		lightSize = properties["omniSize"]
	
	if properties.has("spotlightSize"):
		spotSize = properties["spotlightSize"]
	if properties.has("spotlightAngle"):
		spotAngle = properties["spotlightAngle"]
	
	if setTransform:
		if properties.has("position"):
			global_position = properties["position"]
		if properties.has("rotation"):
			global_rotation = properties["rotation"]

func getExportData() -> Dictionary:
	var data = {
		"position": var_to_str(global_position),
		"rotation": var_to_str(global_rotation),
	}

	if color != Color(1, 1, 1, 1):
		data["color"] = var_to_str(color)
	
	if spotlightMode != false:
		data["spot"] = spotlightMode
	
	if !is_equal_approx(lightSize, 32.0):
		data["omniSize"] = lightSize
	
	if !is_equal_approx(spotSize, 128.0):
		data["spotlightSize"] = spotSize
	if !is_equal_approx(spotAngle, 35.0):
		data["spotlightAngle"] = spotAngle
	
	return data
	

