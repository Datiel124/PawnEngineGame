@tool
extends BTAction
var moveToMarker : Marker3D
var navAgent : NavigationAgent3D
var navPointGrabber : Area3D

func _generate_name():
	return "getPositionToDetectedPawn"

func _tick(delta : float):
	if !blackboard.get_var("navAgent") == null:
		if blackboard.get_var("moveToObject") != null:
			moveToMarker = blackboard.get_var("moveToObject")
			moveToMarker.global_position = getNavPoint()
			setTargetLocation()
			return SUCCESS
		else:
			return FAILURE

func setTargetLocation():
		if blackboard.get_var("navAgent") != null:
			navAgent = blackboard.get_var("navAgent")
			navAgent.set_target_position(moveToMarker.global_position)
			#Console.add_console_message("updating ai location on " + get_owner().pawnOwner.name)
			navAgent.target_desired_distance = randf_range(0.5,3)

func getNavPoint():
	if blackboard.get_var("hasTarget"):
		if blackboard.get_var("pawnTarget") != null:
			return blackboard.get_var("pawnTarget").global_position
