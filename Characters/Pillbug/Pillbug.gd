extends GenericCharacterController

class_name Pillbug

var isDashing = false
var isFlying = false

@export var ROLLSPEED = 10.0
@export var MAXROLLSPEED = 10.0
@export var CUSTOMGRAVITY = 10.0
@export var normal_mesh: RolypolyMaterialSwitcher
@export var rolling_mesh: RolypolyMaterialSwitcher
@export var ball_pivot: Node3D
@onready var akState = $AkState
var intro_sfx

var timeDashed = 0;
var is_coloured = false

func _ready() -> void:
	super()
	rolling_mesh.hide()
	normal_mesh.show()

func detectCollision(collided: Node):	
	if isDashing:
		if (collided is Movable):
			collided.move(direction_facing * ROLLSPEED, timeDashed)
			timeDashed = 0
			isDashing = false
			rolling_mesh.hide()
			normal_mesh.show()
		elif (collided is Ramp):
			velocity.y = collided.RAMPBOOST * timeDashed
	
	if(collided is Paint):
		rolling_mesh.set_painted()
		normal_mesh.set_painted()
		is_coloured = true
	elif(collided is PillbugEatingRange and is_coloured):
		collided.Launch()

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
			
		ball_pivot.rotate_x(-min(timeDashed * 0.5, 0.5))
		
		rotation.y = lerp_angle(rotation.y, atan2(-direction_facing.x, -direction_facing.z), delta * rotationSpeed)
	else :
		super(input_dir, camera_basis, delta)
		if(input_dir != Vector2.ZERO):
			$MeshPivot/rolypoly/AnimationPlayer.play("walk")
		else:
			$MeshPivot/rolypoly/AnimationPlayer.stop()


# The generic character uses gravity
func handleGravity(delta: float) -> void:
	if not is_on_floor() && not isFlying:
		velocity += get_gravity() * delta * CUSTOMGRAVITY

func jumpButtonPressed() -> void:
	if is_on_floor():
		isDashing = true
		rolling_mesh.show()
		normal_mesh.hide()
		
		game_state_manager.hide_tutorial_prompt()
		
		intro_sfx = AudioManager.play_sfx("res://Audio/SFX/Rolypoly/swish_Intro_3.wav")

func jumpButtonReleased() -> void:
	isDashing = false;
	timeDashed = 0
	rolling_mesh.hide()
	normal_mesh.show()
	if intro_sfx != null:
		intro_sfx._on_finished()

	if(!has_dashed_before):
		game_state_manager.show_tutorial_prompt_with_sound("I need a long run-up to get enough momentum.", "Parasite/hmm.wav")
		has_dashed_before = true
	
	#intro_sfx = AudioManager.play_sfx("res://Audio/SFX/Rolypoly/swish.wav")

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
		var key = InputMap.action_get_events("interact")[0].as_text().trim_suffix(" (Physical)")
		if(key.length() == 0):
			key = "null"
		key[0] = key[0].to_upper()
		game_state_manager.show_tutorial_prompt_with_sound("A Rolypoly! Press [" + key + "] to possess", "Parasite/Haha.wav")
		akState.set_value()

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
	super()
	if(has_been_controlled_before):
		return
	
	has_been_controlled_before = true
	game_state_manager.hide_tutorial_prompt()
	
	await(get_tree().create_timer(1.5).timeout)

	# The player may already have dashed during the 1.5s wait above
	if(has_dashed_before):
		return
	
	var key = InputMap.action_get_events("move_jump")[0].as_text().trim_suffix(" (Physical)")
	if(key.length() == 0):
		key = "null"
	key[0] = key[0].to_upper()
	
	game_state_manager.show_tutorial_prompt("I've seen these go super fast! Hold [" + key + "] to roll")
