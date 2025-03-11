# This script is for controlling the Parasite
extends GenericCharacterController
class_name Parasite

@export var parasite_model: Node3D

# Overrides the jumpButtonPressed method of GenericCharacterController
func jumpButtonPressed() -> void:
	AudioManager.set_music_volume(-0.1)
	return
	
# This goes from 0 to 1, and is used to smoothly go between the squish animation and being still
var animation_amount = 0

# Overrides the handleMove method of GenericCharacterController
func handleMove(input_dir: Vector2, camera_basis: Basis, delta: float) -> void:
	# Call handleMove of the genric controller with super()
	super(input_dir, camera_basis, delta)
	
	if(input_dir == Vector2.ZERO):
		animation_amount -= delta * 5
	else:
		animation_amount += delta * 5
	
	animation_amount = max(min(animation_amount, 1), 0);
	var anim_bounces_per_second = 10
	var squish_amount = 0.25
	var animation_value = Time.get_ticks_msec() * 0.001 * anim_bounces_per_second
	parasite_model.scale.x = 1 + sin(animation_value) * squish_amount * animation_amount
	parasite_model.scale.z = 1 + cos(animation_value) * squish_amount * animation_amount
	
	# Do movement specific to the parasite
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if(input_dir != Vector2.ZERO):
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 10)
