extends State
class_name AttackState
@export_category("Attack AI")
@export var hasWeaponToEquip : bool
@export var sightCast : RayCast3D
@export var sightcastEnd : Marker3D
var pawnToAttack
var pawnControlling

# Called when the node enters the scene tree for the first time.

func enterState():
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
			sightCast.add_exception(get_parent().componentOwner.pawnOwner)
			#Set Positioning for the raycast
			sightCast.position = get_parent().componentOwner.pawnOwner.neckBone.position
			#sightCast.rotation = get_parent().componentOwner.pawnOwner.pawnMesh.rotation

			#Set if the pawn has a weapon that can be equipped or not
			if get_parent().componentOwner.pawnOwner.itemInventory.size()-1 >= 1:
				hasWeaponToEquip = true
			else:
				hasWeaponToEquip = false

			#If the pawn sees someone
			if componentOwner.componentOwner.pawnHasTarget:
				var target
				var colliding = sightCast.get_collider()
				if componentOwner.componentOwner.overlappingObject != null:
					if !componentOwner.componentOwner.overlappingObject.isPawnDead:
						target = componentOwner.componentOwner.overlappingObject
						sightCast.look_at(componentOwner.componentOwner.overlappingObjectPosition,Vector3.UP)
				else:
					target = null
				#pawnToAttack = colliding
				if target != null:
					if componentOwner.componentOwner.overlappingObject.is_in_group("Pawn"):
						get_parent().componentOwner.pawnOwner.turnAmount = lerpf(get_parent().componentOwner.pawnOwner.turnAmount,-get_parent().componentOwner.coneOfVision.rotation.x - randf_range(0.22,0.24), delta*25)

						if hasWeaponToEquip:
							if get_parent().componentOwner.pawnOwner.currentItem == null:
								if get_parent().componentOwner.aiMindState == 2:
									get_parent().componentOwner.pawnOwner.currentItemIndex = randi_range(1,get_parent().componentOwner.pawnOwner.itemInventory.size()-1)
									get_parent().componentOwner.pawnOwner.currentItem.weaponCast = sightCast

								if get_parent().componentOwner.aiMindState == 1:
									if !componentOwner.componentOwner.overlappingObject.currentItem == null:
										get_parent().componentOwner.pawnOwner.currentItemIndex = randi_range(1,get_parent().componentOwner.pawnOwner.itemInventory.size()-1)
										get_parent().componentOwner.pawnOwner.currentItem.weaponCast = sightCast

						if get_parent().componentOwner.pawnOwner.currentItem:
							get_parent().componentOwner.pawnOwner.meshLookAt = true
							get_parent().componentOwner.pawnOwner.currentItem.weaponCastEnd = sightcastEnd
							get_parent().componentOwner.pawnOwner.currentItem.weaponCast = sightCast
							get_parent().componentOwner.pawnOwner.meshRotation = sightCast.global_transform.basis.get_euler().y
						#Firing Logic

							if componentOwner.componentOwner.overlappingObject != null:
								target = componentOwner.componentOwner.overlappingObject
								if target != null:
									if !target.isPawnDead:
										if get_parent().componentOwner.aiMindState == 2:
											await get_tree().create_timer(randf_range(0.2,0.5)).timeout
											if get_parent().componentOwner.pawnOwner.currentItem:
												get_parent().componentOwner.pawnOwner.currentItem.fire()

										if get_parent().componentOwner.aiMindState == 1:
											if target.currentItem != null:
												if target.currentItem.isAiming or target.currentItem.isFiring:
													await get_tree().create_timer(randf_range(0.2,0.5)).timeout
													get_parent().componentOwner.pawnOwner.currentItem.fire()
			else:
				get_parent().componentOwner.pawnOwner.meshLookAt = false
				if get_parent().componentOwner.aiType == 0:
					transitionState.emit(self,"wonderState")

