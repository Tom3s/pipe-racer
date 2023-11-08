extends Control
class_name SettingsMenu

@onready var masterVolumeSlider: HSlider = %MasterVolumeSlider
@onready var musicVolumeSlider: HSlider = %MusicVolumeSlider
@onready var sfxVolumeSlider: HSlider = %SFXVolumeSlider
@onready var closeButton: Button = %CloseButton
@onready var fullscreenButton: Button = %FullscreenButton
@onready var renderQuality: OptionButton = %RenderQuality
@onready var fixPedalInput: CheckBox = %FixPedalInput
@onready var compareAgainstBestLap: CheckBox = %CompareAgainstBestLap
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
	compareAgainstBestLap.toggled.connect(onCompareAgainstBestLap_toggled)

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
	compareAgainstBestLap.button_pressed = GlobalProperties.COMPARE_AGAINST_BEST_LAP

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
	GlobalProperties.FIX_PEDAL_INPUT = fix

func onCompareAgainstBestLap_toggled(compare: bool):
	GlobalProperties.COMPARE_AGAINST_BEST_LAP = compare

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
	await animateOut()
	visible = false
	closePressed.emit()
	position = Vector2(0, 0)

func onVisibilityChanged():
	if visible:
		closeButton.grab_focus()

func remapVolume(value: float):
	return max((log(value) / log(10) - 2) * 20, -80)
	
func onFullscreenButton_pressed():
	GlobalProperties.FULLSCREEN = !GlobalProperties.FULLSCREEN

func onRenderQuality_itemSelected(index: int):
	GlobalProperties.RENDER_QUALITY = renderQualities[index][1]

const ANIMATE_TIME = 0.3
func animateIn():
	var tween = create_tween()

	var windowSize = get_viewport_rect().size

	tween.tween_property(self, "position", Vector2(0, -windowSize.y), 0.0)\
		.as_relative()\
		# .set_ease(Tween.EASE_OUT)\
		# .set_trans(Tween.TRANS_EXPO)\
		.finished.connect(show)
	
	tween = create_tween()

	tween.tween_property(self, "position", Vector2(0, windowSize.y), ANIMATE_TIME)\
		.as_relative()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_EXPO)
		# .finished.connect(show)
	
	# visible = true

func animateOut():
	var tween = create_tween()

	var windowSize = get_viewport_rect().size

	tween.tween_property(self, "position", Vector2(0, -windowSize.y), ANIMATE_TIME)\
		.as_relative()\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)
		# .finished.connect(onAnimateOutFinished)
	return tween.finished

func onAnimateOutFinished():
	visible = false