# This script acts as a generic base for each character in the game, extend it to add additional functionality
# NOTE that this script does not process any input at all, instead, methods that update movement etc. are called from PlayerInputProvider
class_name GenericCharacterController extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

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
func handleJump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		print("Performed jump.")

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
	print("Performed interact.")

# The generic character has no special ability, override this in the creature-specific script
func handleSpecialAbility() -> void:
	print("Performed special ability.")
