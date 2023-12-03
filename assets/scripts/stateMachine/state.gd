extends Node
class_name State
signal transitionState
@export_category("State")
var componentOwner

func enterState():
	componentOwner = get_parent().componentOwner
	pass

func exitState():
	pass

func updateState(delta):
	pass

func physicsUpdateState(delta):
	pass
