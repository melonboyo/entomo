extends CharacterBody3D

class_name Movable

@export var MOVESPEED = 120.0

var isMoving = false


func move(direction, duration):
	velocity = direction.normalized() * MOVESPEED * duration * duration
	isMoving = true
	await get_tree().create_timer(0.3).timeout
	isMoving = false
	velocity = Vector3()
	
func _physics_process(delta: float) -> void:
	if isMoving:
		move_and_slide()
	else:
		move_and_collide(get_gravity() * delta * 3)
