extends Node

class_name Paint

func onEnterBucket(collided: Node):
	print("Hu")
	if collided is Pillbug:
		collided.COLOR.changeColor()
