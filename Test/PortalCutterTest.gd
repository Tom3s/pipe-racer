@tool
extends Node3D

@onready var cutting_plane: MeshInstance3D = %CuttingPlane
@onready var mesh: MeshInstance3D = %Mesh

func _process(delta: float) -> void:
	mesh.material_override.set_shader_parameter("cutplane", cutting_plane.global_transform);



