@tool
extends BTAction

func _generate_name():
	return "Equip Random Weapon"

func _tick(delta:float):
	if blackboard.get_var("pawnOwner"):
		if blackboard.get_var("pawnOwner").currentItemIndex == 0:
			if blackboard.get_var("pawnOwner").itemInventory.size()-1>0:
				blackboard.get_var("pawnOwner").currentItemIndex = randi_range(1,blackboard.get_var("pawnOwner").itemInventory.size()-1)
				blackboard.get_var("pawnOwner").currentItem.weaponCast = blackboard.get_var("aimCast")
				blackboard.get_var("pawnOwner").currentItem.weaponCastEnd = blackboard.get_var("aimCastEnd")
				return SUCCESS
			else:
				return FAILURE
		else:
			return SUCCESS
