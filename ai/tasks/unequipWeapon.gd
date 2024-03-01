@tool
extends BTAction

func _generate_name():
	return "pawnUnequipWeapon"

func _tick(delta:float):
	if blackboard.get_var("pawnOwner"):
		if blackboard.get_var("pawnOwner").currentItemIndex > 0:
			blackboard.get_var("pawnOwner").currentItem.isAiming = false
			blackboard.get_var("pawnOwner").currentItemIndex = 0
		blackboard.get_var("pawnOwner").freeAim = false
		blackboard.get_var("pawnOwner").meshLookAt = false
		return SUCCESS
