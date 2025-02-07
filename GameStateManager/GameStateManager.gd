# This script is responsible for providing input to the current GenericCharacterController script, ensuring that only one character can be controlled at a time
extends Node
class_name GameStateManager

@export var currentPossessedCreature: GenericCharacterController = null
@export var camera: Camera3D = null
static var gameStateManagerInstance: GameStateManager 

func _init() -> void:
	if gameStateManagerInstance != null and gameStateManagerInstance != self:
		self.queue_free()
	gameStateManagerInstance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switchCreature(currentPossessedCreature)
	pass # Replace with function body.

func switchCreature(newCreature: GenericCharacterController) -> void:
	if(newCreature != null):
		currentPossessedCreature.lockMovement()
		currentPossessedCreature = newCreature
		currentPossessedCreature.possess(self)
	else:
		print("Error, newCreature not set to an instance!")

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
	if(Input.is_action_just_pressed("special_ability")):
		currentPossessedCreature.handleSpecialAbility()
	
	pass
