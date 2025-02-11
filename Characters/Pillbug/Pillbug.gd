extends GenericCharacterController

class_name Pillbug

var isDashing = false
var isFlying = false

@export var ROLLSPEED = 10.0
@export var MAXROLLSPEED = 10.0
@export var GRAVITYFORCE = 10.0

var timeDashed = 0;


func detectCollision(collided: Node):
	if isDashing:
		if (collided is Movable):
			collided.move(direction_facing * ROLLSPEED, timeDashed)
			timeDashed = 0
			isDashing = false
		elif (collided is Ramp):
			return
		else:
			timeDashed = 0
			

func hitRamp(boost):
	if isDashing:
		velocity.y += boost * timeDashed
		print (velocity.y)

func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	if isDashing :
		var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var rollBoost = min(ROLLSPEED * timeDashed, MAXROLLSPEED)
		
		velocity.x = direction_facing.x * rollBoost + direction.x * SPEED / 2
		velocity.z = direction_facing.z *  rollBoost + direction.z * SPEED / 2
		
		if is_on_floor():
			timeDashed += delta;
		else:
			timeDashed -= delta/2;
			timeDashed = max(0, timeDashed)
	else :
		super(input_dir, camera_basis, delta)
	
		
	
	
# The generic character uses gravity
func handleGravity(delta: float) -> void:
	if not is_on_floor() && not isFlying:
			velocity += get_gravity() * delta * GRAVITYFORCE

func jumpButtonPressed() -> void:
	if is_on_floor():
		isDashing = true

func jumpButtonReleased() -> void:
	isDashing = false;
	timeDashed = 0
