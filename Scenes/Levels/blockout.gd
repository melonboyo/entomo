extends Node3D


@onready var anim = $Anim


func _on_game_state_manager_ending() -> void:
	anim.play("seagull") # Replace with function body.
