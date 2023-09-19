extends Control
class_name SettingsMenu

@onready var masterVolumeSlider: HSlider = %MasterVolumeSlider
@onready var musicVolumeSlider: HSlider = %MusicVolumeSlider
@onready var sfxVolumeSlider: HSlider = %SFXVolumeSlider
@onready var closeButton: Button = %CloseButton
@onready var fullscreenButton: Button = %FullscreenButton
@onready var renderQuality: OptionButton = %RenderQuality

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

	closeButton.button_up.connect(onCloseButton_pressed)
	masterVolumeSlider.value = GlobalProperties.MASTER_VOLUME
	musicVolumeSlider.value = GlobalProperties.MUSIC_VOLUME
	sfxVolumeSlider.value = GlobalProperties.SFX_VOLUME

func onMasterVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), remapVolume(value))
	GlobalProperties.MASTER_VOLUME = value

func onMusicVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), remapVolume(value))
	GlobalProperties.MUSIC_VOLUME = value

func onSFXVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), remapVolume(value))
	GlobalProperties.SFX_VOLUME = value

func onCloseButton_pressed():
	closePressed.emit()
	visible = false

# def percent_to_db(percent, min_dB=-80, max_dB=0):
#     return min_dB + (max_dB - min_dB) * math.log10(percent / 100)

func remapVolume(value: float):
	# return -80 - 80 * (log(value) / log(10))
	return max((log(value) / log(10) - 2) * 20, -80)
	
func onFullscreenButton_pressed():
	GlobalProperties.FULLSCREEN = !GlobalProperties.FULLSCREEN

func onRenderQuality_itemSelected(index: int):
	GlobalProperties.RENDER_QUALITY = renderQualities[index][1]
