extends Control

class_name TutorialPrompt

@export var prompt_label: Label
@export var prompt_control_point: Control
@export var continue_prompt: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prompt_control_point.scale = Vector2.ZERO
	pass

var continue_tween: Tween
var prompt_tween: Tween
var tween_duration: float = 0.5

func show_prompt_with_audio(text: String, audioFile: String):
	AudioManager.play_sfx("res://Audio/SFX/" + audioFile)
	
	show_prompt(text)


func show_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_control_point.scale = Vector2.ZERO
		
	if(continue_tween):
		continue_tween.kill()
	continue_prompt.scale = Vector2.ZERO
	
	if prompt_tween:
		prompt_tween.kill()
		
	prompt_tween = get_tree().create_tween()
	prompt_tween.tween_property(prompt_control_point, "scale", Vector2.ONE, tween_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func hide_prompt() -> void:
	if(continue_tween):
		continue_tween.kill()
	continue_prompt.scale = Vector2.ZERO
	
	if prompt_tween:
		prompt_tween.kill()
		
	if(get_tree() == null):
		return
		
	prompt_tween = get_tree().create_tween()
	prompt_tween.tween_property(prompt_control_point, "scale", Vector2.ZERO, tween_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	prompt_tween.play()

func show_continue_prompt() -> void:
	if continue_tween:
		continue_tween.kill()
		
	if(get_tree() == null):
		return
		
	continue_tween = get_tree().create_tween()
	continue_tween.tween_property(continue_prompt, "scale", Vector2.ONE, tween_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
