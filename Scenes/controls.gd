extends TabBar

@onready var input_button_scene = preload("res://Scenes/Menus/OptionsMenu/input_button.tscn")
@onready var action_list = $Inputs
@onready var save_button = $"../../SaveReturn"

var is_remapping = false
var action_to_remap = null
var remapping_button = null
var pending_keybindings = {}

var input_actions = {
	"move_forward": "Move forward",
	"move_left": "Move left",
	"move_backward": "Move backward",
	"move_right" : "Move right",
	"interact" : "Interact",
	"special_ability" : "Special",
	"move_jump" : "Jump",
}


# Called when the node enters the scene tree for the first time.
func _ready():
	_load_keybindings_from_settings()
	_create_action_list()
	#save_button.pressed.connect(_on_save_return_pressed)

func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_keybinding()
	#checks for null values (not the issue)
	if keybindings == null or not keybindings is Dictionary:
		print("Error: keybindings is null or not a dictionary")
		return
	
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])


func _create_action_list():
	
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		if action in input_actions:
			action_label.text = input_actions[action]
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		action_list.add_child(button)
		
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind"
		

func _input(event):
	if is_remapping:
		if (event is InputEventKey):
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			accept_event()
			#ensures correct storage of the pending changes (not the issue)
			if action_to_remap != null and action_to_remap in input_actions:
				pending_keybindings[action_to_remap] = event
				_update_action_list(remapping_button, event)
			
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null

func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed():
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigFileHandler.save_keybinding(action, events[0])

	_create_action_list()

func save_keybinds():
	for action in pending_keybindings.keys():
		ConfigFileHandler.save_keybinding(action, pending_keybindings[action])
	pending_keybindings.clear()
	print("Keybindings saved!")


func clear_keybinds():
	pending_keybindings.clear()
