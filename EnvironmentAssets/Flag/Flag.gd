class_name Flag extends Node3D

@export var next_flag: Flag # The next flag to show once this one is triggered, if null this is considered to be the last flag
@export var zoom_size: int # How far out the camera should zoom when showing this flag
@export var focus_move_speed: float = 3 # How fast the camera should move when showing this flag
@export var zoom_out_duration: float = 2 # How long it should take for the camera to zoom out when showing this flag
@export var focus_duration: float = 3 # How long the camera should focus on this flag
@export var game_state_manager: GameStateManager
@export var fail_flag: Node3D
@export var win_flag: Node3D
@export var flags_pivot: Node3D
@export var wind_curve: Curve

var has_been_triggered = false 
var lowered_flag_position : Vector3
var raised_flag_position : Vector3

func _process(delta: float) -> void:
	flags_pivot.rotation_degrees.y = wind_curve.sample((((Time.get_ticks_msec()) % 10000) * 0.1 * 0.001)) * 20

func _ready() -> void:
	lowered_flag_position = win_flag.position
	raised_flag_position = fail_flag.position

# This signal is called when another body enters this flag's trigger area
func _on_switch_area_body_entered(body: Node3D) -> void:
	if(has_been_triggered):
		return
	
	var g = body as GenericCharacterController
	
	if(g == null):
		return
		
	has_been_triggered = true
	
	# Animate flags
	var tween1 = create_tween()
	tween1.tween_property(fail_flag, "position", lowered_flag_position, 1)
	var tween2 = create_tween()
	tween2.tween_property(win_flag, "position", raised_flag_position, 1)
		
	AudioManager.play_sfx("res://Audio/SFX/Other/Flag.wav")
	
	# The ending is reached if this is the last flag, i.e. next_flag is null
	if(next_flag == null):
		game_state_manager.ending_reached()
		print("No next flag assigned, this is expected behaviour for the last flag.");
		return
	
	# Show the next flag in the game state manager
	game_state_manager.show_flag(next_flag)
