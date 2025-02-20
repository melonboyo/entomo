extends Control
@export var game_manager : GameStateManager

func _ready():
	hide()
	game_manager.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)






func _on_resume_pressed():
	game_manager.get_tree().paused = false
	hide()


func _on_restart_pressed():
	
	game_manager.get_tree().paused = false
	get_tree().reload_current_scene()
	
	


func _on_quit_pressed():
	get_tree().quit()
	
func _process(delta):
	pass

func _on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		show()
	else:
		hide()
	
	


func _on_return_pressed() -> void:
	game_manager.get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
