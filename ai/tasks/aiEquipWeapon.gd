@tool
extends BTAction

func _generate_name():
	return "Equip Random Weapon"

func _tick(delta:float):
	if blackboard.get_var("pawnOwner"):
		if blackboard.get_var("pawnOwner").currentItemIndex == 0:
			if blackboard.get_var("pawnOwner").itemInventory.size()>0:
				blackboard.get_var("pawnOwner").currentItemIndex = randi_range(1,blackboard.get_var("pawnOwner").itemInventory.size()-1)
				return SUCCESS
			else:
				return FAILURE
		else:
			return SUCCESS
