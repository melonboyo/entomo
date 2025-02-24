class_name Flag extends Node3D

@export var next_flag: Flag
@export var zoom_size: int
@export var focus_move_speed: float = 3
@export var game_state_manager: GameStateManager
@export var flag_mesh: MeshInstance3D

var has_been_triggered = false

func _on_switch_area_body_entered(body: Node3D) -> void:
	if(has_been_triggered):
		return
	
	var g = body as GenericCharacterController
	
	if(g == null):
		return
		
	var unique_material = StandardMaterial3D.new()
	unique_material.albedo_color = Color(0, 1, 0)  # Set to green, for example
	flag_mesh.material_override = unique_material
	has_been_triggered = true
	
	if(next_flag == null):
		game_state_manager.final_flag_reached()
		print("No next flag assigned, this is expected behaviour for the last flag.");
		return
	
	game_state_manager.show_flag(next_flag)
