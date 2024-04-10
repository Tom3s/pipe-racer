extends MeshInstance3D
class_name PhysicsSurface

# var materials = [
# 	preload("res://Tracks/AsphaltMaterial.tres"), # ROAD
# 	preload("res://Track Props/GrassMaterial.tres"), # GRASS
# 	preload("res://Track Props/DirtMaterial.tres"), # DIRT
# 	preload("res://Track Props/BoosterMaterial.tres"), # BOOSTER	
# 	preload("res://Track Props/BoosterMaterialReversed.tres"), # REVERSE BOOSTER	
# 	preload("res://Tracks/RacetrackMaterial.tres") # CONCRETE
# ]

var frictions = [
	1.0, # ROAD
	0.3, # GRASS
	0.3, # DIRT
	1.0, # BOOSTER
	1.0, # REVERSE BOOSTER
	0.9, # CONCRETE
]

var accelerationMultipliers = [
	1.0, # ROAD
	0.2, # GRASS
	1.0, # DIRT
	3.0, # BOOSTER
	3.0, # REVERSE BOOSTER
	0.9, # CONCRETE
]

var smokeParticlesTypes = [
	true, # ROAD
	true, # GRASS
	false, # DIRT
	true, # BOOSTER
	true, # REVERSE BOOSTER
	true, # CONCRETE
]

var friction: float = 1.0
var accelerationPenalty: float = 0.0
var smokeParticles: bool = true

func setPhysicsMaterial(material: int) -> void:
	friction = frictions[material]
	accelerationPenalty = accelerationMultipliers[material]
	smokeParticles = smokeParticlesTypes[material]