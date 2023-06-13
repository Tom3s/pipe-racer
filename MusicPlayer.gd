extends Node

class_name MusicPlayer

var menuMusic: AudioStreamPlayer = null
var ingameMusic: AudioStreamPlayer = null

func _ready():
	menuMusic = get_child(0)
	ingameMusic = get_child(1)
	# menuMusic.targetVolume = 0.0
	# ingameMusic.targetVolume = -60.0
	menuMusic.volume_db = -60.0
	ingameMusic.volume_db = -60.0
	menuMusic.targetVolume = 0.0
	ingameMusic.targetVolume = -60.0
	menuMusic.play()
	ingameMusic.play()
	
	set_physics_process(true)

@export_range(0, 5, 0.1)
var FADE_TIME: float = 0.2

func playMenuMusic():
	menuMusic.fadeTo(0.0, FADE_TIME)
	ingameMusic.fadeTo(-60.0, FADE_TIME)
	# var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	# tween.tween_property(menuMusic, "volume_db", 0.0, FADE_TIME)
	# tween.parallel().tween_property(ingameMusic, "volume_db", -60.0, FADE_TIME)


func playIngameMusic():
	menuMusic.fadeTo(-60.0, FADE_TIME)
	ingameMusic.fadeTo(0.0, FADE_TIME)
	# var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	# tween.tween_property(menuMusic, "volume_db", -60.0, FADE_TIME)
	# tween.parallel().tween_property(ingameMusic, "volume_db", 0.0, FADE_TIME)
