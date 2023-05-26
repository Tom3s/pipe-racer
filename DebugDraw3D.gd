extends Control

class_name DebugDraw3D

var springOrigins = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]
var springVectors = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]

var actualOrigin = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]
var actualVector = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)]

func _draw():
	for i in range(4):
		var line_endpoints = draw_vector(springOrigins[i], springVectors[i])
		draw_line(line_endpoints[0], line_endpoints[1], Color.GREEN, 2, true)

		var line_endpoints2 = draw_vector(actualOrigin[i], actualVector[i])
		draw_line(line_endpoints2[0], line_endpoints2[1], Color.RED, 2, true)
		# print(line_endpoints[0], line_endpoints[1])
	queue_redraw()
	

func draw_vector(origin: Vector3, vector: Vector3) -> Array[Vector2]:
	var camera := %Camera
	var start = camera.unproject_position(origin)
	var end = camera.unproject_position(origin + vector)
	return [start, end]
