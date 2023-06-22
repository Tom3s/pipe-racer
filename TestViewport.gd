extends SubViewport

# var HudScene: IngameHUD = preload("res://HUD/HUD.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var car = %CarController
	var camera = FollowingCamera.new(car)
	add_child(camera)

	# var hud = HudScene.instantiate()
	# hud.prepare