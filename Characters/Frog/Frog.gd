extends GenericCharacterController

var isChargingJump = false
var isJumpButtonDown = false;
var currentJumpVelocityPercentage = 0
var currentMovementDirection = Vector3.ZERO
var isToungeOut = false

@export var timeToReachFullJumpVelocity = 0.5
@export var gravityMultiplier = 10
@export var rotationSpeed = 5
@export var airborneMovementControl = 0.5;
@export var minJumpVelocity = 20
@export var jumpForwardVelocity = 60


@export var raycast : RayCast3D
@export var toungeCollision : Node3D
@export var toungeMesh : Node3D
@export var collisionScaleDifference : float
@export var collisionOffsetDifference : float

var was_on_floor_last_frame = true

func _ready() -> void:
	super._ready()
	$froggy_v3/AnimationPlayer.play("idle_croak")
	

# Overrides the handleMove method of GenericCharacterController
func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	
	if(isToungeOut):
		return
	
	if(is_on_floor() && !was_on_floor_last_frame):
		$froggy_v3/AnimationPlayer.play("idle_croak")
	
	was_on_floor_last_frame = is_on_floor();
	
	# Movement speed dependent on if bug are airborne or grounded
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	currentMovementDirection = direction
	
	if is_on_floor() and velocity.y <= 0:
		if direction and !isChargingJump:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0
			velocity.z = 0
	
	if not is_on_floor():
		var s = SPEED * airborneMovementControl
		if direction:
			velocity.x += direction.x * s * delta
			velocity.z += direction.z * s * delta
			
		var xzPlaneVelocityMagnitude = Vector2(velocity.x, velocity.z).length()
		if Vector2(velocity.x, velocity.z).length() > jumpForwardVelocity:
			velocity.x = velocity.x / xzPlaneVelocityMagnitude * jumpForwardVelocity
			velocity.z = velocity.z / xzPlaneVelocityMagnitude * jumpForwardVelocity
		
	# Rotation
	if(input_dir != Vector2.ZERO):
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * rotationSpeed)

func _process(delta: float) -> void:
	if(isChargingJump):
		currentJumpVelocityPercentage += delta / timeToReachFullJumpVelocity
		if(currentJumpVelocityPercentage > 1):
			currentJumpVelocityPercentage = 1
			
func specialAbilityButtonPressed() -> void:
	$froggy_v3/AnimationPlayer.play("idle_croak")
	if(isToungeOut):
		lerpToungeMesh(toungeCollision.scale.z, 0.1, 0.2)
		
		toungeCollision.scale.z = 0.1
		toungeCollision.position.z = 0
		
		isToungeOut = false
	elif(raycast.is_colliding()):
		print("A")
		var collisionPoint = raycast.get_collision_point()
		var distance = collisionPoint.distance_to(raycast.global_position)
				
		lerpToungeMesh(0.1, distance, 0.1)
		
		toungeCollision.position.z = ((distance / 2) * -1) + collisionOffsetDifference
		toungeCollision.scale.z = distance - collisionScaleDifference
		
		print(distance)
		isToungeOut = true
	else:
		quickToungeAnimation(100)

func lerpToungeMesh(distanceStart, distanceEnd, delay):
	
	var startingDelay = delay
		
	while delay > 0:
		delay -= get_process_delta_time()
		await get_tree().process_frame
		var t = 1 - delay/startingDelay
		var currentDistance = distanceStart + (distanceEnd - distanceStart) * t
		
		toungeMesh.position.z = ((currentDistance / 2) * -1) + collisionOffsetDifference
		toungeMesh.scale.y = max(currentDistance - collisionScaleDifference, 0.1)

func quickToungeAnimation(distance):
	lerpToungeMesh(0.1, distance, 0.15)
	await get_tree().create_timer(0.1).timeout
	lerpToungeMesh(distance, 0.1, 0.1)

func jumpButtonPressed() -> void:
	currentJumpVelocityPercentage = 0
	isChargingJump = true
	$froggy_v3/AnimationPlayer.play("squish")
		
func jumpButtonReleased() -> void:
	if(isChargingJump and is_on_floor() and !isToungeOut):
		jump(
			(currentJumpVelocityPercentage * JUMP_VELOCITY + minJumpVelocity) / (JUMP_VELOCITY + minJumpVelocity) * JUMP_VELOCITY,
			currentMovementDirection if currentMovementDirection else -global_transform.basis.z.normalized()
		)
		$froggy_v3/AnimationPlayer.play("jump")

func jump(jumpSpeed: float, direction: Vector3) -> void:
	velocity.x = direction.x * jumpForwardVelocity
	velocity.z = direction.z * jumpForwardVelocity
	velocity.y = jumpSpeed
	currentJumpVelocityPercentage = 0
	isChargingJump = false

func handleGravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * gravityMultiplier
