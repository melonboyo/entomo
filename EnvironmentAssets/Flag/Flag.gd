class_name Flag extends Node3D

@export var next_flag: Flag # The next flag to show once this one is triggered, if null this is considered to be the last flag
@export var zoom_size: int # How far out the camera should zoom when showing this flag
@export var focus_move_speed: float = 3 # How fast the camera should move when showing this flag
@export var zoom_out_duration: float = 2 # How long it should take for the camera to zoom out when showing this flag
@export var focus_duration: float = 3 # How long the camera should focus on this flag
@export var game_state_manager: GameStateManager
@export var flag_mesh: MeshInstance3D

var has_been_triggered = false 

# This signal is called when another body enters this flag's trigger area
func _on_switch_area_body_entered(body: Node3D) -> void:
	if(has_been_triggered):
		return
	
	var g = body as GenericCharacterController
	
	if(g == null):
		return
		
	# Change flg color to green
	var unique_material = StandardMaterial3D.new()
	unique_material.albedo_color = Color(0, 1, 0)  # Set to green, for example
	flag_mesh.material_override = unique_material
	has_been_triggered = true
		
	AudioManager.play_sfx("res://Audio/SFX/Other/Flag.wav")
	
	# The ending is reached if this is the last flag, i.e. next_flag is null
	if(next_flag == null):
		game_state_manager.ending_reached()
		print("No next flag assigned, this is expected behaviour for the last flag.");
		return
	
	# Show the next flag in the game state manager
	game_state_manager.show_flag(next_flag)
