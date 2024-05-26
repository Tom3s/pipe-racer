extends Node
class_name EditorInputHandler

var maxDistance: int = 2000

signal mouseMovedTo(worldPosition: Vector3)
signal moveUpGrid()
signal moveDownGrid()

signal rotatePressed(axis: Vector3, angle: float)
signal resetRotationPressed()

signal clickStarted()
signal clickEnded()

signal mouseMovedOnScreen(newPos: Vector2)

signal placePressed()

signal mouseMovedTo_Scenery(worldPosition: Vector3, isPlacePressed: bool)

signal pausePressed(paused)

var lastGridHeight: float = 0
var currentGridHeight: float = 0
var currentPlaneSize: int = 64

var mousePos2D: Vector2 = Vector2()

var angleSnap: float = deg_to_rad(5)

var scrollCooldown: float = 0.0
var scrollCooldownTime: float = 0.05

var editorMode: EditorEventListener.EditorMode = EditorEventListener.EditorMode.BUILD

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	scrollCooldown -= delta

func _unhandled_input(event):
	if editorMode == EditorEventListener.EditorMode.BUILD:
		var newMousePos: Vector2 = get_viewport().get_mouse_position()
		if !Input.is_action_pressed("editor_look_around") && (mousePos2D != newMousePos || lastGridHeight != currentGridHeight):
			mousePos2D = newMousePos
			mouseMovedTo.emit(onScreenMousePosToGridIntersect())
		
		if Input.is_action_just_pressed("editor_rotate_right"):
			rotatePressed.emit(Vector3.UP, -angleSnap)
		elif Input.is_action_just_pressed("editor_tilt_right"):
			rotatePressed.emit(Vector3.FORWARD, angleSnap)
		elif Input.is_action_just_pressed("editor_pitch_back"):
			rotatePressed.emit(Vector3.RIGHT, -angleSnap)
		elif Input.is_action_just_pressed("editor_grid_down"):
			if scrollCooldown <= 0:
				currentGridHeight -= PrefabConstants.GRID_SIZE
				mouseMovedTo.emit(onScreenMousePosToGridIntersect())
				moveDownGrid.emit()
				scrollCooldown = scrollCooldownTime
				


		if Input.is_action_just_pressed("editor_rotate_left"):
			rotatePressed.emit(Vector3.UP, angleSnap)
		elif Input.is_action_just_pressed("editor_tilt_left"):
			rotatePressed.emit(Vector3.FORWARD, -angleSnap)
		elif Input.is_action_just_pressed("editor_pitch_forward"):
			rotatePressed.emit(Vector3.RIGHT, angleSnap)
		elif Input.is_action_just_pressed("editor_grid_up"):
			if scrollCooldown <= 0:
				currentGridHeight += PrefabConstants.GRID_SIZE
				moveUpGrid.emit()
				mouseMovedTo.emit(onScreenMousePosToGridIntersect())
				scrollCooldown = scrollCooldownTime

		lastGridHeight = currentGridHeight

		if Input.is_action_just_pressed("editor_reset_rotation"):
			resetRotationPressed.emit()

		if Input.is_action_just_pressed("editor_place"):
			placePressed.emit()


	elif editorMode == EditorEventListener.EditorMode.SCENERY:
		if !Input.is_action_pressed("editor_look_around"):
			mouseMovedTo_Scenery.emit(screenPointToRay_Scenery(), Input.is_action_pressed("editor_place"))

		if Input.is_action_just_pressed("editor_place"):
			placePressed.emit()


	elif editorMode == EditorEventListener.EditorMode.EDIT:
		if !Input.is_action_pressed("editor_look_around") && Input.is_action_pressed("editor_place"):
			mouseMovedOnScreen.emit(get_viewport().get_mouse_position())

		if Input.is_action_just_pressed("editor_place"):
			clickStarted.emit()
			placePressed.emit()
		elif Input.is_action_just_released("editor_place"):
			clickEnded.emit()
		
		if Input.is_action_just_pressed("editor_rotate_right"):
			rotatePressed.emit(Vector3.UP, -angleSnap)
		elif Input.is_action_just_pressed("editor_tilt_right"):
			rotatePressed.emit(Vector3.FORWARD, angleSnap)
		elif Input.is_action_just_pressed("editor_pitch_back"):
			rotatePressed.emit(Vector3.RIGHT, -angleSnap)
				


		if Input.is_action_just_pressed("editor_rotate_left"):
			rotatePressed.emit(Vector3.UP, angleSnap)
		elif Input.is_action_just_pressed("editor_tilt_left"):
			rotatePressed.emit(Vector3.FORWARD, -angleSnap)
		elif Input.is_action_just_pressed("editor_pitch_forward"):
			rotatePressed.emit(Vector3.RIGHT, angleSnap)
	

	elif editorMode == EditorEventListener.EditorMode.DELETE:
		if Input.is_action_just_pressed("editor_place"):
			placePressed.emit()


func onScreenMousePosToGridIntersect() -> Vector3:
	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	# var to = from + camera.project_ray_normal(mousePos) * maxDistance
	var dir = camera.project_ray_normal(mousePos)

	var a: Vector3 = Vector3(
		-(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH,
		currentGridHeight,
		-(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH
	)
	var b: Vector3 = Vector3(
		(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH,
		currentGridHeight,
		-(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH
	)
	var c: Vector3 = Vector3(
		-(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH,
		currentGridHeight,
		(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH
	)
	var d: Vector3 = Vector3(
		(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH,
		currentGridHeight,
		(float(currentPlaneSize) / 2) * PrefabConstants.TRACK_WIDTH
	)



	var intersection = Geometry3D.ray_intersects_triangle(
		from,
		dir,
		a,
		b,
		c
	)

	if intersection == null:
		intersection = Geometry3D.ray_intersects_triangle(
			from,
			dir,
			b,
			c,
			d
		)
	
	if intersection == null:
		return Vector3.INF
	
	intersection = intersection.snapped(Vector3.ONE * PrefabConstants.GRID_SIZE)

	return intersection

func screenPointToRay_Scenery() -> Vector3:
	var spaceState = get_parent().get_world_3d().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * maxDistance
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 8))
	
	if rayArray.has("position"):
		return rayArray["position"]
	return Vector3.INF