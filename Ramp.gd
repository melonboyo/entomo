extends StaticBody3D

class_name Ramp

@export var RAMPBOOST = 10.0

func OnObjectUseRamp(collided : Node):
	if collided is Pillbug:
		collided.hitRamp(RAMPBOOST)
