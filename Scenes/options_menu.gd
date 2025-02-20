extends Control



func _on_save_return_pressed() -> void:
	pass # Replace with function body.


func _on_return_no_save_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
