extends CharacterBody3D

class_name Movable

func move(direction, duration):
	velocity = direction
	print(velocity)
	await get_tree().create_timer(duration).timeout
	velocity = Vector3()
	print(velocity)
	

# Update the physics body each physics tick
func _physics_process(delta: float) -> void:
	# move_and_slide is called each physics tick
	move_and_slide()
