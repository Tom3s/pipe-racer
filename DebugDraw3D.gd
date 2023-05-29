extends Control

class_name DebugDraw3D

var springOrigins = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]
var springVectors = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]

var actualOrigins = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]
var actualVectors = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]

var steeringOrigins = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]
var steeringVectors = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]

var accelerationOrigins = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]
var accelerationVectors = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]

func _draw():
	for i in range(4):
		var line_endpoints = draw_vector(springOrigins[i], springVectors[i])
		draw_line(line_endpoints[0], line_endpoints[1], Color.GREEN, 2, true)

		var line_endpoints2 = draw_vector(actualOrigins[i], actualVectors[i], true)
		draw_line(line_endpoints2[0], line_endpoints2[1], Color.PURPLE, 2, true)

		var line_endpoints3 = draw_vector(steeringOrigins[i], steeringVectors[i])
		draw_line(line_endpoints3[0], line_endpoints3[1], Color.RED, 2, true)

		var line_endpoints4 = draw_vector(accelerationOrigins[i], accelerationVectors[i])
		draw_line(line_endpoints4[0], line_endpoints4[1], Color.BLUE, 2, true)
		# print(line_endpoints[0], line_endpoints[1])
	queue_redraw()
	pass
	

func draw_vector(origin: Vector3, vector: Vector3, is_it: bool = false) -> Array[Vector2]:
	var camera := %Camera
	var start = camera.unproject_position(origin)
	var end = camera.unproject_position(origin + vector * (1 if is_it else 0.01))
	return [start, end]
