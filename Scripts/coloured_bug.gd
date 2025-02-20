extends Node

class_name ColouredBug

@export var DEFAULT_COLOUR = Color.WHITE
@export var CHANGED_COLOUR = Color.REBECCA_PURPLE
@export var MESH : MeshInstance3D

var is_coloured = false

func changeColor():
	is_coloured = true
	
	var mat = MESH.get_surface_override_material(0)	
	mat.albedo_color = CHANGED_COLOUR
	MESH.set_surface_override_material(0, mat)


func resetColor():
	is_coloured = false	
	MESH.mesh.surface_get_material(0).albedo_color = DEFAULT_COLOUR
	
