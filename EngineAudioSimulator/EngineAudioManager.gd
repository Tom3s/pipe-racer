extends Node3D
class_name EngineAudioManager

@onready var on_high: AudioStreamPlayer3D = %OnHigh
@onready var on_low: AudioStreamPlayer3D = %OnLow
@onready var off_high: AudioStreamPlayer3D = %OffHigh
@onready var off_low: AudioStreamPlayer3D = %OffLow
@onready var limiter: AudioStreamPlayer3D = %Limiter
@onready var backfire: AudioStreamPlayer3D = %Backfire

class CrossFade:
	var gain1: float
	var gain2: float

	func _init(g1: float, g2: float) -> void:
		gain1 = g1
		gain2 = g2

static func crossFade(value: float, start: float, end: float) -> CrossFade:
	var x = clamp((value - start) / (end - start), 0, 1)
	var gain1 = cos((1.0 - x) * 0.5 * PI)
	var gain2 = cos(x * 0.5 * PI)

	return CrossFade.new(gain1, gain2)

func start_all_sounds() -> void:
	on_high.playing = true
	on_low.playing = true
	off_high.playing = true
	off_low.playing = true
	limiter.playing = true

func play_backfire() -> void:
	backfire.play()