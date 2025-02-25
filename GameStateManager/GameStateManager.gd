# This script is responsible for providing input to the current GenericCharacterController script, ensuring that only one character can be controlled at a time
extends Node
class_name GameStateManager

@export var currentPossessedCreature: GenericCharacterController = null
@export var camera: Camera3D = null
@export var first_flag: Flag

var isInputEnabled = true

signal zoom_changed(newFocus: Node3D, zoomSize: int)
signal toggle_game_paused(is_paused : bool)
signal show_victory_screen()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(first_flag != null):
		show_flag(first_flag)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(currentPossessedCreature == null or camera == null):
		return
		
	if(!isInputEnabled):
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
		if(event.is_action_pressed("pause")):
			game_paused = !game_paused
		

func switchCharacter(character: GenericCharacterController):
	zoom_changed.emit(character, character.size)
	currentPossessedCreature = character

# Zooms out, pans over to the next flag, and zooms back to the player character
func show_flag(next_flag: Flag):
	isInputEnabled = false
	zoom_changed.emit(currentPossessedCreature, next_flag.zoom_size)
	await(get_tree().create_timer(next_flag.zoom_out_duration).timeout)
	zoom_changed.emit(next_flag, next_flag.zoom_size, next_flag.focus_move_speed)
	await(get_tree().create_timer(next_flag.focus_duration).timeout)
	zoom_changed.emit(currentPossessedCreature, currentPossessedCreature.size)
	isInputEnabled = true

# Zooms out and shows the victory screen
func ending_reached():
	isInputEnabled = false
	zoom_changed.emit(currentPossessedCreature, 10)
	await(get_tree().create_timer(3).timeout)
	isInputEnabled = true
	game_paused = true
	show_victory_screen.emit()
