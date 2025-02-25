extends GenericCharacterController

var isFlying = false
@export var gravityMultiplier = 2
@export var flyingSpeed = 15
@export var maxFlyingStamina = 5
@export var rotationSpeed = 5
var currentFlyingStamina = 0.0

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

func _process(delta: float) -> void:
	if(isFlying and currentFlyingStamina > 0):
		var currentStamina = int((currentFlyingStamina / maxFlyingStamina) * 100)
		if(Time.get_ticks_msec() % 500 == 0):  
			print("Bumblebee stamina: " + str(currentStamina) + "%");
		currentFlyingStamina -= delta
		
	if(currentFlyingStamina <= 0):
		currentFlyingStamina = 0
		isFlying = false;
		
	if is_on_floor():
		currentFlyingStamina = maxFlyingStamina
		
func jumpButtonPressed() -> void:
	if is_on_floor():
		print("Bumblebee stamina: " + str(100) + "%");
		velocity.y = JUMP_VELOCITY * gravityMultiplier
		
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
