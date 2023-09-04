extends CharacterBody3D
class_name BasePawn

##Signals
signal playerAssigned
signal aiAssigned
signal clothingChanged
signal itemChanged

#Sounds
@onready var soundHolder = $Sounds
@onready var equipSound = $Sounds/equipSound
##Onready

##IK
@onready var bodyIK = $Mesh/MaleSkeleton/Skeleton3D/bodyIK
@onready var bodyIKMarker = $Mesh/Marker3D
@onready var leftHandIK = $Mesh/MaleSkeleton/Skeleton3D/LeftHandIK
@onready var leftHandIKMarker = $Mesh/MaleSkeleton/Skeleton3D/LeftHandIK/leftHandMarker
@onready var rightHandIK = $Mesh/MaleSkeleton/Skeleton3D/RightHandIK
@onready var rightHandIKMarker = $Mesh/MaleSkeleton/Skeleton3D/LeftHandIK/leftHandMarker
@onready var rightHandBone = $BoneAttatchments/rightHand
@onready var leftHandBone = $BoneAttatchments/leftHand

##Pawn Parts
@onready var head = $Mesh/MaleSkeleton/Skeleton3D/MaleHead
@onready var upperChest = $Mesh/MaleSkeleton/Skeleton3D/Male_UpperBody
@onready var shoulders = $Mesh/MaleSkeleton/Skeleton3D/Male_Shoulders
@onready var leftUpperArm = $Mesh/MaleSkeleton/Skeleton3D/Male_LeftArm
@onready var rightUpperArm = $Mesh/MaleSkeleton/Skeleton3D/Male_RightArm
@onready var leftForearm = $Mesh/MaleSkeleton/Skeleton3D/Male_LeftForearm
@onready var rightForearm = $Mesh/MaleSkeleton/Skeleton3D/Male_RightForearm
@onready var lowerBody = $Mesh/MaleSkeleton/Skeleton3D/Male_LowerBody
@onready var leftUpperLeg = $Mesh/MaleSkeleton/Skeleton3D/Male_LeftThigh
@onready var rightUpperLeg = $Mesh/MaleSkeleton/Skeleton3D/Male_RightThigh
@onready var leftLowerLeg = $Mesh/MaleSkeleton/Skeleton3D/Male_LeftKnee
@onready var rightLowerLeg = $Mesh/MaleSkeleton/Skeleton3D/Male_RightKnee

@onready var freeAimTimer = $freeAimTimer
@onready var pawnSkeleton = $Mesh/MaleSkeleton/Skeleton3D
@onready var animationTree = $AnimationTree
@onready var collisionShape = $CollisionShape3D
@onready var clothingHolder = $Mesh/MaleSkeleton/Skeleton3D/Clothing
@onready var pawnMesh = $Mesh
@onready var componentHolder = $Components
@onready var itemHolder = $BoneAttatchments/rightHand/Weapons
@onready var animationPlayer = $AnimationPlayer
##Internal Variables
var direction = Vector3.ZERO
var meshRotation : float = 0.0
##Component Setup
@export_category("Pawn")
#Base Components - Components required for this entity to even be used
@export_subgroup("Base Components")
@export var velocityComponent : VelocityComponent
@export var healthComponent : HealthComponent
@export_subgroup("Sub-Components")
@export var inputComponent : InputComponent:
	set(value):
		inputComponent = value
		if value == InputComponent:
			emit_signal("playerAssigned")
	get:
		return inputComponent
@export var aiClassComponent : Component:
	set(value):
		aiClassComponent = value
		emit_signal("aiAssigned")
	get:
		return aiClassComponent

##Variables
@export_subgroup("Camera Behavior")
##Root Follow Node
@export var rootCameraNode : Node3D
##Camera Data for a camera to follow
@export var pawnCameraData : CameraData
##If a camera were to be attached to this node, it would follow this.
@export var followNode : Node3D
##The current attached camera (if there is one)
signal cameraAttached
@export var attachedCam : CharacterBody3D:
	set(value):
		attachedCam = value
		emit_signal("cameraAttached")
	get:
		return attachedCam
@export_subgroup("Behavior")
@export var forceAnimation = false
@export var animationToForce : String = ""
##Allows the pawn to interact with the environment, move and have physics applied, etc..
@export var freeAim : bool = false
@export var pawnEnabled = true
@export var collisionEnabled = true:
	set(value):
		collisionEnabled = value
	get:
		return collisionEnabled

@export_subgroup("Variables")
signal pawnDied(pawnRagdoll)
@export var turnAmount : float
@export var turnSpeed = 18.0
@export var isPawnDead = false:
	set(value):
		isPawnDead = value
	get:
		return isPawnDead
@export var isMoving = false
@export_subgroup("Movement")
@export var canRun : bool = true
@export var isRunning : bool = false
@export var JUMP_VELOCITY = 4.5
@export var defaultWalkSpeed = 3.0
@export var defaultRunSpeed = 6.0
@export var canJump = true
@export var isJumping = false
@export_subgroup("Inventory")
var lastItem
@export var itemInventory : Array
var currentItem = null
@export var currentItemIndex = 0:
	set(value):
		currentItemIndex = clamp(value, 0, itemInventory.size()-1)
		currentItem = itemInventory[currentItemIndex]
		if !currentItem == null:
			equipWeapon(currentItemIndex)
		emit_signal("itemChanged")
@export var clothingInventory : Array:
	set(value):
		emit_signal("clothingChanged")

@export_subgroup("Mesh")
##Ragdoll to spawn when the pawn dies
@export var ragdollScene : PackedScene
##Makes the mesh look at a certain thing, mainly used for aiming
@export var meshLookAt = false
@export var lastHitPart : int
@export var hitImpulse : Vector3 = Vector3.ZERO
@export var hitVector : Vector3 = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	itemInventory.append(null)
	checkComponents()
	checkClothes()
	checkItems()
	if collisionEnabled:
		collisionShape.disabled = false
	else:
		collisionShape.disabled = false

	if forceAnimation:
		animationTree.active = false
		animationPlayer.play(animationToForce)


func _physics_process(delta):
	if pawnEnabled:
		if !isPawnDead:
			##Debug

			##FreeAim
			if freeAim:
				meshLookAt = true
				bodyIK.start()
				bodyIK.interpolation = lerpf(bodyIK.interpolation, 1, turnSpeed * delta)
				

			##Movement Code
			#TODO - AI Stuff here I think

			##Item Equip
			if !currentItem == null:
				#Add equipanimation here, once it it finishes, enable the hand IKs and lerp
				if currentItem:
					##Camera set
					if attachedCam:
						attachedCam.itemEquipOffsetToggle = true

					#Weapon Aiming
					if meshLookAt and !freeAim:
						currentItem.isAiming = true
					else:
						currentItem.isAiming = false

					#Weapon Animations
					#await setupWeaponAnimations()

					#Set filters
					if currentItem.useLeftHand:
						setLeftHandFilter(true)
					else:
						setLeftHandFilter(false)

					if currentItem.useRightHand:
						setRightHandFilter(true)
					else:
						setRightHandFilter(false)

					#Set Parent Hands
					if currentItem.leftHandParent:
						itemHolder.reparent(leftHandBone)
						itemHolder.position = Vector3.ZERO

					if currentItem.rightHandParent:
						itemHolder.reparent(rightHandBone)
						itemHolder.position = Vector3.ZERO

					if !currentItem.useWeaponSprintAnim:
						if isMoving and isRunning and is_on_floor() and !meshLookAt:
							animationTree.set("parameters/weaponBlend/blend_amount", lerpf(animationTree.get("parameters/weaponBlend/blend_amount"), 0, 4*delta))
						else:
							animationTree.set("parameters/weaponBlend/blend_amount", lerpf(animationTree.get("parameters/weaponBlend/blend_amount"), 1, 12*delta))
			else:
				for weapon in itemHolder.get_children():
					weapon.hide()
				if attachedCam:
						attachedCam.itemEquipOffsetToggle = false
				animationTree.set("parameters/weaponBlend/blend_amount", lerpf(animationTree.get("parameters/weaponBlend/blend_amount"), 0, 12*delta))
			##Mesh Rotation
			if !meshLookAt:
				if isMoving:
					if !is_on_wall():
						pawnMesh.rotation.y = lerp_angle(pawnMesh.rotation.y, atan2(-velocity.x,-velocity.z), 8 * delta)
			if meshLookAt:
				canJump = false
				bodyIKMarker.rotation.x = turnAmount
				pawnMesh.rotation.y = lerp_angle(pawnMesh.rotation.y, meshRotation, 23 * delta)


			# Add the gravity
			if !is_on_floor():
				canJump = false
				velocity.y -= gravity * delta
				if !isJumping:
					animationTree.set("parameters/fallBlend/blend_amount", lerpf(animationTree.get("parameters/fallBlend/blend_amount"), 1.0, delta * 12))
			if is_on_floor():
				if !meshLookAt:
					canJump = true
				animationTree.set("parameters/fallBlend/blend_amount", lerpf(animationTree.get("parameters/fallBlend/blend_amount"), 0.0, delta * 12))
				animationTree.set("parameters/jumpBlend/blend_amount", lerpf(animationTree.get("parameters/jumpBlend/blend_amount"), 0.0, delta * 12))

			if direction != Vector3.ZERO:
					isMoving = true
					direction = direction.normalized()
			else:
				isMoving = false

			if !velocityComponent == null:
				velocity.x = velocityComponent.accelerateToVel(direction, delta, true, false, false).x
				velocity.z = velocityComponent.accelerateToVel(direction, delta, false, false, true).z

			##Run Speed
			if !velocityComponent == null:
				if !isRunning:
					velocityComponent.vMaxSpeed = defaultWalkSpeed
				else:
					velocityComponent.vMaxSpeed = defaultRunSpeed

			#Jump Animation
				if isJumping:
					animationTree.set("parameters/jumpBlend/blend_amount", lerpf(animationTree.get("parameters/jumpBlend/blend_amount"), 1.0, delta * 12))
				else:
					animationTree.set("parameters/jumpBlend/blend_amount", lerpf(animationTree.get("parameters/jumpBlend/blend_amount"), 0.0, delta * 12))

			if meshLookAt:
				bodyIK.start()
				bodyIK.interpolation = lerpf(bodyIK.interpolation, 1, turnSpeed * delta)
				if is_on_floor():
					animationTree.set("parameters/strafeSpace/blend_position",Vector2(-velocity.x, -velocity.z).rotated(meshRotation))
					animationTree.set("parameters/aimTransition/transition_request", "aiming")
				else:
					animationTree.set("parameters/aimTransition/transition_request", "notAiming")
			else:
				animationTree.set("parameters/aimTransition/transition_request", "notAiming")
				bodyIK.interpolation = lerpf(bodyIK.interpolation, 0, turnSpeed * delta)
				if bodyIK.interpolation <= 0:
					bodyIK.stop()
				if isMoving:
					if !isRunning:
						if !velocityComponent == null:
							animationTree.set("parameters/runBlend/blend_amount", lerpf(animationTree.get("parameters/runBlend/blend_amount"), 0.0, delta * velocityComponent.getAcceleration()))
							animationTree.set("parameters/idleSpace/blend_position", lerpf(animationTree.get("parameters/idleSpace/blend_position"), 1, delta * velocityComponent.getAcceleration()))
					if isRunning:
						if !velocityComponent == null:
							animationTree.set("parameters/runBlend/blend_amount", lerpf(animationTree.get("parameters/runBlend/blend_amount"), 1.0, delta * velocityComponent.getAcceleration()))
				else:
					if !velocityComponent == null:
						animationTree.set("parameters/runBlend/blend_amount", lerpf(animationTree.get("parameters/runBlend/blend_amount"), 0.0, delta * velocityComponent.getAcceleration()))
						animationTree.set("parameters/idleSpace/blend_position", lerp(animationTree.get("parameters/idleSpace/blend_position"), 0.0, delta * velocityComponent.getAcceleration()))
			#Move the pawn accordingly
			move_and_slide()


			#Player movement
			if inputComponent:
				direction = inputComponent.getInputDir().rotated(Vector3.UP, meshRotation)

##Checks to see if any required components (Base components) Are null
func checkComponents():
	if inputComponent:
		inputComponent.controllingPawn = self
		if globalGameManager.activeCamera == null:
			var cam = load("res://assets/entities/camera/camera.tscn")
			var _cam = cam.instantiate()
			_cam.global_position = self.global_position
			await get_tree().process_frame
			globalGameManager.world.worldMisc.add_child(_cam)
			_cam.posessObject(self, followNode)
			_cam.camCast.add_exception(self)

	if velocityComponent == null or healthComponent == null:
		return null
	else:
		return OK

func die():
	removeComponents()
	unequipWeapon()
	currentItemIndex = 0
	currentItem = null
	pawnEnabled = false
	collisionEnabled = false
	isPawnDead = true
	$remover.start()


func _on_health_component_health_depleted():
	die()
	createRagdoll(lastHitPart)

func createRagdoll(impulse_bone : int = 0):
	if !ragdollScene == null:
		collisionEnabled = false
		self.hide()
		var ragdoll = ragdollScene.instantiate()
		ragdoll.global_transform = pawnMesh.global_transform
		ragdoll.rotation = pawnMesh.rotation
		globalGameManager.world.worldMisc.add_child(ragdoll)
		for bones in ragdoll.ragdollSkeleton.get_bone_count():
			ragdoll.ragdollSkeleton.set_bone_pose_position(bones, pawnSkeleton.get_bone_pose_position(bones))
			ragdoll.ragdollSkeleton.set_bone_pose_rotation(bones, pawnSkeleton.get_bone_pose_rotation(bones))

		for bones in ragdoll.ragdollSkeleton.get_child_count():
			var child = ragdoll.ragdollSkeleton.get_child(bones)
			if child is RagdollBone:
				ragdoll.startRagdoll()
				child.apply_central_impulse(velocity)
				if child.get_bone_id() == impulse_bone:
					ragdoll.startRagdoll()
					child.apply_impulse(hitImpulse, hitVector)

		emit_signal("pawnDied",ragdoll)
		await moveClothesToRagdoll(ragdoll)
		ragdoll.checkClothingHider()

		if !attachedCam == null:
			var cam = attachedCam
			await cam.unposessObject()
			await cam.posessObject(ragdoll)
			for bones in ragdoll.ragdollSkeleton.get_child_count():
				if ragdoll.ragdollSkeleton.get_child(bones) is RagdollBone:
					cam.vertical.add_excluded_object(ragdoll.ragdollSkeleton.get_child(bones).get_rid())
			attachedCam = null
		collisionShape.queue_free()


func checkItems():
	for items in itemHolder.get_children():
		items.freeze = true
		items.collisionEnabled = false
		items.visible = false
		items.position = Vector3.ZERO
		items.rotation = Vector3.ZERO
		if !itemInventory.has(items):
			itemInventory.append(items)

func checkClothes():
	for clothes in clothingHolder.get_children():
		if !clothingInventory.has(clothes):
			clothingInventory.append(clothes)
			clothes.itemSkeleton = pawnSkeleton.get_path()
			clothes.remapSkeleton()

	checkClothingHider()

func moveClothesToRagdoll(moveto):
	for clothes in clothingHolder.get_children():
		clothes.itemSkeleton = moveto.ragdollSkeleton.get_path()
		clothes.reparent(moveto)
		clothes.remapSkeleton()
	return

func checkClothingHider():
	for clothes in clothingHolder.get_children():
		if clothes is ClothingItem:
			if clothes.head:
				head.hide()
			if clothes.rightUpperarm:
				rightUpperArm.hide()
			if clothes.leftUpperarm:
				leftUpperArm.hide()
			if clothes.shoulders:
				shoulders.hide()
			if clothes.leftForearm:
				leftForearm.hide()
			if clothes.rightForearm:
				rightForearm.hide()
			if clothes.upperChest:
				upperChest.hide()
			if clothes.lowerBody:
				lowerBody.hide()
			if clothes.leftUpperLeg:
				leftUpperLeg.hide()
			if clothes.rightUpperLeg:
				rightUpperLeg.hide()
			if clothes.rightLowerLeg:
				rightLowerLeg.hide()
			if clothes.leftLowerLeg:
				leftLowerLeg.hide()

func jump():
	if !isJumping:
		isJumping = true
		canJump = false
		if is_on_floor():
			isJumping = false
	velocity.y = JUMP_VELOCITY

func setupWeaponAnimations():
	if !currentItem == null:
		if !currentItem.weaponAnimSet:
			#Swap out animationLibraries
			animationPlayer.remove_animation_library("weaponAnims")
			animationPlayer.add_animation_library("weaponAnims", currentItem.animationPlayer.get_animation_library("weaponAnims"))

			#Add the weapons stateMachine to the player
			(animationTree.tree_root as AnimationNodeBlendTree).disconnect_node("weaponBlend", 1)
			animationTree.tree_root.remove_node("weaponState")
			animationTree.tree_root.add_node("weaponState", currentItem.animationTree.tree_root)
			(animationTree.tree_root as AnimationNodeBlendTree).connect_node("weaponBlend", 1, "weaponState")
			currentItem.weaponRemoteState = animationTree.get("parameters/weaponState/weaponState/playback")
			currentItem.weaponAnimSet = true
			return
	else:
		print_rich("[color=red]You don't have a weapon![/color]")
		return

func setLeftHandFilter(value : bool = true):
	var filterBlend = animationTree.tree_root.get_node("weaponBlend")
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Shoulder", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_UpperArm", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Forearm", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Hand", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Thumb0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Thumb1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Thumb2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Index0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Index1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Index2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Middle0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Middle1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Middle2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Ring0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Ring1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Ring2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Pinkie0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Pinkie1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:L_Pinkie2", value)

func setRightHandFilter(value : bool = true):
	var filterBlend = animationTree.tree_root.get_node("weaponBlend")
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Shoulder", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_UpperArm", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Forearm", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Hand", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Thumb0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Thumb1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Thumb2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Index0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Index1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Index2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Middle0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Middle1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Middle2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Ring0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Ring1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Ring2", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Pinkie0", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Pinkie1", value)
	filterBlend.set_filter_path("MaleSkeleton/Skeleton3D:R_Pinkie2", value)

func equipWeapon(index):
	await unequipWeapon()
	if !equipSound.playing:
		equipSound.play()
	currentItem = itemInventory[index]
	currentItem.weaponOwner = self
	currentItem.isEquipped = true
	currentItem.visible = true
	await setupWeaponAnimations()
	return true

func unequipWeapon():
	animationTree.set("parameters/weaponBlend/blend_amount", 0)
	for weapon in itemHolder.get_children():
		weapon.hide()
		weapon.resetToDefault()
	if currentItem:
		currentItem.resetToDefault()
		currentItem.weaponAnimSet = false
		currentItem.isEquipped = false
		currentItem.hide()
		currentItem = null
		return true



func _on_free_aim_timer_timeout():
	freeAim = false


func _on_remover_timeout():
	queue_free()

func removeComponents():
	velocityComponent = null
	inputComponent = null
