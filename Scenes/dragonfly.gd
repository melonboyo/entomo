extends PathFollow3D

class_name Dragonfly

@export var speed : float
@export var color : ColouredBug
@export var frogPoint : float
@export var rolypoly_material_switcher : RolypolyMaterialSwitcher

var lastProgressCheck = 0
var rng = RandomNumberGenerator.new()
var checked := false

func _ready():
	setColour()
	$dragonfly/AnimationPlayer.play("fly")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress += speed * delta
	
	if (progress < lastProgressCheck):
		setColour()
	elif (!checked and progress > frogPoint):
		checkIfEaten()
	
	lastProgressCheck = progress
		

func setColour():
	checked = false
	rolypoly_material_switcher.show()
	if(rng.randi_range(1,3) == 3):
		color.changeColor()
		rolypoly_material_switcher.set_painted()
	else:
		color.resetColor()
		rolypoly_material_switcher.set_unpainted()

func checkIfEaten():
	checked = true
	if color.is_coloured == true :
		rolypoly_material_switcher.hide()
