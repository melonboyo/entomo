extends GenericCharacterController
class_name Beetle

@export var walk_acceleration := 10.0
@export var roll_acceleration := 5.0
@export var air_acceleration := 3.0
var is_rolling := false
var move_velocity := Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Call handleMove of the generic controller
	super(delta)

#func handleJump() -> void:
	#pass

func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	var acceleration = walk_acceleration if not is_rolling else roll_acceleration
	move_velocity = velocity * Vector3(1,0,1)
	#camera_basis.y = Vector3.UP
	#camera_basis = camera_basis.orthonormalized()
	var x = camera_basis.x.project(get_floor_normal())
	var z = camera_basis.z.project(get_floor_normal())
	
	# Get the input direction and handle the movement/deceleration.
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if is_on_floor():
		#direction = direction.project(get_floor_normal())
	#var direction2 := Vector2(direction.x, direction.z)
	var desired_velocity = Vector3.ZERO
	if direction:
		desired_velocity = direction * SPEED
	if not is_on_floor():
		acceleration = air_acceleration
	
	move_velocity = move_velocity.lerp(desired_velocity, delta * acceleration)
	velocity = Vector3(move_velocity.x, velocity.y, move_velocity.z)
