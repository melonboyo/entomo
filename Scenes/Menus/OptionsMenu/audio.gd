extends TabBar

@onready var audio_manager = get_node("/root/AudioManager")
@onready var master_slider = $MarginContainer/Sliders/MasterSlider
@onready var music_slider = $MarginContainer/Sliders/MusicSlider
@onready var sfx_slider = $MarginContainer/Sliders/SFXSlider
@onready var save_button = $"../../SaveReturn"
@onready var return_nosave = $"../../ReturnNoSave"

var pending_changes = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	master_slider.value = ConfigFileHandler.load_audio_setting("master_volume",1.0)
	music_slider.value = ConfigFileHandler.load_audio_setting("music_volume",1.0)
	sfx_slider.value = ConfigFileHandler.load_audio_setting("sfx_volume",1.0)
	save_button.connect("pressed", Callable(self, "on_save_return_pressed"))
	
	
	master_slider.connect("value_changed", Callable(self, "on_master_slider_value_changed"))
	music_slider.connect("value_changed", Callable(self, "on_music_slider_value_changed"))
	sfx_slider.connect("value_changed", Callable(self, "on_sfx_slider_value_changed"))

func _on_master_slider_value_changed(value: float):
	audio_manager.set_global_volume("Master", value)
	pending_changes["master_volume"] = value
	
func _on_music_slider_value_changed(value: float):
	audio_manager.set_global_volume("Music", value)
	pending_changes["music_volume"] = value
	
func _on_sfx_slider_value_changed(value: float):
	audio_manager.set_global_volume("Effects", value)
	pending_changes["sfx_volume"] = value


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_return_pressed() -> void:
	for key in pending_changes.keys():
		ConfigFileHandler.save_audio_setting(key, pending_changes[key])
	pending_changes.clear()
	print("Audio settings saved!")


func _on_return_no_save_pressed() -> void:
	pending_changes.clear()
	print("Audio settings not saved!")
