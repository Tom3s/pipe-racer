extends Control

@onready
var elements = %Elements

@onready
var masterVolumeSlider = %MasterVolumeSlider

@onready
var musicVolumeSlider = %MusicVolumeSlider

@onready
var sfxVolumeSlider = %SFXVolumeSlider

@onready
var closeButton = %CloseButton

func _ready():
	masterVolumeSlider.value_changed.connect(onMasterVolumeSlider_valueChanged)
	musicVolumeSlider.value_changed.connect(onMusicVolumeSlider_valueChanged)
	sfxVolumeSlider.value_changed.connect(onSFXVolumeSlider_valueChanged)
	closeButton.button_up.connect(onCloseButton_pressed)

func onMasterVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), remap(value, 0, 100, -80, 0))
	Playerstats.MASTER_VOLUME = value

func onMusicVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), remap(value, 0, 100, -80, 0))
	Playerstats.MUSIC_VOLUME = value

func onSFXVolumeSlider_valueChanged(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), remap(value, 0, 100, -80, 0))
	Playerstats.SFX_VOLUME = value

func onCloseButton_pressed():
	elements.hide()
