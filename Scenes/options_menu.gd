extends Control


#declare the different set values in audio





#saving and loading methods here
func _load_files():
	pass
	

func _save_files():
	pass


func _on_save_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	#save method here


func _on_return_no_save_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
