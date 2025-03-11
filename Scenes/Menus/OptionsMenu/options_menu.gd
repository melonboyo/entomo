extends Control


@onready var audio: TabBar = %Audio
@onready var controls: TabBar = %Controls


func _on_save_return_pressed() -> void:
	controls.save_keybinds()
	audio.save_audio_settings()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")


func _on_return_no_save_pressed() -> void:
	controls.clear_keybinds()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")
