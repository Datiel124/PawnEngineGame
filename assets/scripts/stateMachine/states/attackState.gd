extends State
@export_category("Attack AI")
@export var hasWeaponToEquip : bool
@export var sightCast : RayCast3D
var pawnToAttack
var pawnControlling
# Called when the node enters the scene tree for the first time.

func enterState():
	pawnControlling = get_parent().componentOwner.pawnOwner


# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateState(delta):
	if get_parent().componentOwner.pawnOwner:
		if !get_parent().componentOwner.pawnOwner.isPawnDead:
			sightCast.add_exception(get_parent().componentOwner.pawnOwner)
			#Set Positioning for the raycast
			sightCast.position = get_parent().componentOwner.pawnOwner.neckBone.position
			sightCast.rotation = get_parent().componentOwner.pawnOwner.pawnMesh.rotation

			#Set if the pawn has a weapon that can be equipped or not
			if get_parent().componentOwner.pawnOwner.itemInventory.size() >= 1:
				hasWeaponToEquip = true
			else:
				hasWeaponToEquip = false

			#If the raycast sees someone
			if sightCast.is_colliding():
				var colliding = sightCast.get_collider()
				#pawnToAttack = colliding
				if colliding:
					if hasWeaponToEquip:
						if get_parent().componentOwner.pawnOwner.currentItem == null:
							get_parent().componentOwner.pawnOwner.currentItemIndex = randi_range(1,get_parent().componentOwner.pawnOwner.itemInventory.size()-1)

					if get_parent().componentOwner.pawnOwner.currentItem:
						get_parent().componentOwner.pawnOwner.meshLookAt = true
						var collisionVector = get_parent().componentOwner.pawnOwner.pawnMesh.global_position.direction_to(colliding.position)
						var collisionBasis = get_parent().componentOwner.pawnOwner.pawnMesh.global_transform.basis.looking_at(collisionVector)
						get_parent().componentOwner.pawnOwner.pawnMesh.global_transform.basis.slerp(collisionBasis, delta* 24)
						get_parent().componentOwner.pawnOwner.meshRotation = get_parent().componentOwner.pawnOwner.pawnMesh.global_transform.basis.get_euler().y
				else:
					get_parent().componentOwner.pawnOwner.meshLookAt = false
		else:
			get_parent().queue_free()
