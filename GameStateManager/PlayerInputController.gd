# This script is responsible for providing input to the current GenericCharacterController script, ensuring that only one character can be controlled at a time
extends Node3D

@export var currentPossessedCreature: GenericCharacterController = null
@export var camera: Camera3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(currentPossessedCreature == null or camera == null):
		return
	
	# Handle jump
	if Input.is_action_just_pressed("move_jump"):
		currentPossessedCreature.handleJump()
	
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
	
	# Simple camera follow for playtesting. TODO: implement proper camera follow as part of swapping between creatures
	camera.size = currentPossessedCreature.CAMERA_SIZE
	camera.position = currentPossessedCreature.position + Vector3(-10, 14, 10)
	
	pass
