extends Node
class_name Util

static func exp_decay(a: Variant, b: Variant, decay_rate: float, delta: float) -> Variant:
	return b + (a - b) * exp(-decay_rate * delta)

static func get_device_pass() -> String:
	var device_id: String = "%s%s%s%s" % [
		OS.get_name(),
		OS.get_processor_name(),
		OS.get_environment("USER"),
		OS.get_environment("USERNAME"),
	]

	return device_id.md5_text()