# This script acts as a generic base for each character in the game, extend it to add additional functionality
# NOTE that this script does not process any input at all, instead, methods that update movement etc. are called from PlayerInputProvider
class_name GenericCharacterController extends CharacterBody3D

@export_range(1,10) var size := 1
@export var game_state_manager: GameStateManager
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SIZE = 10 # Assumes orthographic camera
@export var exitPosition: Node3D
@export var enter_position: Node3D
@export var mesh_pivot: Node3D
@export var rotationSpeed = 5
var held_character: GenericCharacterController = null

var is_in_switch_area := false
var current_switchable_character: GenericCharacterController = null
var direction_facing: Vector3 = Vector3.ZERO

func _ready():
	pass

# Update the physics body each physics tick
func _physics_process(delta: float) -> void:
	if game_state_manager.currentPossessedCreature == self:
	# Add gravity
		handleGravity(delta)
	
		# move_and_slide is called each physics tick
		move_and_slide()
	elif !is_inside_other_creature:
		move_and_collide(get_gravity() * delta)
		
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
		
func jumpButtonReleased() -> void:
	print("Jump button released.");

# The handleMove method of Generic Character Controller is called every tick
func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		direction_facing = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if(input_dir != Vector2.ZERO):
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * rotationSpeed)

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
func specialAbilityButtonPressed() -> void:
	print("Special ability button pressed.")
	
func specialAbilityButtonReleased() -> void:
	print("Special ability button released.")

# Switch to another character
func handleSwitch() -> void:
	if not current_switchable_character:
		return
	if current_switchable_character.size < size:	
		return
	
	velocity = Vector3.ZERO
	resetAbilities()
	game_state_manager.switchCharacter(current_switchable_character)
	current_switchable_character.held_character = self
	AudioManager.play_switch_sfx_pack(-15.0)
	
	$CollisionShape3D.disabled = true
	var move_tween = get_tree().create_tween()
	move_tween.parallel().tween_property(self, "global_position", current_switchable_character.enter_position.global_position, 1)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(mesh_pivot, "scale", Vector3(0.2, 0.2, 0.2), 1)
	move_tween.tween_callback(disable)

func resetAbilities():
	pass

func handleExit() -> void:
	resetAbilities()
	held_character.global_position = enter_position.global_position
	held_character.animate_exiting_character(exitPosition.global_position)
	game_state_manager.switchCharacter(held_character)
	velocity = Vector3.ZERO
	held_character = null

# Called when a character enters this character's switch area
func _on_switch_area_body_entered(body):
	if game_state_manager.currentPossessedCreature == self:
		return
	if body == self:
		return
	var c = body as GenericCharacterController
	if(c == null):
		return
	c.set_switchable_body_to(self)

# Called when a character exits this character's switch area
func _on_switch_area_body_exited(body):
	if game_state_manager.currentPossessedCreature == self:
		return
	if body == self:
		return
	var c = body as GenericCharacterController
	if(c == null):
		return
	c.reset_switchable_body()

func set_switchable_body_to(body: GenericCharacterController) -> void:
	current_switchable_character = body
	is_in_switch_area = true

func reset_switchable_body() -> void:
	current_switchable_character = null
	is_in_switch_area = false

var is_inside_other_creature = false
# Generic function for disabling the creature
# Hides and makes it intangible
func disable():
	hide()
	$CollisionShape3D.disabled = true
	$SwitchArea.monitoring = false
	is_inside_other_creature = true

func animate_exiting_character(move_to_position: Vector3):
	show()
	$CollisionShape3D.disabled = true
	$SwitchArea.monitoring = false
	
	var move_tween = create_tween()
	move_tween.parallel().tween_property(self, "global_position", move_to_position, 1)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(mesh_pivot, "scale", Vector3.ONE, 1)
	move_tween.tween_callback(enable)

# Generic function to enable the creature
# Unhides and makes it tangible
func enable():
	show()
	$CollisionShape3D.disabled = false
	$SwitchArea.monitoring = true
	is_inside_other_creature = false

# Kills the player when they enter water, override this method in child class to stop this behaviour
# TODO: change this to be more generalized, being able to enter different types of areas (if necessary)
func entered_water():
	if(game_state_manager.currentPossessedCreature != self):
		return
		
	game_state_manager.player_died()
	
# This method is called when the creature gets possessed
func switched_to_this_character():
	#var bounce_tween = create_tween()
	#bounce_tween.tween_property(mesh_pivot, "scale", Vector3.ONE * 1.2, 1.0).set_trans(Tween.TRANS_BACK).set_delay(0.5)
	#bounce_tween.tween_property(mesh_pivot, "scale", Vector3.ONE, 1.0);
	#print("DASUHIO")
	pass

func _on_switch_area_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
