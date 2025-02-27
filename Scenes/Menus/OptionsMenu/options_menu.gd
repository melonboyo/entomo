extends Control


func _on_save_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")
