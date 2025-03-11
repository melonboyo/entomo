extends TabBar

#@onready var audio_manager = get_node("/root/AudioManager")
@onready var master_slider = $MasterSlider
@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SFXSlider
@onready var save_button = $"../../SaveReturn"
@onready var return_nosave = $"../../ReturnNoSave"
@export var wwiseRTPC:WwiseRTPC

var pending_changes = {}
var play_test_sfx := true


func _ready():
	master_slider.value = ConfigFileHandler.load_audio_setting("master_volume",master_slider.value)
	music_slider.value = ConfigFileHandler.load_audio_setting("music_volume",music_slider.value)
	sfx_slider.value = ConfigFileHandler.load_audio_setting("sfx_volume",sfx_slider.value)
	
	save_button.connect("pressed", Callable(self, "on_save_return_pressed"))
	
	
	master_slider.connect("value_changed", Callable(self, "on_master_slider_value_changed"))
	music_slider.connect("value_changed", Callable(self, "on_music_slider_value_changed"))
	sfx_slider.connect("value_changed", Callable(self, "on_sfx_slider_value_changed"))

func _on_master_slider_value_changed(value: float):
	
	print("Master slider changed to: ", value)
	AudioManager.set_global_volume(value)
	
	pending_changes["master_volume"] = value
	if play_test_sfx:
		play_test_sfx = false
		%SFXTimer.start()
		AudioManager.play_sfx("res://Audio/SFX/Frog/slurp.wav")


func _on_music_slider_value_changed(value: float):
	print("Music slider changed to: ", value)
	AudioManager.set_music_volume(value)
	pending_changes["music_volume"] = value


func _on_sfx_slider_value_changed(value: float):
	print("Effects slider changed to: ", value)
	AudioManager.change_sfx_volume(value)
	
	pending_changes["sfx_volume"] = value
	if play_test_sfx:
		play_test_sfx = false
		%SFXTimer.start()
		AudioManager.play_frog_sfx_pack()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_save_return_pressed() -> void:
	if pending_changes.is_empty():
		print("No changes to save!")
		return
	for key in pending_changes.keys():
		print("Saving setting:", key, "->", pending_changes[key])
		ConfigFileHandler.save_audio_setting(key, pending_changes[key])
	pending_changes.clear()
	print("Audio settings saved!")


func _on_return_no_save_pressed() -> void:
	pending_changes.clear()
	print("Audio settings not saved!")


func _on_sfx_timer_timeout() -> void:
	play_test_sfx = true
