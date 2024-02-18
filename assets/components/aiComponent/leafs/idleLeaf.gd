extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	get_owner().pawnOwner.direction = Vector3.ZERO
	await get_tree().create_timer(1).timeout
	return SUCCESS

