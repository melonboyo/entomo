extends TabBar

var is_customizable = false
var action_string
enum ACTIONS {move_left, move_right, move_down, move_up, move_jump, special_ability, interact, pause}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_action_keys():
	for input_action in ACTIONS:
		var action_button = get_node("Inputs/" + input_action + "/Button")
		action_button.set_pressed(false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
