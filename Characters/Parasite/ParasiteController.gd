# This script is for controlling the Parasite
extends GenericCharacterController
class_name Parasite
	
# Overrides the jumpButtonPressed method of GenericCharacterController
func jumpButtonPressed() -> void:
	return

# Overrides the handleMove method of GenericCharacterController
func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	# Call handleMove of the genric controller with super()
	super(input_dir, camera_basis, delta)
	
	# Do movement specific to the parasite
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if(input_dir != Vector2.ZERO):
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 10)


func _on_ak_event_3d_music_play_started(data: Dictionary) -> void:
	print(data)
