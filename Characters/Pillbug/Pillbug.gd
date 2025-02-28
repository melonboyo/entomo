extends GenericCharacterController

class_name Pillbug

var isDashing = false
var isFlying = false

@export var ROLLSPEED = 10.0
@export var MAXROLLSPEED = 10.0
@export var CUSTOMGRAVITY = 10.0
@export var COLOR : ColouredBug

var timeDashed = 0;


func detectCollision(collided: Node):	
	if isDashing:
		if (collided is Movable):
			collided.move(direction_facing * ROLLSPEED, timeDashed)
			timeDashed = 0
			isDashing = false
		elif (collided is Ramp):
			velocity.y = collided.RAMPBOOST * timeDashed
	
	if(collided is Paint):
		COLOR.changeColor()
	elif(collided is PillbugEatingRange and COLOR.is_coloured):
		isFlying = true
		velocity = collided.FORCEPUSH
		await get_tree().create_timer(0.2).timeout
		isFlying = false

func resetAbilities():
	isDashing = false
	timeDashed = 0
	

func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	if isFlying:
		pass
	elif isDashing :		
		var rollBoost = min(ROLLSPEED * timeDashed ** 2, MAXROLLSPEED)
		
		velocity.x = direction_facing.x * rollBoost
		velocity.z = direction_facing.z *  rollBoost
		
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
			velocity += get_gravity() * delta * CUSTOMGRAVITY

func jumpButtonPressed() -> void:
	if is_on_floor():
		isDashing = true
		
		

func jumpButtonReleased() -> void:
	isDashing = false;
	timeDashed = 0
	AudioManager.play_sfx("res://Audio/SFX/Rolypoly/swish.wav")
