extends Control

func resume():
	get_tree().paused = false
	hide()
func pause():
	get_tree().paused = true
	
func testEsc():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
		show()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()
		hide()





func _on_resume_pressed():
	resume()


func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()
	


func _on_quit_pressed():
	get_tree().quit()

func _process(delta):
	testEsc()
