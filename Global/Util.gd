extends Node
class_name Util

static func exp_decay(a: Variant, b: Variant, decay_rate: float, delta: float) -> Variant:
	return b + (a - b) * exp(-decay_rate * delta)