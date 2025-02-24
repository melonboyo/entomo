extends PathFollow3D

class_name Dragonfly

@export var speed : float
@export var color : ColouredBug
@export var frogPoint : float

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
		setColour()
	elif (!checked and progress > frogPoint):
		checkIfEaten()
	
	lastProgressCheck = progress
		

func setColour():
	color.MESH.visible = true
	checked = false
	if(rng.randi_range(1,3) == 3):
		color.changeColor()
	else:
		color.resetColor()

func checkIfEaten():
	if color.is_coloured:
		color.MESH.visible = false
	checked = true
