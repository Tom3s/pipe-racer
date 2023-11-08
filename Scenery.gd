@tool
extends MeshInstance3D
class_name Scenery

var sceneryShaderMaterial = preload("res://SceneryMaterial.tres")

@export
var noiseTexture: Texture2D = NoiseTexture2D.new()

@export 
var terrainHeight: float = 100.0:
	set(value):
		terrainHeight = value
		get_surface_override_material(0).set_shader_parameter("Terrain_Height", value)
		# calculateCollisionShape()
	get:
		return terrainHeight	

@export_range(0, 1, 0.01)
var valleyDip: float = 1.0:
	set(value):
		valleyDip = value
		# get_surface_override_material(0).set_shader_parameter("ValleyDip", value)
		# calculateCollisionShape()
	get:
		return valleyDip

@export
var noiseSize: float = 5:
	set(value):
		noiseSize = value
		if noiseTexture.noise != null:
			noiseTexture.noise.frequency = 1.0 / value
		get_surface_override_material(0).set_shader_parameter("Noise_Size", value)
		# calculateCollisionShape()
	get:
		return noiseSize

@export
var subdivisions: int = 128:
	set(value):
		subdivisions = value
		mesh.subdivide_depth = value - 1
		mesh.subdivide_width = value - 1
		noiseTexture.width = value + 1
		noiseTexture.height = value + 1
		await noiseTexture.changed

		get_surface_override_material(0).set_shader_parameter("NoiseTexture", noiseTexture)
		# calculateCollisionShape()

@export
var terrainSize: float = 1000.0:
	set(value):
		terrainSize = value
		mesh.size = Vector2(value, value)
		# calculateCollisionShape()
	get:
		return terrainSize



@export
var heightmapTexture: Texture2D

func _ready():
	mesh = PlaneMesh.new()
	mesh.subdivide_depth = subdivisions - 1
	mesh.subdivide_width = subdivisions - 1
	mesh.size = Vector2(terrainSize, terrainSize)

	noiseTexture = NoiseTexture2D.new()
	noiseTexture.width = subdivisions + 1
	noiseTexture.height = subdivisions + 1

	noiseTexture.noise = FastNoiseLite.new()
	noiseTexture.noise.frequency = 1.0 / noiseSize
	await noiseTexture.changed

	var material = sceneryShaderMaterial
	material.set_shader_parameter("Terrain_Height", terrainHeight)
	# material.set_shader_parameter("ValleyDip", valleyDip)
	material.set_shader_parameter("Noise_Size", noiseSize)
	# material.set_shader_parameter("NoiseTexture", noiseTexture)

	set_surface_override_material(0, material)

	calculateCollisionShape()

func calculateCollisionShape():
	var heights = []
	var image = noiseTexture.get_image()
	if image == null:
		return
	var actualSize = terrainSize / subdivisions

	var heightmap = Image.new()
	heightmap.copy_from(image)

	for x in subdivisions + 1:
		heights.append([])
		for y in subdivisions + 1:
			heights[x].append(image.get_pixel(x, y).r) #  * terrainHeight

			var uv = Vector2(float(x) / subdivisions, float(y) / subdivisions)
			var value = uv.distance_to(Vector2(0.5, 0.5))
			value = cos(value * PI)
			value = clamp(value, 0.0, 1.0)

			# heights[x][y] *= 1 - (value * valleyDip)
			var asd = value * valleyDip
			heights[x][y] = lerp(heights[x][y], 0.0, asd)

			# heights[x][y] = floor(heights[x][y] * 20) / 20

			heightmap.set_pixel(x, y, Color(
				heights[x][y], 
				heights[x][y], 
				heights[x][y], 
				1.0))
			heights[x][y] *= (terrainHeight / actualSize)
			heights[x][y] = floor(heights[x][y] * 20) / 20
	
	var flatArray = []
	for array in heights:
		flatArray.append_array(array)
	
	var collisionNode = %Proper

	collisionNode.shape = HeightMapShape3D.new()
	collisionNode.shape.map_width = subdivisions + 1
	collisionNode.shape.map_depth = subdivisions + 1
	collisionNode.shape.map_data = PackedFloat32Array(flatArray)
	collisionNode.scale = Vector3(actualSize, actualSize, actualSize)

	# sceneryShaderMaterial.set_shader_parameter("HeightMap", heightmap)
	heightmapTexture = ImageTexture.create_from_image(heightmap)
	get_surface_override_material(0).set_shader_parameter("HeightMap", heightmapTexture)

func setIngameCollision():
	%Proper.disabled = false
	%Flat.disabled = true
