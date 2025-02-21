class_name Flag extends Node3D

@export var next_flag: Flag
@export var zoom_size: int
@export var game_state_manager: GameStateManager
@export var flag_mesh: MeshInstance3D

var has_been_triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_switch_area_body_entered(body: Node3D) -> void:
	if(has_been_triggered):
		return
	
	var g = body as GenericCharacterController
	
	if(g == null):
		return
	
	if(next_flag == null):
		print("Error, no next flag assigned!");
		return
	
	var unique_material = StandardMaterial3D.new()
	unique_material.albedo_color = Color(0, 1, 0)  # Set to green, for example
	flag_mesh.material_override = unique_material
	
	has_been_triggered = true
	game_state_manager.show_flag(next_flag)
