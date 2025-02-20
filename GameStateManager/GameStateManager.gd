# This script is responsible for providing input to the current GenericCharacterController script, ensuring that only one character can be controlled at a time
extends Node
class_name GameStateManager

@export var currentPossessedCreature: GenericCharacterController = null
@export var camera: Camera3D = null

signal zoom_changed(character: GenericCharacterController)
signal toggle_game_paused(is_paused : bool)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(currentPossessedCreature == null or camera == null):
		return
	
	# Handle jump
	if Input.is_action_just_pressed("move_jump"):
		currentPossessedCreature.jumpButtonPressed()
	if Input.is_action_just_released("move_jump"):
		currentPossessedCreature.jumpButtonReleased()
	
	# Handle moving
	currentPossessedCreature.handleMove(
		Input.get_vector("move_left", "move_right", "move_forward", "move_backward"),
		camera.basis,
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
	zoom_changed.emit(character)
	currentPossessedCreature = character
