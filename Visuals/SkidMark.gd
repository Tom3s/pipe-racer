extends Node3D
class_name SkidMark

@onready var left: RayCast3D = %Left
@onready var right: RayCast3D = %Right

@export
var distance_treshold: float = 0.2

@export
var offset: float = 0.01

signal new_contact_point(last_l: Vector3, last_r: Vector3, left: Vector3, right: Vector3)

var last_left: Vector3
var last_right: Vector3

var drawing: bool = false

func _ready() -> void:
	last_left = left.global_position
	last_right = right.global_position

	distance_treshold *= distance_treshold

	set_physics_process(true)

func _physics_process(delta: float) -> void:
	left.force_raycast_update()
	right.force_raycast_update()
	
	var left_contact: Vector3 = left.get_collision_point() + left.get_collision_normal() * offset
	var right_contact: Vector3 = right.get_collision_point() + right.get_collision_normal() * offset

	# print(left_contact)
	# print(right_contact)

	if left_contact.distance_squared_to(last_left) >= distance_treshold || \
		right_contact.distance_squared_to(last_right) >= distance_treshold:
		
		new_contact_point.emit(
			last_left,
			last_right,
			left_contact,
			right_contact,
		)

		# print("[SkidMark.gd] New contact points at: %v - %v" % [
		# 	left_contact + left.get_collision_normal() * offset,
		# 	right_contact + right.get_collision_normal() * offset,
		# ])

		last_left = left_contact
		last_right = right_contact


