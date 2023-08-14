extends Node3D
class_name Map

var trackPieces: Node3D

@onready
var roadMaterial = preload("res://Tracks/RacetrackMaterial.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	trackPieces = %TrackPieces


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func addPrefab(prefab: MeshInstance3D, prefabPosition: Vector3, prefabRotation: Vector3):
	trackPieces.add_child(prefab)
	prefab.global_position = prefabPosition
	prefab.global_rotation = prefabRotation
	prefab.mesh.surface_set_material(0, roadMaterial)
	prefab.create_trimesh_collision()
