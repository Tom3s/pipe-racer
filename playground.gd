extends Node

var parsed = null
# Called when the node enters the scene tree for the first time.
func _ready():
	var json = JSON.stringify({
		"vector3": var_to_str(Vector3.ONE) 
	})

	print(json)

	var parsed_json = JSON.parse_string(json)

	parsed = str_to_var(parsed_json["vector3"])
