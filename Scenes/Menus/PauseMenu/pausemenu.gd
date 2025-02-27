extends Control
@export var game_manager : GameStateManager
@export var pause_panel: PanelContainer
@export var victory_panel: PanelContainer
@export var death_panel: PanelContainer
@export var final_flag: Flag

func _ready():
	hide()
	game_manager.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)
	game_manager.connect("show_victory_screen", _on_game_manager_show_victory_screen)
	game_manager.connect("show_death_screen", _on_game_manager_show_death_screen)






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
		pause_panel.show()
		victory_panel.hide()
		death_panel.hide()
	else:
		hide()
		
func _on_game_manager_show_victory_screen():
	show()
	victory_panel.show()
	pause_panel.hide()
	death_panel.hide()

func _on_game_manager_show_death_screen():
	show()
	death_panel.show()
	victory_panel.hide()
	pause_panel.hide()
	
func _on_return_pressed() -> void:
	game_manager.get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")
