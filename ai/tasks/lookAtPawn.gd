@tool
extends BTAction

func _generate_name():
	return "lookAtPawn"

func _tick(delta : float):
	if blackboard.get_var("pawnOwner"):
		var lookAt
		if blackboard.get_var("hasTarget"):
			if blackboard.get_var("pawnOwner").currentItem:
				blackboard.get_var("pawnOwner").currentItem.isAiming = true
			blackboard.get_var("pawnOwner").meshLookAt = true
		else:
			if blackboard.get_var("pawnOwner").currentItem:
				blackboard.get_var("pawnOwner").currentItem.isAiming = false
			blackboard.get_var("pawnOwner").meshLookAt = false

		lookAt = blackboard.get_var("aimCast").global_transform.basis.get_euler().y
		blackboard.get_var("pawnOwner").meshRotation = lookAt
		return SUCCESS
	else:
		return FAILURE
