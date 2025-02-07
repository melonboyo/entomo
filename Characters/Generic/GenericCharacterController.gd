# This script acts as a generic base for each character in the game, extend it to add additional functionality
# NOTE that this script does not process any input at all, instead, methods that update movement etc. are called from PlayerInputProvider
class_name GenericCharacterController extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SIZE = 10 # Assumes orthographic camera

var gameStateManagerInstance: GameStateManager

# Lock the character's movement on load, this ensures that we don't get any weird physics interactions
func _init() -> void:
	lockMovement()
	
# Locks the character's movement
func lockMovement() -> void:
	axis_lock_linear_x = true
	axis_lock_linear_y = true
	axis_lock_linear_z = true

# Unlocks the character's movement
func unlockMovement() -> void:
	axis_lock_linear_x = false
	axis_lock_linear_y = false
	axis_lock_linear_z = false

func possess(gsm: GameStateManager) -> void:
	unlockMovement()
	gameStateManagerInstance = gsm

# Update the physics body each physics tick
func _physics_process(delta: float) -> void:
	# Add gravity
	handleGravity(delta)
	
	# move_and_slide is called each physics tick
	move_and_slide()
		
# The generic character uses gravity
func handleGravity(delta: float) -> void:
	if not is_on_floor():
			velocity += get_gravity() * delta

# The generic character jumps when the jump button is pressed and they are on the ground, override this in the creature-specific script for additional functionality 
func jumpButtonPressed() -> void:
	print("Jump button pressed.")
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		print("Performed jump.")
		
# Override this in the creature-specific script for additional functionality 
func jumpButtonReleased() -> void:
	print("Jump button released.");

# The handleMove method of Generic Character Controller is called every tick
func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

# TODO: Implement generic character interaction
# The generic character can interact, this method should work the same for all cratures. 
func handleInteract() -> void:
	if gameStateManagerInstance == null:
		print("Error, no GameStateManager in scene!")
		return
		
	if currentCloseCharacter != null:
		gameStateManagerInstance.switchCreature(currentCloseCharacter)

# The generic character has no special ability, override this in the creature-specific script
func specialAbilityButtonPressed() -> void:
	print("Special ability button pressed.")

# The generic character has no special ability, override this in the creature-specific script
func specialAbilityButtonReleased() -> void:
	print("Special ability button released.")

var currentCloseCharacter: GenericCharacterController = null
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body as GenericCharacterController:
		currentCloseCharacter = body as GenericCharacterController

func _on_area_3d_body_exited(body: Node3D) -> void:
	currentCloseCharacter = null
