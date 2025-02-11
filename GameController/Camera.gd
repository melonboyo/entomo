extends Node3D


@export var camera: Camera3D = null
@export var game_state_machine: GameStateManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Simple camera follow for playtesting. TODO: implement proper camera follow as part of swapping between creatures
	#camera.size = game_state_machine.currentPossessedCreature.CAMERA_SIZE
	global_position = game_state_machine.currentPossessedCreature.global_position
	camera.position.z = game_state_machine.currentPossessedCreature.CAMERA_SIZE
