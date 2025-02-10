extends GenericCharacterController

var isDashing = false
var isFlying = false

@export var ROLLSPEED = 10.0
@export var RAMPBOOST = 10.0
var timeDashed = 0;

func detectCollision(collided: Node):
	if isDashing:
		if (collided is Ramp):
			velocity.y = RAMPBOOST * timeDashed
			isFlying = true
		elif (collided is Movable):
			collided.move(directionFacing * ROLLSPEED, timeDashed)
			timeDashed = 0
		else:
			timeDashed = 0
	
	isDashing = false

func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	if isDashing :
		velocity.x = directionFacing.x * ROLLSPEED
		velocity.z = directionFacing.z * ROLLSPEED
		timeDashed += delta;
	elif isFlying:
		timeDashed -= delta;
		if timeDashed > 0:
			velocity.x = directionFacing.x * ROLLSPEED
			velocity.z = directionFacing.z * ROLLSPEED
		else:
			velocity.x = 0
			velocity.z = 0
			isFlying = false
			timeDashed = 0
	else :
		super(input_dir, camera_basis, delta)

func handleSpecialAbility() -> void:
	isDashing = true
