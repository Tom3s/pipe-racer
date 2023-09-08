extends Control
class_name SettingsMenu

@onready var masterVolumeSlider = %MasterVolumeSlider
@onready var musicVolumeSlider = %MusicVolumeSlider
@onready var sfxVolumeSlider = %SFXVolumeSlider
@onready var closeButton = %CloseButton
@onready var fullscreenButton = %FullscreenButton


signal closePressed()

func _ready():
	masterVolumeSlider.value_changed.connect(onMasterVolumeSlider_valueChanged)
	musicVolumeSlider.value_changed.connect(onMusicVolumeSlider_valueChanged)
	sfxVolumeSlider.value_changed.connect(onSFXVolumeSlider_valueChanged)

	fullscreenButton.pressed.connect(onFullscreenButton_pressed)

	closeButton.button_up.connect(onCloseButton_pressed)
	masterVolumeSlider.value = Playerstats.MASTER_VOLUME
	musicVolumeSlider.value = Playerstats.MUSIC_VOLUME
	sfxVolumeSlider.value = Playerstats.SFX_VOLUME

func onMasterVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), remapVolume(value))
	Playerstats.MASTER_VOLUME = value

func onMusicVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), remapVolume(value))
	Playerstats.MUSIC_VOLUME = value

func onSFXVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), remapVolume(value))
	Playerstats.SFX_VOLUME = value

func onCloseButton_pressed():
	closePressed.emit()
	visible = false

# def percent_to_db(percent, min_dB=-80, max_dB=0):
#     return min_dB + (max_dB - min_dB) * math.log10(percent / 100)

func remapVolume(value: float):
	# return -80 - 80 * (log(value) / log(10))
	return max((log(value) / log(10) - 2) * 20, -80)
	
func onFullscreenButton_pressed():
	Playerstats.FULLSCREEN = !Playerstats.FULLSCREEN
