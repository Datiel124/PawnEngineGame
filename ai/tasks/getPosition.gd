@tool
extends BTAction
var moveToMarker : Marker3D
var navAgent : NavigationAgent3D
var navPointGrabber : Area3D

func _generate_name():
	return "getPosition"

func _tick(delta : float):
	if !blackboard.get_var("navAgent") == null:
		moveToMarker = blackboard.get_var("moveToObject")
		moveToMarker.global_position = getNavPoints(true).global_position
		setTargetLocation()
		return SUCCESS

func setTargetLocation():
		if blackboard.get_var("navAgent") != null:
			navAgent = blackboard.get_var("navAgent")
			navAgent.set_target_position(moveToMarker.global_position)
			#Console.add_console_message("updating ai location on " + get_owner().pawnOwner.name)
			navAgent.target_desired_distance = randf_range(0.5,3)

func getNavPoints(getRandomPoint:bool=false):
	if getRandomPoint == false:
		for navPoints in navPointGrabber.get_overlapping_bodies():
			if navPoints is Marker3D:
				return navPoints
	else:
		var navPointArray
		if globalGameManager.world:
			if globalGameManager.world.worldWaypoints:
				navPointArray = globalGameManager.world.worldWaypoints.get_children()
		if navPointArray:
			for navPoint in navPointArray:
				var randomPoint = navPointArray.pick_random()
				return randomPoint
