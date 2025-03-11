@tool
extends Node3D

# Zoom levels dictionary
# First number corresponds to the size of the character,
# second number is the distance from the camera to the focus
@export var zooms := {
	1 : 10.0,
	2 : 15.0,
	3 : 23.0,
	4 : 40.0,
	5 : 100.0,
}

@export var camera: Camera3D = null
@export var game_state_manager: GameStateManager

@export_range(0.0, 10.0) var zoom_duration := 0.9
@export_range(0.0, 100.0) var focus_move_speed := 5.0
var current_focus_move_speed = focus_move_speed
@export_range(1, 10) var zoom_level := 1:
	set(value):
		var new_zoom_level = clampi(value, 1, zooms.size())
		zoom_level = new_zoom_level
		zoom()
@export var focus: Node3D

var zoom_tween: Tween
@export var zoom_mult := 1.3

func _ready():
	if Engine.is_editor_hint():
		return

func _physics_process(delta):
	if focus and global_position.distance_to(focus.global_position) > 0.001:
		global_position = global_position.lerp(focus.global_position, current_focus_move_speed * delta)
	
	if Engine.is_editor_hint():
		return
	
	# For testing, up and down keys to manually change zoom
	#if not zoom_tween or not zoom_tween.is_running():
	#	if Input.is_action_just_pressed("ui_down"):
	#		zoom_level += 1
	#	elif Input.is_action_just_pressed("ui_up"):
	#		zoom_level -= 1

# Creates a tween that animates between the previous zoom and the new zoom
func zoom():
	if zoom_tween:
		zoom_tween.kill()
	
	var target_z_pos = zooms[zoom_level] * zoom_mult
	var duration = sqrt(sqrt(sqrt(abs(camera.position.z - target_z_pos)))) * 1.5
	
	zoom_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_QUART).set_parallel()
	zoom_tween.tween_property(camera, "position:z", target_z_pos, duration)

# Changes zoom when this function receives a zoom changed signal
func _on_game_state_manager_zoom_changed(newFocus: Node3D, zoomSize: int, new_focus_move_speed: float = -1) -> void:
	zoom_level = zoomSize
	focus = newFocus
	if(new_focus_move_speed <= 0):
		current_focus_move_speed = focus_move_speed
	else:
		focus_move_speed = new_focus_move_speed
