extends GenericCharacterController

var isFlying = false
@export var gravityMultiplier = 2
@export var flyingSpeed = 15
@export var maxFlyingStamina = 5
@export var left_wing : Node3D
@export var right_wing : Node3D
var currentFlyingStamina = 0.0
@onready var akState = $AkState

# This goes from 0 to 1, and is used to smoothly go between the squish animation and being still
var animation_amount = 0

# Overrides the handleMove method of GenericCharacterController
func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	
	# Movement speed dependent on if bug are airborne or grounded
	var s = flyingSpeed if isFlying else SPEED
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * s
		velocity.z = direction.z * s
	else:
		velocity.x = move_toward(velocity.x, 0, s)
		velocity.z = move_toward(velocity.z, 0, s)
		
	# Rotation
	if(input_dir != Vector2.ZERO):
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * rotationSpeed)

var has_shown_stamina_prompt_before = false # Used to show the tiredness prompt the first time
func _process(delta: float) -> void:
	var stamina_fraction = currentFlyingStamina / maxFlyingStamina
	if(isFlying and currentFlyingStamina > 0):
		var currentStamina = int(stamina_fraction * 100)
		if(Time.get_ticks_msec() % 500 == 0):  
			print("Bumblebee stamina: " + str(currentStamina) + "%");
		currentFlyingStamina -= delta
		
		if(!has_shown_stamina_prompt_before and currentStamina < 50):
			has_shown_stamina_prompt_before = true
			game_state_manager.show_tutorial_prompt("This is heavy, I can't make it much longer..." )
			await(get_tree().create_timer(1.5).timeout)
			game_state_manager.hide_tutorial_prompt()
		
	if(currentFlyingStamina <= 0):
		currentFlyingStamina = 0
		isFlying = false;
		
	if is_on_floor():
		currentFlyingStamina = maxFlyingStamina
	
	if(!isFlying):
		animation_amount -= delta * 5
	else:
		animation_amount += delta * 5
	
	var f = 1 - stamina_fraction
	var max_flap_intensity = 1 - (f * f * f * f)
	animation_amount = max(min(animation_amount, max_flap_intensity), 0);
	
	var flaps_per_second = 60
	var flap_magnitude = 30
	
	left_wing.rotation_degrees.z = (13.4 - sin(Time.get_ticks_msec() * 0.001 * flaps_per_second) * flap_magnitude * animation_amount)
	right_wing.rotation_degrees.z = (13.4 + sin(Time.get_ticks_msec() * 0.001 * flaps_per_second) * flap_magnitude * animation_amount)
		
func jumpButtonPressed() -> void:
	if is_on_floor():
		print("Bumblebee stamina: " + str(100) + "%");
		velocity.y = JUMP_VELOCITY * gravityMultiplier
		
		if(!has_flown_before):
			has_flown_before = true
			game_state_manager.hide_tutorial_prompt()
		
	if(currentFlyingStamina > 0):
		isFlying = true;

func jumpButtonReleased() -> void:
	isFlying = false;

func handleGravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * gravityMultiplier
		
	if isFlying and velocity.y < 0:
		velocity.y = 0
	
func resetAbilities():
	isFlying = false

############################################### Tutorial prompts about this creature ###############################################
var has_been_controlled_before = false # Used to show a prompt when the player enteres this creature's area for the first time
var has_flown_before = false # Used to show a prompt the first time the player flies
func _on_switch_area_body_entered(body):
	super(body)
	
	if(body == self):
		return
	
	if(has_been_controlled_before):
		return
	
	if(body as Parasite):
		var key = InputMap.action_get_events("interact")[0].as_text().trim_suffix(" (Physical)")
		if(key.length() == 0):
			key = "null"
		key[0] = key[0].to_upper()
		game_state_manager.show_tutorial_prompt("A bumblebee! Press [" + key + "] to possess" )
		akState.set_value()

# Called when a character exits this character's switch area
func _on_switch_area_body_exited(body):
	super(body)
	
	if(body == self):
		return
	
	if(has_been_controlled_before):
		return
	
	if(body as Parasite):
		game_state_manager.hide_tutorial_prompt()
		
func switched_to_this_character():
	if(has_been_controlled_before):
		return
	
	has_been_controlled_before = true
	game_state_manager.hide_tutorial_prompt()
	
	await(get_tree().create_timer(1.5).timeout)
	
	var key = InputMap.action_get_events("move_jump")[0].as_text().trim_suffix(" (Physical)")
	if(key.length() == 0):
		key = "null"
	key[0] = key[0].to_upper()
	
	# The player may already have flown during the 1.5s wait above
	if(has_flown_before):
		return
		
	game_state_manager.show_tutorial_prompt("Woah! Let's explore! Hold [" + key + "] to hover")
