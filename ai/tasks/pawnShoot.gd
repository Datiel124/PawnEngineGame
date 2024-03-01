@tool
extends BTAction

func _generate_name():
	return "Pawn Shoot Weapon"

func _tick(delta:float):
	if blackboard.get_var("pawnOwner"):
		if !blackboard.get_var("pawnOwner").currentItemIndex == 0:
			if !blackboard.get_var("pawnOwner").currentItem.isAiming:
				blackboard.get_var("pawnOwner").currentItem.isAiming = true
			blackboard.get_var("pawnOwner").currentItem.fire()
			return SUCCESS
		else:
			return FAILURE
