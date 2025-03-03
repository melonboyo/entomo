# This script is responsible for providing input to the current GenericCharacterController script, ensuring that only one character can be controlled at a time
extends Node
class_name GameStateManager

@export var currentPossessedCreature: GenericCharacterController = null
@export var camera: Camera3D = null
@export var first_flag: Flag
@export var tutorial_prompt: TutorialPrompt

var isInputEnabled = true
var is_player_alive = true

signal zoom_changed(newFocus: Node3D, zoomSize: int)
signal toggle_game_paused(is_paused : bool)
signal show_victory_screen()
signal show_death_screen()
signal show_help_screen()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	AudioManager.play_music("Froggu_Final", -5)
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
	zoom_changed.emit(character, character.size)
	currentPossessedCreature = character
	character.switched_to_this_character()

# Zooms out, pans over to the next flag, and zooms back to the player character
func show_flag(next_flag: Flag):
	isInputEnabled = false
	currentPossessedCreature.resetAbilities()
	zoom_changed.emit(currentPossessedCreature, next_flag.zoom_size)
	await(get_tree().create_timer(next_flag.zoom_out_duration).timeout)
	zoom_changed.emit(next_flag, next_flag.zoom_size, next_flag.focus_move_speed)
	await(get_tree().create_timer(next_flag.focus_duration).timeout)
	zoom_changed.emit(currentPossessedCreature, currentPossessedCreature.size)
	isInputEnabled = true

# Zooms out and shows the victory screen
func ending_reached():
	isInputEnabled = false
	zoom_changed.emit(currentPossessedCreature, 20)
	show_tutorial_prompt("Woah, the world is so beautiful from up here! What an adventure")
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
@export var intro_tutorial_lines = [
	"Life as a parasite is so boring...", 
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
		return
	
	show_tutorial_prompt(intro_tutorial_lines[intro_tutorial_index])
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
func hide_tutorial_prompt():
	tutorial_prompt.hide_prompt()
