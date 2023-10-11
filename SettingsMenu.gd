extends Control
class_name SettingsMenu

@onready var masterVolumeSlider: HSlider = %MasterVolumeSlider
@onready var musicVolumeSlider: HSlider = %MusicVolumeSlider
@onready var sfxVolumeSlider: HSlider = %SFXVolumeSlider
@onready var closeButton: Button = %CloseButton
@onready var fullscreenButton: Button = %FullscreenButton
@onready var renderQuality: OptionButton = %RenderQuality
@onready var fixPedalInput: CheckBox = %FixPedalInput

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

	closeButton.button_up.connect(onCloseButton_pressed)
	closeButton.grab_focus()

	visibility_changed.connect(onVisibilityChanged)

	masterVolumeSlider.value = GlobalProperties.MASTER_VOLUME
	musicVolumeSlider.value = GlobalProperties.MUSIC_VOLUME
	sfxVolumeSlider.value = GlobalProperties.SFX_VOLUME

	fixPedalInput.button_pressed = GlobalProperties.FIX_PEDAL_INPUT

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

	InputMap.action_erase_events(p1Accel)
	var accelEvent = InputEventKey.new()
	accelEvent.physical_keycode = KEY_UP
	InputMap.action_add_event(p1Accel, accelEvent)

	InputMap.action_erase_events(p1Break)
	var breakEvent = InputEventKey.new()
	breakEvent.physical_keycode = KEY_DOWN
	InputMap.action_add_event(p1Break, breakEvent)

	if !fix:
		var accelJoypadEvent = InputEventJoypadMotion.new()
		accelJoypadEvent.axis = JOY_AXIS_TRIGGER_RIGHT
		accelJoypadEvent.device = 0
		InputMap.action_add_event(p1Accel, accelJoypadEvent)

		var breakJoypadEvent = InputEventJoypadMotion.new()
		breakJoypadEvent.axis = JOY_AXIS_TRIGGER_LEFT
		breakJoypadEvent.device = 0
		InputMap.action_add_event(p1Break, breakJoypadEvent)
	else:
		var accelJoypadEvent = InputEventJoypadMotion.new()
		accelJoypadEvent.axis = fixedPedalAccelAxis
		accelJoypadEvent.device = 0
		InputMap.action_add_event(p1Accel, accelJoypadEvent)

		var breakJoypadEvent = InputEventJoypadMotion.new()
		breakJoypadEvent.axis = fixedPedalBreakAxis
		breakJoypadEvent.device = 0
		InputMap.action_add_event(p1Break, breakJoypadEvent)


	GlobalProperties.FIX_PEDAL_INPUT = fix

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
