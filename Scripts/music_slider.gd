extends "res://Scenes/options_menu.gd"

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var FX_BUS_ID = AudioServer.get_bus_index("Effects")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .005)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(FX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(FX_BUS_ID, value < .005)
