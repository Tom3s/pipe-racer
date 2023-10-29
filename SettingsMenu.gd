extends Control
class_name SettingsMenu

@onready var masterVolumeSlider: HSlider = %MasterVolumeSlider
@onready var musicVolumeSlider: HSlider = %MusicVolumeSlider
@onready var sfxVolumeSlider: HSlider = %SFXVolumeSlider
@onready var closeButton: Button = %CloseButton
@onready var fullscreenButton: Button = %FullscreenButton
@onready var renderQuality: OptionButton = %RenderQuality
@onready var fixPedalInput: CheckBox = %FixPedalInput
@onready var deadzoneSlider: HSlider = %DeadzoneSlider
@onready var deadzoneSpinbox: SpinBox = %DeadzoneSpinbox
@onready var smoothSteeringSlider: HSlider = %SmoothSteeringSlider
@onready var smoothSteeringSpinbox: SpinBox = %SmoothSteeringSpinbox

var renderQualities = [
	['Tometo (x0.25)', 0.25],
	['Low (x0.5)', 0.5],
	['Medium (x0.66)', 0.66],
	['High (x0.83)', 0.83],
	['Max (x1)', 1],
]

signal closePressed()

func _ready():
	masterVolumeSlider.value_changed.connect(onMasterVolumeSlider_valueChanged)
	musicVolumeSlider.value_changed.connect(onMusicVolumeSlider_valueChanged)
	sfxVolumeSlider.value_changed.connect(onSFXVolumeSlider_valueChanged)

	fullscreenButton.pressed.connect(onFullscreenButton_pressed)
	renderQuality.item_selected.connect(onRenderQuality_itemSelected)
	var index = 0
	for quality in renderQualities:
		renderQuality.add_item(quality[0])
		if is_equal_approx(quality[1], GlobalProperties.RENDER_QUALITY):
			renderQuality.selected = index
		index += 1

	fixPedalInput.toggled.connect(onFixPedalInput_toggled)

	# preciseInput.toggled.connect(onPreciseInput_toggled)
	deadzoneSlider.value_changed.connect(deadzoneSlider_valueChanged)
	deadzoneSpinbox.value_changed.connect(deadzoneSpinbox_valueChanged)
	smoothSteeringSlider.value_changed.connect(smoothSteeringSlider_valueChanged)
	smoothSteeringSpinbox.value_changed.connect(smoothSteeringSpinbox_valueChanged)

	closeButton.button_up.connect(onCloseButton_pressed)
	closeButton.grab_focus()

	visibility_changed.connect(onVisibilityChanged)

	masterVolumeSlider.value = GlobalProperties.MASTER_VOLUME
	musicVolumeSlider.value = GlobalProperties.MUSIC_VOLUME
	sfxVolumeSlider.value = GlobalProperties.SFX_VOLUME

	fixPedalInput.button_pressed = GlobalProperties.FIX_PEDAL_INPUT

	deadzoneSlider.value = GlobalProperties.DEADZONE
	deadzoneSpinbox.value = GlobalProperties.DEADZONE
	smoothSteeringSlider.value = GlobalProperties.SMOOTH_STEERING
	smoothSteeringSpinbox.value = GlobalProperties.SMOOTH_STEERING

	# preciseInput.button_pressed = GlobalProperties.PRECISE_INPUT

func onMasterVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), remapVolume(value))
	GlobalProperties.MASTER_VOLUME = value

func onMusicVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), remapVolume(value))
	GlobalProperties.MUSIC_VOLUME = value

func onSFXVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), remapVolume(value))
	GlobalProperties.SFX_VOLUME = value


const p1Accel: String = "p1_accelerate"
const p1Break: String = "p1_break"

@export
var fixedPedalAccelAxis: int = 7
@export
var fixedPedalBreakAxis: int = 8

func onFixPedalInput_toggled(fix: bool):

	# TODO: fix this with remapping
	# InputMap.action_erase_events(p1Accel)
	# var accelEvent = InputEventKey.new()
	# accelEvent.physical_keycode = KEY_UP
	# InputMap.action_add_event(p1Accel, accelEvent)

	# InputMap.action_erase_events(p1Break)
	# var breakEvent = InputEventKey.new()
	# breakEvent.physical_keycode = KEY_DOWN
	# InputMap.action_add_event(p1Break, breakEvent)

	# if !fix:
	# 	var accelJoypadEvent = InputEventJoypadMotion.new()
	# 	accelJoypadEvent.axis = JOY_AXIS_TRIGGER_RIGHT
	# 	accelJoypadEvent.device = 0
	# 	InputMap.action_add_event(p1Accel, accelJoypadEvent)

	# 	var breakJoypadEvent = InputEventJoypadMotion.new()
	# 	breakJoypadEvent.axis = JOY_AXIS_TRIGGER_LEFT
	# 	breakJoypadEvent.device = 0
	# 	InputMap.action_add_event(p1Break, breakJoypadEvent)
	# else:
	# 	var accelJoypadEvent = InputEventJoypadMotion.new()
	# 	accelJoypadEvent.axis = fixedPedalAccelAxis
	# 	accelJoypadEvent.device = 0
	# 	InputMap.action_add_event(p1Accel, accelJoypadEvent)

	# 	var breakJoypadEvent = InputEventJoypadMotion.new()
	# 	breakJoypadEvent.axis = fixedPedalBreakAxis
	# 	breakJoypadEvent.device = 0
	# 	InputMap.action_add_event(p1Break, breakJoypadEvent)


	GlobalProperties.FIX_PEDAL_INPUT = fix

# func onPreciseInput_toggled(preciseInput: bool):
# 	InputMap.action_set_deadzone("p1_turn_left", 0.0 if preciseInput else 0.1)
# 	InputMap.action_set_deadzone("p1_turn_right", 0.0 if preciseInput else 0.1)

# 	GlobalProperties.PRECISE_INPUT = preciseInput

func deadzoneSlider_valueChanged(value: float):
	deadzoneSpinbox.value = value
	changeDeadzone(value)

func deadzoneSpinbox_valueChanged(value: float):
	deadzoneSlider.value = value
	changeDeadzone(value)

func changeDeadzone(value):
	for i in 4:
		InputMap.action_set_deadzone("p" + str(i + 1) + "_turn_left", value)
		InputMap.action_set_deadzone("p" + str(i + 1) + "_turn_right", value)
	GlobalProperties.DEADZONE = value

func smoothSteeringSlider_valueChanged(value: float):
	smoothSteeringSpinbox.value = value
	changeSmoothSteering(value)

func smoothSteeringSpinbox_valueChanged(value: float):
	smoothSteeringSlider.value = value
	changeSmoothSteering(value)

func changeSmoothSteering(value):
	GlobalProperties.SMOOTH_STEERING = value


func onCloseButton_pressed():
	closePressed.emit()
	visible = false

func onVisibilityChanged():
	if visible:
		closeButton.grab_focus()

func remapVolume(value: float):
	return max((log(value) / log(10) - 2) * 20, -80)
	
func onFullscreenButton_pressed():
	GlobalProperties.FULLSCREEN = !GlobalProperties.FULLSCREEN

func onRenderQuality_itemSelected(index: int):
	GlobalProperties.RENDER_QUALITY = renderQualities[index][1]
