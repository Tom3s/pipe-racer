extends Control
class_name RebindMenu

const ACTION_ACCELERATE = "accelerate"
const ACTION_BREAK = "break"
const ACTION_TURN_LEFT = "turn_left"
const ACTION_TURN_RIGHT = "turn_right"
const ACTION_RESPAWN = "respawn"
const ACTION_DRIFT = "drift"
const ACTION_READY = "ready"
const ACTION_PAUSE = "pause"
const ACTION_RESET = "reset"
const ACTION_CHANGE_CAMERA_MODE = "change_camera_mode"

const ALL_ACTIONS: Array[String] = [
	ACTION_ACCELERATE,
	ACTION_BREAK,
	ACTION_TURN_LEFT,
	ACTION_TURN_RIGHT,
	ACTION_RESPAWN,
	ACTION_DRIFT,
	ACTION_READY,
	ACTION_PAUSE,
	ACTION_RESET,
	ACTION_CHANGE_CAMERA_MODE,
]

const CONTROLLER_BUTTON_ICONS = {
	JOY_BUTTON_A: "res://Sprites/XboxPrompts/A.png",
	JOY_BUTTON_B: "res://Sprites/XboxPrompts/B.png",
	JOY_BUTTON_X: "res://Sprites/XboxPrompts/X.png",
	JOY_BUTTON_Y: "res://Sprites/XboxPrompts/Y.png",
	JOY_BUTTON_BACK: "res://Sprites/XboxPrompts/View.png",
	JOY_BUTTON_START: "res://Sprites/XboxPrompts/Menu.png",
	JOY_BUTTON_LEFT_SHOULDER: "res://Sprites/XboxPrompts/LB.png",
	JOY_BUTTON_RIGHT_SHOULDER: "res://Sprites/XboxPrompts/RB.png",
}

const CONTROLLER_AXIS_ICONS = {
	JOY_AXIS_TRIGGER_LEFT: "res://Sprites/XboxPrompts/LT.png",
	JOY_AXIS_TRIGGER_RIGHT: "res://Sprites/XboxPrompts/RT.png",
	JOY_AXIS_LEFT_X: "res://Sprites/XboxPrompts/Left_Stick.png",
	JOY_AXIS_LEFT_Y: "res://Sprites/XboxPrompts/Left_Stick.png",
	JOY_AXIS_RIGHT_X: "res://Sprites/XboxPrompts/Right_Stick.png",
	JOY_AXIS_RIGHT_Y: "res://Sprites/XboxPrompts/Right_Stick.png",
}

const INVALID_JOY_ICON = "res://Sprites/InvalidJoyInput.png"
const INVALID_KEY_ICON = "res://Sprites/InvalidKeyInput.png"

static func isAxisAction(action: String):
	return action in [
		ACTION_ACCELERATE,
		ACTION_BREAK,
		ACTION_TURN_LEFT,
		ACTION_TURN_RIGHT,
	]

const controllerDefaultBindings = {
	# actionName: [joypadMapping, axisDirection (0 = not important)]
	ACTION_ACCELERATE: [JOY_AXIS_TRIGGER_RIGHT, 0],
	ACTION_BREAK: [JOY_AXIS_TRIGGER_LEFT, 0],
	ACTION_TURN_LEFT: [JOY_AXIS_LEFT_X, -1],
	ACTION_TURN_RIGHT: [JOY_AXIS_LEFT_X, 1],
	ACTION_RESPAWN: [JOY_BUTTON_Y, 0],
	ACTION_DRIFT: [JOY_BUTTON_X, 0],
	ACTION_READY: [JOY_BUTTON_BACK, 0],
	ACTION_PAUSE: [JOY_BUTTON_START, 0],
	ACTION_RESET: [JOY_BUTTON_B, 0],
	ACTION_CHANGE_CAMERA_MODE: [JOY_BUTTON_LEFT_SHOULDER, 0],
}

const defaultKeyboard1Bindings = {
	ACTION_ACCELERATE: KEY_UP,
	ACTION_BREAK: KEY_DOWN,
	ACTION_TURN_LEFT: KEY_LEFT,
	ACTION_TURN_RIGHT: KEY_RIGHT,
	ACTION_RESPAWN: KEY_ENTER,
	ACTION_DRIFT: KEY_SPACE,
	ACTION_READY: KEY_P,
	ACTION_PAUSE: KEY_ESCAPE,
	ACTION_RESET: KEY_BACKSPACE,
	ACTION_CHANGE_CAMERA_MODE: KEY_C,
}

const defaultKeyboard2Bindings = {
	ACTION_ACCELERATE: KEY_W,
	ACTION_BREAK: KEY_S,
	ACTION_TURN_LEFT: KEY_A,
	ACTION_TURN_RIGHT: KEY_D,
	ACTION_RESPAWN: KEY_R,
	ACTION_DRIFT: KEY_SHIFT,
	ACTION_READY: KEY_TAB,
	# ACTION_PAUSE: KEY_ESCAPE, # - not used to avoid p1-p2 conflict
	ACTION_RESET: KEY_R,
	ACTION_CHANGE_CAMERA_MODE: KEY_ALT,
}

func _ready():
	pass

