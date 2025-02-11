extends CharacterBody3D

class_name Movable

@export var MOVESPEED = 120.0

func move(direction, duration):
	velocity = direction.normalized() * MOVESPEED * duration * duration
	await get_tree().create_timer(0.3).timeout
	velocity = Vector3()
	print(velocity)
	

# Update the physics body each physics tick
func _physics_process(delta: float) -> void:
	# move_and_slide is called each physics tick
	move_and_slide()
