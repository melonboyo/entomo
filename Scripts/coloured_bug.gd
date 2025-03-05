extends Node

class_name ColouredBug

var is_coloured = false

func _ready():
	resetColor()

func changeColor():
	is_coloured = true


func resetColor():
	is_coloured = false	
	
