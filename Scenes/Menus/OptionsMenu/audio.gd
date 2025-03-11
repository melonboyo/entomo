#@tool
extends TabBar


@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var FX_BUS_ID = AudioServer.get_bus_index("Effects")

var music_level := 0.7
var sfx_level := 0.7


func _ready() -> void:
	music_level = ConfigFileHandler.load_audio_setting("Music")
	sfx_level = ConfigFileHandler.load_audio_setting("Effects")
	
	apply_settings_to_bus(MUSIC_BUS_ID, music_level)
	apply_settings_to_bus(FX_BUS_ID, sfx_level)
	
	$MusicSlider.set_value_no_signal(music_level)
	$SFXSlider.set_value_no_signal(sfx_level)


func _on_music_slider_value_changed(value):
	music_level = value
	apply_settings_to_bus(MUSIC_BUS_ID, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_level = value
	apply_settings_to_bus(FX_BUS_ID, value)


func apply_settings_to_bus(id: int, value):
	AudioServer.set_bus_volume_db(id, linear_to_db(value))
	AudioServer.set_bus_mute(id, linear_to_db(value) < .005)


func save_audio_settings():
	ConfigFileHandler.save_audio_setting("Music", music_level)
	ConfigFileHandler.save_audio_setting("Effects", sfx_level)
