extends Node

var newConfig = ConfigFile.new()
var audio_settings = {}
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		#initial keybinding settings
		newConfig.set_value("keybinding","move_forward","W")
		newConfig.set_value("keybinding","move_backward","S")
		newConfig.set_value("keybinding","move_left","A")
		newConfig.set_value("keybinding","move_right","D")
		newConfig.set_value("keybinding","move_jump","Space")
		newConfig.set_value("keybinding","special_ability","Q")
		newConfig.set_value("keybinding","interact","E")
		newConfig.set_value("keybinding","pause","Escape")
		
		#initial audio settings
		newConfig.set_value("audio", "master_volume", 1.0)
		newConfig.set_value("audio", "music_volume", 1.0)
		newConfig.set_value("audio", "sfx_volume", 1.0)
		
		newConfig.save(SETTINGS_FILE_PATH)
	else:
		newConfig.load(SETTINGS_FILE_PATH)

func save_audio_setting(key: String, value):
	newConfig.set_value("audio", key, value)
	newConfig.save(SETTINGS_FILE_PATH)

func load_audio_setting(key: String, default_value: float):
	if newConfig.has_section_key("audio", key):
		return newConfig.get_value("audio",key, default_value)
	return default_value

func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
		
	newConfig.set_value("keybinding", action, event_str)
	newConfig.save(SETTINGS_FILE_PATH)


func load_keybinding():
	var keybindings = {}
	var keys = newConfig.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = newConfig.get_value("keybinding", key)
		input_event = InputEventKey.new()
		input_event.keycode = OS.find_keycode_from_string(event_str)
		keybindings[key] = input_event
	return keybindings
	
