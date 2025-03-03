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
		
		if(!has_dashed_before):
			game_state_manager.hide_tutorial_prompt()
			has_dashed_before = true
		
		AudioManager.play_sfx("res://Audio/SFX/Rolypoly/swish.wav")

func jumpButtonReleased() -> void:
	isDashing = false;
	timeDashed = 0

func entered_water():
	super()
	resetAbilities()

############################################### Tutorial prompts about this creature ###############################################
var has_been_controlled_before = false # Used to show a prompt when the player enteres this creature's area for the first time
var has_dashed_before = false # Used to show a prompt about how to dash
func _on_switch_area_body_entered(body):
	super(body)
	
	if(body == self):
		return
	
	if(has_been_controlled_before):
		return
	
	if(body as GenericCharacterController):
		var key = OS.get_keycode_string((InputMap.action_get_events("interact")[0] as InputEventKey).unicode)
		if(key.length() == 0):
			key = "null"
		key[0] = key[0].to_upper()
		game_state_manager.show_tutorial_prompt("A Rolypoly! Press [" + key + "] to possess" )

# Called when a character exits this character's switch area
func _on_switch_area_body_exited(body):
	super(body)
	
	if(body == self):
		return
	
	if(has_been_controlled_before):
		return
	
	if(body as GenericCharacterController):
		game_state_manager.hide_tutorial_prompt()
		
func switched_to_this_character():
	if(has_been_controlled_before):
		return
	
	has_been_controlled_before = true
	game_state_manager.hide_tutorial_prompt()
	
	await(get_tree().create_timer(1.5).timeout)

	# The player may already have dashed during the 1.5s wait above
	if(has_dashed_before):
		return
	
	var key = OS.get_keycode_string((InputMap.action_get_events("move_jump")[0] as InputEventKey).unicode)
	if(key.length() == 0):
		key = "null"
	key[0] = key[0].to_upper()
	
	game_state_manager.show_tutorial_prompt("I've seen these go super fast! Hold [" + key + "] to roll")
