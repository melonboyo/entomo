# This script is responsible for providing input to the current GenericCharacterController script, ensuring that only one character can be controlled at a time
extends Node
class_name GameStateManager

@export var currentPossessedCreature: GenericCharacterController = null
@export var camera: Camera3D = null
@export var first_flag: Flag
@export var tutorial_prompt: TutorialPrompt
@export var final_camera_focus: Node3D
var isInputEnabled = true
var is_player_alive = true

var maxStageReached = 0

signal zoom_changed(newFocus: Node3D, zoomSize: int)
signal toggle_game_paused(is_paused : bool)
signal show_victory_screen()
signal show_death_screen()
signal ending()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(first_flag != null):
		start_intro_tutorial()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(!is_intro_tutorial_done):
		if(Input.is_action_just_pressed("pause")):
			skip_intro_tutorial()
		elif(Input.is_anything_pressed()):
			continue_intro_tutorial()
	
	if(currentPossessedCreature == null or camera == null):
		return
		
	if(!isInputEnabled || !is_player_alive):
		currentPossessedCreature.handleMove(Vector2.ZERO, camera.global_basis, delta);
		return
	
	# Handle jump
	if Input.is_action_just_pressed("move_jump"):
		currentPossessedCreature.jumpButtonPressed()
	if Input.is_action_just_released("move_jump"):
		currentPossessedCreature.jumpButtonReleased()
	
	# Handle moving
	currentPossessedCreature.handleMove(
		Input.get_vector("move_left", "move_right", "move_forward", "move_backward"),
		camera.global_basis,
		delta
	)
	
	if(!has_shown_movement_tutorial && Input.get_vector("move_left", "move_right", "move_forward", "move_backward") != Vector2.ZERO):
		has_shown_movement_tutorial = true
		hide_tutorial_prompt()

	# Handle interacting
	if(Input.is_action_just_pressed("interact")):
		currentPossessedCreature.handleInteract()
		
	
	# Handle Special Ability
	if Input.is_action_just_pressed("special_ability"):
		currentPossessedCreature.specialAbilityButtonPressed()
	if Input.is_action_just_released("special_ability"):
		currentPossessedCreature.specialAbilityButtonReleased()
	
	#handle pausing the game
var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)
func _input(event: InputEvent):
		if(event.is_action_pressed("pause") and is_intro_tutorial_done):
			game_paused = !game_paused
		

func switchCharacter(character: GenericCharacterController):
	if(character.size > maxStageReached):
		maxStageReached = character.size
	
	zoom_changed.emit(character, character.size)
	currentPossessedCreature = character
	
	isInputEnabled = false
	await(get_tree().create_timer(1).timeout)
	character.switched_to_this_character()
	await(get_tree().create_timer(0.5).timeout)
	isInputEnabled = true

# Zooms out, pans over to the next flag, and zooms back to the player character
func show_flag(next_flag: Flag):
	isInputEnabled = false
	
	currentPossessedCreature.resetAbilities()
	await(get_tree().create_timer(0.5).timeout) # This timeout is to showcase the flag animation a little longer, should probably be moved somewhere else in the future
	zoom_changed.emit(currentPossessedCreature, next_flag.zoom_size)
	await(get_tree().create_timer(next_flag.zoom_out_duration).timeout)
	zoom_changed.emit(next_flag, next_flag.zoom_size, next_flag.focus_move_speed)
	await(get_tree().create_timer(next_flag.focus_duration).timeout)
	zoom_changed.emit(currentPossessedCreature, currentPossessedCreature.size)
	isInputEnabled = true

# Zooms out and shows the victory screen
func ending_reached():
	isInputEnabled = false
	zoom_changed.emit(%FinalCameraFocus, 5)
	show_tutorial_prompt_with_sound("Woah, the world is so beautiful from up here! What an adventure", "Parasite/Haha.wav")
	await(get_tree().create_timer(2).timeout)
	ending.emit()
	AudioManager.play_sfx("res://Audio/SFX/Other/gull.mp3")
	await(get_tree().create_timer(3).timeout)
	isInputEnabled = true
	game_paused = true
	show_victory_screen.emit()


func player_died():
	is_player_alive = false;
	zoom_changed.emit(currentPossessedCreature, currentPossessedCreature.size + 1)
	await(get_tree().create_timer(3).timeout)
	game_paused = true
	show_death_screen.emit()

#################################################### Tutorial stuff ####################################################
var has_shown_movement_tutorial = false
@export var intro_tutorial_lines = [
	"I'm just a tiny little parasite, life is so boring...", 
	"I want to see the world, but I'm stuck here!", 
	"If only I could find a creature to control...",
	]
	
var intro_tutorial_index = 0
var can_progress_tutorial = false
var is_intro_tutorial_done  = false

func start_intro_tutorial():
	isInputEnabled = false
	await(get_tree().create_timer(1).timeout)
	can_progress_tutorial = true
	continue_intro_tutorial()

func continue_intro_tutorial():
	if(is_intro_tutorial_done):
		return
	
	if(!can_progress_tutorial):
		return
	
	# Reached end of tutorial, start game
	if(intro_tutorial_index >= intro_tutorial_lines.size()):
		hide_tutorial_prompt()
		show_flag(first_flag)
		can_progress_tutorial = false
		is_intro_tutorial_done = true
		
		await(get_tree().create_timer(7).timeout)
		if(!has_shown_movement_tutorial):
			var key1 = InputMap.action_get_events("move_forward")[0].as_text().trim_suffix(" (Physical)")
			var key2 = InputMap.action_get_events("move_left")[0].as_text().trim_suffix(" (Physical)")
			var key3 = InputMap.action_get_events("move_backward")[0].as_text().trim_suffix(" (Physical)")
			var key4 = InputMap.action_get_events("move_right")[0].as_text().trim_suffix(" (Physical)")
			
			show_tutorial_prompt("Use " + key1 + ", " + key2 + ", " + key3 + " and " + key4 + " to move")
		return
	
	if(intro_tutorial_index != 0):
		show_tutorial_prompt(intro_tutorial_lines[intro_tutorial_index])
	else:
		show_tutorial_prompt_with_sound(intro_tutorial_lines[0], "Parasite/hmm.wav")
	
	intro_tutorial_index += 1
	
	var current_index = intro_tutorial_index
	
	can_progress_tutorial = false
	await(get_tree().create_timer(1).timeout)
	can_progress_tutorial = true
	
	# Show the continue prompt if the player hasn't already continued
	await(get_tree().create_timer(3).timeout)
	if(!is_intro_tutorial_done and intro_tutorial_index == current_index):
		tutorial_prompt.show_continue_prompt()

func skip_intro_tutorial():
	is_intro_tutorial_done = true
	hide_tutorial_prompt()
	isInputEnabled = true
	zoom_changed.emit(currentPossessedCreature, currentPossessedCreature.size)
	
# These two methods are available for objects in the scene that already reference GameStateManager to call
# For instance, the Bumblebee calls them to show the initial "press [E] to possess" prompt
func show_tutorial_prompt(prompt: String):
	tutorial_prompt.show_prompt(prompt)
	
func show_tutorial_prompt_with_sound(prompt: String, soundFile: String):
	tutorial_prompt.show_prompt_with_audio(prompt, soundFile)
	
func hide_tutorial_prompt():
	tutorial_prompt.hide_prompt()
