extends PathFollow3D

class_name Dragonfly

@export var speed : float
@export var color : ColouredBug
@export var frogPoint : float
@export var distanceToFrog : float
@export var frog : Frog
@export var gameState : GameStateManager


var lastProgressCheck = 0
var rng = RandomNumberGenerator.new()
var checked := false

func _ready():
	color.MESH.set_surface_override_material(0, color.MESH.get_surface_override_material(0).duplicate())
	setColour()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress += speed * delta
	
	if (progress < lastProgressCheck):
		color.MESH.visible = true
		checked = false
	elif (!checked and progress > frogPoint):
		checkIfEaten()
	
	lastProgressCheck = progress
		

func setColour():
	color.MESH.visible = true
	checked = false
	if(rng.randi_range(1,2) == 2):
		color.changeColor()
	else:
		color.resetColor()

func checkIfEaten():
	checked = true
	if color.is_coloured and gameState.maxStageReached < 4:
		frog.quickTongueAnimation(distanceToFrog, 0.1)
		await get_tree().create_timer(0.1).timeout
		color.MESH.visible = false
	
