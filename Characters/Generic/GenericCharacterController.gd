# This script acts as a generic base for each character in the game, extend it to add additional functionality
# NOTE that this script does not process any input at all, instead, methods that update movement etc. are called from PlayerInputProvider
class_name GenericCharacterController extends CharacterBody3D

@export_range(1,10) var size := 1
@export var game_state_manager: GameStateManager
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SIZE = 10 # Assumes orthographic camera
var held_character: GenericCharacterController = null

var is_in_switch_area := false
var current_switchable_character: GenericCharacterController = null

func _ready():
	pass

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

# The generic character can interact, this method should work the same for all cratures. 
func handleInteract() -> void:
	print("Performed interact.")
	if is_in_switch_area:
		# Try switch to another creature if interacted in its switch area
		handleSwitch()
		return
	if held_character:
		# Try exiting current creature
		handleExit()
		return

# The generic character has no special ability, override this in the creature-specific script
func handleSpecialAbility() -> void:
	print("Performed special ability.")

# Switch to another character
func handleSwitch() -> void:
	print("Handle switch")
	if not current_switchable_character:
		return
	if current_switchable_character.size < size:
		return
	velocity = Vector3.ZERO
	game_state_manager.switchCharacter(current_switchable_character)
	current_switchable_character.held_character = self
	disable()

func handleExit() -> void:
	held_character.global_position = global_position + Vector3.RIGHT*2
	held_character.enable()
	game_state_manager.switchCharacter(held_character)
	velocity = Vector3.ZERO
	held_character = null

# Called when a character enters this character's switch area
func _on_switch_area_body_entered(body):
	if game_state_manager.currentPossessedCreature != self:
		return
	if body == self:
		return
	print("Entered")
	is_in_switch_area = true
	current_switchable_character = body

# Called when a character exits this character's switch area
func _on_switch_area_body_exited(body):
	if game_state_manager.currentPossessedCreature != self:
		return
	if body == self:
		return
	print("Exited")
	is_in_switch_area = false
	current_switchable_character = null

# Generic function for disabling the creature
# Hides and makes it intangible
func disable():
	hide()
	$CollisionShape3D.disabled = true
	$SwitchArea.monitoring = false

# Generic function to enable the creature
# Unhides and makes it tangible
func enable():
	show()
	$CollisionShape3D.disabled = false
	$SwitchArea.monitoring = true
