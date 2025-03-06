extends Node

class_name PillbugEatingRange

@export var FORCEPUSH : Vector3
@export var frog : Frog
@export var pillbug : Pillbug
@export var distanceToFrog : float


func Launch():
	pillbug.isDashing = false
	frog.quickTongueAnimation(distanceToFrog, 0.15)
	await get_tree().create_timer(0.15).timeout
	
	pillbug.isFlying = true
	pillbug.velocity = FORCEPUSH
	await get_tree().create_timer(0.25).timeout
	pillbug.isFlying = false
