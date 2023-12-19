extends State
class_name AttackState
@export_category("Attack AI")
@export var hasWeaponToEquip : bool
@export var sightCast : RayCast3D
@export var sightcastEnd : Marker3D
@export var navAgent : NavigationAgent3D
var safeVel
var target
var pawnControlling
@export var currLocation:Vector3
@export var newVelocity:Vector3
var aiMoveTime : bool = false
# Called when the node enters the scene tree for the first time.

func enterState():
	$attackTimer.start()
	pawnControlling = get_parent().componentOwner.pawnOwner
	await get_tree().process_frame
	await get_tree().process_frame
	for hboxes in get_parent().componentOwner.pawnOwner.boneAttatchementHolder.get_children():
		if hboxes is BoneAttachment3D:
			for boxes in hboxes.get_children():
				if boxes is Area3D:
					sightCast.add_exception(boxes)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateState(delta):
	if get_parent().componentOwner.pawnOwner:
		if get_parent().componentOwner.pawnOwner.isPawnDead:
			get_parent().queue_free()

		if !get_parent().componentOwner.pawnOwner.isPawnDead:
			if aiMoveTime:
				if get_parent().componentOwner.navAgent.is_target_reachable():
					var nextLocation = get_parent().componentOwner.navAgent.get_next_path_position()
					currLocation = get_parent().componentOwner.pawnOwner.position
					newVelocity = (nextLocation - currLocation).normalized() * get_parent().componentOwner.pawnOwner.velocityComponent.vMaxSpeed
					get_parent().componentOwner.navAgent.set_velocity(newVelocity)
				else:
					aiMoveTime = false

			sightCast.add_exception(get_parent().componentOwner.pawnOwner)
			#Set Positioning for the raycast
			moveToEnemy()
			sightCast.position = get_parent().componentOwner.pawnOwner.neckBone.position
			#sightCast.rotation = get_parent().componentOwner.pawnOwner.pawnMesh.rotation

			#Set if the pawn has a weapon that can be equipped or not
			if get_parent().componentOwner.pawnOwner.itemInventory.size()-1 >= 1:
				hasWeaponToEquip = true
			else:
				hasWeaponToEquip = false

			#If the pawn sees someone
			if componentOwner.componentOwner.pawnHasTarget:
				var colliding = sightCast.get_collider()
				if componentOwner.componentOwner.overlappingObject != null:
					if !componentOwner.componentOwner.overlappingObject.isPawnDead:
						target = componentOwner.componentOwner.overlappingObject
						sightCast.rotation.y = lerpf(sightCast.rotation.y, get_parent().componentOwner.coneOfVision.rotation.y, delta*20)
				else:
					target = null
				#pawnToAttack = colliding
				if target != null:
					if componentOwner.componentOwner.overlappingObject.is_in_group("Pawn"):
						#get_parent().componentOwner.pawnOwner.turnAmount = lerpf(get_parent().componentOwner.pawnOwner.turnAmount,-get_parent().componentOwner.coneOfVision.rotation.x - randf_range(0.22,0.24), delta*25)

						if hasWeaponToEquip:
							if get_parent().componentOwner.pawnOwner.currentItem == null:
								if get_parent().componentOwner.aiMindState == 2:
									get_parent().componentOwner.pawnOwner.currentItemIndex = randi_range(1,get_parent().componentOwner.pawnOwner.itemInventory.size()-1)
									get_parent().componentOwner.pawnOwner.currentItem.weaponCast = sightCast

								if get_parent().componentOwner.aiMindState == 1:
									if !componentOwner.componentOwner.overlappingObject.currentItem == null:
										get_parent().componentOwner.pawnOwner.currentItemIndex = randi_range(1,get_parent().componentOwner.pawnOwner.itemInventory.size()-1)
										get_parent().componentOwner.pawnOwner.currentItem.weaponCast = sightCast
										addToHatedPawns(componentOwner.componentOwner.overlappingObject)

						if get_parent().componentOwner.pawnOwner.currentItem:
							get_parent().componentOwner.pawnOwner.meshLookAt = true
							get_parent().componentOwner.pawnOwner.currentItem.weaponCastEnd = sightcastEnd
							get_parent().componentOwner.pawnOwner.currentItem.weaponCast = sightCast
							get_parent().componentOwner.pawnOwner.meshRotation = lerpf(get_parent().componentOwner.pawnOwner.meshRotation, get_parent().componentOwner.coneOfVision.global_transform.basis.get_euler().y, 24*delta)
						#Firing Logic

							if componentOwner.componentOwner.overlappingObject != null:
								target = componentOwner.componentOwner.overlappingObject
								if target != null:
									if !target.isPawnDead:
										if get_parent().componentOwner.aiMindState == 2:
											await get_tree().create_timer(randf_range(0.2,0.4)).timeout
											if get_parent().componentOwner.pawnOwner.currentItem:
												get_parent().componentOwner.pawnOwner.currentItem.isAiming = true
												if sightCast.is_colliding():
													get_parent().componentOwner.pawnOwner.currentItem.fire()

										if get_parent().componentOwner.aiMindState == 1:
											if target.currentItem and target.currentItem.isAiming or target.currentItem and target.currentItem.isFiring or get_parent().componentOwner.hatedPawns.has(componentOwner.componentOwner.overlappingObject):
												await get_tree().create_timer(randf_range(0.2,0.4)).timeout
												if get_parent().componentOwner.pawnOwner.currentItem:
													if sightCast.is_colliding():
														get_parent().componentOwner.pawnOwner.currentItem.fire()

			else:
				if get_parent().componentOwner.aiType == 0:
					transitionState.emit(self,"wonderState")
				await get_tree().create_timer(randf_range(0.5,1)).timeout
				if get_parent().componentOwner.pawnOwner.currentItem:
					get_parent().componentOwner.pawnOwner.currentItem.isAiming = false
				get_parent().componentOwner.pawnOwner.meshLookAt = false

func _on_nav_agent_target_reached():
	if componentOwner.componentOwner.pawnHasTarget:
		get_parent().componentOwner.navAgent.target_desired_distance = randf_range(2,6)


func _on_nav_agent_velocity_computed(safe_velocity):
	if target:
		get_parent().componentOwner.pawnOwner.direction = get_parent().componentOwner.pawnOwner.direction.move_toward(safe_velocity, 0.25)

func exitState():
	$attackTimer.stop()
	aiMoveTime = false
	target = null

func moveToEnemy():
	if target:
		aiMoveTime = true
		get_parent().componentOwner.moveTo.position = target.position
		get_parent().componentOwner.navAgent.set_target_position(get_parent().componentOwner.moveTo.position)
		#get_parent().componentOwner.navAgent.target_desired_distance = randf_range(0.02,0.06)


func _on_attack_timer_timeout():
	$attackTimer.start()
	if componentOwner.componentOwner.pawnHasTarget:
		get_parent().componentOwner.navAgent.target_desired_distance = randf_range(2,6)

func addToHatedPawns(overlappingPawn):
	for pawns in get_parent().componentOwner.hatedPawns:
		if overlappingPawn != pawns:
			get_parent().componentOwner.hatedPawns.append(overlappingPawn)
