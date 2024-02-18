@tool
extends BTAction
##Pathfinding
@export var currLocation:Vector3
@export var newVelocity:Vector3
var reachedTarget : bool = false
var safeVel
var owner

func _tick(delta:float):
	if !blackboard.get_var("pawnOwner") == null:
		if !blackboard.get_var("pawnOwner").healthComponent.isDead:
			if !blackboard.get_var("hasTarget",true):
				if blackboard.get_var("navAgent"):
					#Signal connection..
					if !blackboard.get_var("navAgent").target_reached.is_connected(_on_nav_agent_target_reached):
						blackboard.get_var("navAgent").target_reached.connect(_on_nav_agent_target_reached)

					if !blackboard.get_var("navAgent").path_changed.is_connected(_on_nav_agent_path_changed):
						blackboard.get_var("navAgent").path_changed.connect(_on_nav_agent_path_changed)

					if !blackboard.get_var("navAgent").velocity_computed.is_connected(_on_nav_agent_velocity_computed):
						blackboard.get_var("navAgent").velocity_computed.connect(_on_nav_agent_velocity_computed)

					if blackboard.get_var("navAgent").is_target_reachable():
						var nextLocation = blackboard.get_var("navAgent").get_next_path_position()
						currLocation = blackboard.get_var("pawnOwner").global_position
						newVelocity = (nextLocation - currLocation).normalized() * blackboard.get_var("pawnOwner").velocityComponent.vMaxSpeed
						blackboard.get_var("navAgent").set_velocity(newVelocity)
					else:
						return FAILURE
			else:
				blackboard.get_var("navAgent").set_velocity(Vector3.ZERO)
				blackboard.get_var("pawnOwner").direction = Vector3.ZERO
				return SUCCESS

	if !reachedTarget:
		return RUNNING
	else:
		return SUCCESS

func _on_nav_agent_target_reached():
	if blackboard.get_var("navAgent"):
		#Console.add_console_message("stopping ai on " + owner.pawnOwner.name)
		blackboard.get_var("pawnOwner").direction = Vector3.ZERO
		reachedTarget = true
		#Console.add_console_message("%s, reachedtarget = %s"%[owner.pawnOwner.name,reachedTarget])


func _on_nav_agent_velocity_computed(safe_velocity):
	safeVel = safe_velocity
	if blackboard.get_var("navAgent"):
		if blackboard.get_var("pawnOwner"):
			blackboard.get_var("pawnOwner").direction = blackboard.get_var("pawnOwner").direction.move_toward(safe_velocity, 0.25)

func _on_nav_agent_path_changed():
	reachedTarget = false
