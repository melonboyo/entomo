extends Node

@onready var sfx_scene: PackedScene = load("res://AudioManager/SoundEffect.tscn")
@onready var music_player = $poop
@export_dir var music_folder_path: String = "res://Audio/Music"
@export_dir var frog_folder_path: String = "res://Audio/SFX/Frog/"
@export_dir var switch_folder_path: String = "res://Audio/SFX/Switch/"
var songlist: Dictionary = {}  # Dictionary to store song references by name
var froglist: Dictionary = {}  # Dictionary to store song references by name
var switchlist: Dictionary = {}  # Dictionary to store song references by name





func _ready() -> void:
	load_music_files()
	load_frog_sfx_pack()
	load_switch_sfx_pack()

func load_music_files(folder_path: String = ""):
	# Standard	
	var dir: DirAccess = DirAccess.open(music_folder_path + folder_path)
	if dir:
		dir.list_dir_begin()  # Start reading the directory
		var file_name = dir.get_next()

		while file_name != "":
			# Ignore "." and ".." which refer to the current and parent directory
			if file_name != "." and file_name != "..":
				var full_path = music_folder_path + folder_path + "/" + file_name
				if dir.current_is_dir():
					# Recursively load music files from subdirectories
					load_music_files(folder_path + "/" + file_name)
				elif file_name.ends_with(".wav.import") or file_name.ends_with(".mp3.import") or file_name.ends_with(".ogg.import"):
					if (file_name.ends_with(".import")):
						file_name = file_name.get_basename()
					var song_name = file_name.get_basename()  # Get the file name without extension
					songlist[song_name] = full_path.get_basename()  # Add full path to the dictionary
			file_name = dir.get_next()
		dir.list_dir_end()  # Close directory
	else:
		print("Error: Could not open folder at path:", music_folder_path + folder_path)

func load_frog_sfx_pack(folder_path: String = ""):
	var sfx_num = 0
	var dir: DirAccess = DirAccess.open(frog_folder_path + folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = frog_folder_path + folder_path + "/" + file_name
				if file_name.ends_with(".wav.import") or file_name.ends_with(".mp3.import") or file_name.ends_with(".ogg.import"):
					froglist[sfx_num] = full_path.get_basename()
					sfx_num += 1
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error: Could not open folder at path:", music_folder_path + folder_path)

func load_switch_sfx_pack(folder_path: String = ""):
	var sfx_num = 0
	var dir: DirAccess = DirAccess.open(switch_folder_path + folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = switch_folder_path + folder_path + "/" + file_name
				if file_name.ends_with(".wav.import") or file_name.ends_with(".mp3.import") or file_name.ends_with(".ogg.import"):
					switchlist[sfx_num] = full_path.get_basename()
					sfx_num += 1
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error: Could not open folder at path:", music_folder_path + folder_path)
# Uses and instantiates the sound_effect.tscn
func play_sfx(path: String, volume_modifier: float = 0):
	var sfx = sfx_scene.instantiate()
	sfx.stream = load(path)
	sfx.volume_db = 0 + volume_modifier
	add_child(sfx)
	return sfx
	
func play_frog_sfx_pack(volume_modifier: float = 0):
	var sfx = sfx_scene.instantiate()
	var num = randi_range(0, 2)
	print(froglist.get(num))
	sfx.stream = load(froglist.get(num))
	sfx.volume_db = 0 + volume_modifier
	add_child(sfx)
	
func play_switch_sfx_pack(volume_modifier: float = 0):
	var sfx = sfx_scene.instantiate()
	var num = randi_range(0, 2)
	print(switchlist.get(num))
	sfx.stream = load(switchlist.get(num))
	sfx.volume_db = 0 + volume_modifier
	add_child(sfx)



# Uses paths, not AudioStream.
func play_music(song_name: String, volume_modifier: float = 0, fade_time = 0.1):
	var song_path = songlist.get(song_name, null)
	if song_path:
		var music_stream = load(song_path)
		if music_stream:
			if music_player.stream:
				music_player.stop()  # Stop any currently playing music
			
			music_player.stream = music_stream
			
			music_player.volume_db = -40
			music_player.play()
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(music_player, "volume_db", 0 + volume_modifier, fade_time)
		else:
			print("Error: Could not load the music stream for song:", song_name)
	else:
		print("Error: Song name not found in songlist:", song_name)

func stop_music(fade_time: float = 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property(music_player, "volume_db", -40, fade_time)
	await tween.finished
	music_player.stop()

func set_global_volume(bus_name: String, amount: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	amount = linear_to_db(amount)
	AudioServer.set_bus_volume_db(bus_index, amount)

# Increases/decreases by db amount
func change_music_volume(db, fade_time: float = 0):
	db = 0 + db
	var tween = get_tree().create_tween()
	tween.tween_property(music_player, "volume_db", db, fade_time)
