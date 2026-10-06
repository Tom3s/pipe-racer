extends Node

const CarScene := preload("res://CarController.tscn")

var failures: Array[String] = []

func _ready() -> void:
	runTests.call_deferred()

func runTests() -> void:
	var world := Node3D.new()
	add_child(world)

	var car: CarController = CarScene.instantiate()
	car.freeze = true
	world.add_child(car)
	car.set_physics_process(false)

	var camera := FollowingCamera.new(car)
	world.add_child(camera)
	camera.set_physics_process(false)

	testDelayedPortalCrossing(car, camera)
	testReversePortalCrossing(car, camera)
	testDelayedOrbitCrossing(car, camera)
	testCameraAlreadyCrossed(car, camera)
	testRespawnSnap(car, camera)

	world.queue_free()

	if failures.is_empty():
		print("FollowingCamera portal tests: PASS")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func testDelayedPortalCrossing(car: CarController, camera: FollowingCamera) -> void:
	var entry := Transform3D.IDENTITY
	var exit := Transform3D(Basis(Vector3.UP, PI / 2.0), Vector3(100.0, 0.0, 20.0))
	var crossingOffset := Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.1))

	camera.mode = 0
	camera.global_transform = Transform3D(Basis.IDENTITY, Vector3(0.0, 3.0, -4.0))
	car.global_transform = crossingOffset
	car.set_new_transform(entry, exit, crossingOffset)
	car._physics_process(1.0 / 60.0)
	camera._physics_process(1.0 / 60.0)

	check(car.global_transform.is_equal_approx(exit * crossingOffset), "CarController did not apply the requested portal transform")
	check(camera.portalTransitionActive, "Chase camera should remain on the entry side after the car teleports")
	check(camera.global_position.distance_to(exit.origin) > 50.0, "Chase camera jumped directly to the exit portal")

	car.global_transform = exit * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 8.0))
	for index in 60:
		camera._physics_process(1.0 / 60.0)
		if !camera.portalTransitionActive:
			break

	check(!camera.portalTransitionActive, "Chase camera never crossed the entry portal")
	check(camera.global_position.distance_to(exit.origin) < 20.0, "Chase camera was not mapped to the exit portal")
	check(camera.doppler_tracking == Camera3D.DOPPLER_TRACKING_DISABLED, "Doppler tracking stayed enabled during the camera teleport")

	camera._physics_process(1.0 / 60.0)
	check(camera.doppler_tracking == Camera3D.DOPPLER_TRACKING_PHYSICS_STEP, "Doppler tracking was not restored after the teleport")

func testReversePortalCrossing(car: CarController, camera: FollowingCamera) -> void:
	var entry := Transform3D.IDENTITY
	var exit := Transform3D(Basis(Vector3.UP, -PI / 2.0), Vector3(-60.0, 1.0, 45.0))
	var reverseBasis := Basis(Vector3.UP, PI)
	var crossingOffset := Transform3D(reverseBasis, Vector3(0.0, 0.0, -0.1))

	camera.mode = 0
	camera.global_transform = Transform3D(reverseBasis, Vector3(0.0, 3.0, 4.0))
	car.global_transform = crossingOffset
	car.set_new_transform(entry, exit, crossingOffset)
	car._physics_process(1.0 / 60.0)
	camera._physics_process(1.0 / 60.0)

	check(camera.portalTransitionActive, "Reverse crossing should keep the chase camera on the entry side")
	check(camera.global_position.distance_to(exit.origin) > 30.0, "Reverse crossing moved the camera directly to the exit portal")

	car.global_transform = exit * Transform3D(reverseBasis, Vector3(0.0, 0.0, -8.0))
	for index in 60:
		camera._physics_process(1.0 / 60.0)
		if !camera.portalTransitionActive:
			break

	check(!camera.portalTransitionActive, "Chase camera never completed the reverse portal crossing")
	check(camera.global_position.distance_to(exit.origin) < 20.0, "Reverse crossing mapped the camera to the wrong side of the exit portal")

func testDelayedOrbitCrossing(car: CarController, camera: FollowingCamera) -> void:
	var entry := Transform3D.IDENTITY
	var exit := Transform3D(Basis(Vector3.UP, PI), Vector3(0.0, 0.0, 120.0))

	camera.mode = 2
	camera.global_transform = Transform3D(Basis.IDENTITY, Vector3(0.0, 2.75, -5.0))
	car.global_transform = exit * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.1))
	car.teleported.emit(entry, exit, -1.0)
	camera._physics_process(1.0 / 60.0)

	check(camera.portalTransitionActive, "Orbit camera should remain on the entry side after the car teleports")
	check(camera.global_position.z < 20.0, "Orbit camera jumped directly to the exit portal")

	car.global_transform = exit * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 12.0))
	for index in 90:
		camera._physics_process(1.0 / 60.0)
		if !camera.portalTransitionActive:
			break

	check(!camera.portalTransitionActive, "Orbit camera never crossed the entry portal")
	check(camera.global_position.z > 80.0, "Orbit camera was not mapped to the exit portal")

func testCameraAlreadyCrossed(car: CarController, camera: FollowingCamera) -> void:
	var entry := Transform3D.IDENTITY
	var exit := Transform3D(Basis(Vector3.UP, -PI / 2.0), Vector3(-80.0, 2.0, 35.0))

	camera.mode = 1
	camera.global_transform = Transform3D(Basis.IDENTITY, Vector3(0.0, 1.0, 0.25))
	car.global_transform = exit * Transform3D(Basis.IDENTITY, Vector3(0.0, 1.0, 0.25))
	car.teleported.emit(entry, exit, -1.0)

	check(!camera.portalTransitionActive, "A camera already beyond the entry plane should teleport immediately")
	check(camera.global_position.distance_to(exit * Vector3(0.0, 1.0, 0.25)) < 0.001, "Immediate camera teleport used the wrong transform")

func testRespawnSnap(car: CarController, camera: FollowingCamera) -> void:
	camera.mode = 0
	car.global_transform = Transform3D(Basis(Vector3.UP, PI / 3.0), Vector3(12.0, 4.0, -7.0))
	camera.global_position = Vector3(-100.0, 40.0, 80.0)
	camera.forceUpdatePosition()
	camera._physics_process(1.0 / 60.0)

	var expected := car.global_position + car.global_basis.y * 3.0 + car.global_basis.z * -4.0
	check(camera.global_position.distance_to(expected) < 0.001, "Respawn did not snap the camera to the car")
	check(!camera.portalTransitionActive, "Respawn left a stale portal transition active")
	check(camera.doppler_tracking == Camera3D.DOPPLER_TRACKING_DISABLED, "Respawn did not suppress the Doppler discontinuity")

	camera._physics_process(1.0 / 60.0)
	check(camera.doppler_tracking == Camera3D.DOPPLER_TRACKING_PHYSICS_STEP, "Respawn did not restore Doppler tracking")

func check(condition: bool, message: String) -> void:
	if !condition:
		failures.append(message)
