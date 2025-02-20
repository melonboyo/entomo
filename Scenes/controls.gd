extends TabBar


@export var action: String
var waiting_for_input: String = "" #to keep track of whats being reassigned
const SAVE_PATH = "user://keybindings.cfg"

enum ACTIONS {move_left, move_right, move_backward, move_forward, move_jump, special_ability, interact, pause}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#for updating the button text to show the current keybinding
func update_action_keys():
	for action_name in ACTIONS.keys():
		var action_button = get_node("Inputs/" + action_name + "/Button")
		var events = InputMap.action_get_events(action_name)
		if events.size() < 0:
			action_button.text = events[0].as_text()
		else:
			action_button.text = "Unbound"
func _input(event):
	if waiting_for_input != "" and event is InputEventKey and event.pressed:
		# Remove existing bindings
		InputMap.action_erase_events(waiting_for_input)
		# Assign new key
		InputMap.action_add_event(waiting_for_input, event)
		# Save to file
		save_keybindings()
		# Refresh UI
		update_action_keys()
		# Reset state
		waiting_for_input = ""
		$Label.text = "Key bound successfully!"  # Update UI feedback

func save_keybindings():
	var config = ConfigFile.new()
	for action_name in ACTIONS.keys():
		var events = InputMap.action_get_events(action_name)
		if events.size() > 0:
			config.set_value("keybindings", action_name, events[0].as_text())
	config.save(SAVE_PATH)

func load_keybindings():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for action_name in ACTIONS.keys():
			var event_str = config.get_value("keybindings", action_name, "")
			var event = InputEventKey.new()
			event.from_text(event_str)
			if event is InputEvent:
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
