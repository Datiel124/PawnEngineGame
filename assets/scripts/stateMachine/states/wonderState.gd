extends State
class_name WonderState
@export_category("Wonder State")
@export var aiMoveTime = true
@export var wonderTimer : Timer
##Pathfinding
@export var currLocation:Vector3
@export var newVelocity:Vector3
var safeVel

func enterState():
	randomize()
	await get_tree().process_frame
	startAI()

func exitState():
	aiMoveTime = false
	wonderTimer.stop()
	get_parent().componentOwner.navAgent.set_velocity(Vector3.ZERO)
	get_parent().componentOwner.pawnOwner.direction = Vector3.ZERO

func updateState(delta):
		if !get_parent().componentOwner.pawnOwner == null:
			if !get_parent().componentOwner.pawnOwner.healthComponent.isDead:
					if aiMoveTime:
						if get_parent().componentOwner.navAgent.is_target_reachable():
							var nextLocation = get_parent().componentOwner.navAgent.get_next_path_position()
							currLocation = get_parent().componentOwner.pawnOwner.global_position
							newVelocity = (nextLocation - currLocation).normalized() * get_parent().componentOwner.pawnOwner.velocityComponent.vMaxSpeed
							get_parent().componentOwner.navAgent.set_velocity(newVelocity)
						else:
							aiMoveTime = false
							updateTargetLocation(getNavPoints(true).global_position)

			if get_parent().componentOwner.aiMindState == 1:
				if get_parent().componentOwner.pawnHasTarget:
							if get_parent().componentOwner.overlappingObject.currentItem:
								transitionState.emit(self,"attackstate")

			if get_parent().componentOwner.aiMindState == 2:
				if get_parent().componentOwner.pawnHasTarget:
					transitionState.emit(self,"attackstate")

func getNavPoints(getRandomPoint:bool=false):
	if getRandomPoint == false:
		for navPoints in get_parent().componentOwner.navPointGrabber.get_overlapping_bodies():
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

func _on_nav_agent_target_reached():
	#Console.add_console_message("stopping ai on " + get_parent().componentOwner.pawnOwner.name)
	get_parent().componentOwner.pawnOwner.direction = Vector3.ZERO
	aiMoveTime = false
	wonderTimer.start()


func _on_nav_agent_velocity_computed(safe_velocity):
	safeVel = safe_velocity
	if aiMoveTime:
		if get_parent().componentOwner.pawnOwner:
			get_parent().componentOwner.pawnOwner.direction = get_parent().componentOwner.pawnOwner.direction.move_toward(safe_velocity, 0.25)


func updateTargetLocation(targetPosition:Vector3):
	#Console.add_console_message("updating ai location on " + get_parent().componentOwner.pawnOwner.name)
	get_parent().componentOwner.moveTo.global_position = targetPosition
	get_parent().componentOwner.navAgent.set_target_position(get_parent().componentOwner.moveTo.global_position)
	get_parent().componentOwner.navAgent.target_desired_distance = randf_range(0.5,3)
	aiMoveTime = true

func _on_ai_timer_timeout():
	updateTargetLocation(getNavPoints(true).global_position)
	wonderTimer.wait_time = randf_range(0.4,5)
	wonderTimer.stop()
	#Console.add_console_message("timer stopped/starting ai on " + get_parent().componentOwner.pawnOwner.name)

func startAI():
	updateTargetLocation(getNavPoints(true).global_position)
