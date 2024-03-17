extends CharacterBody3D
class_name BasePawn

##Signals
signal controllerAssigned
signal clothingChanged
signal itemChanged
signal forcingAnimation
signal killedPawn
signal hitboxAssigned(hitbox)

#Sounds
@onready var soundHolder = $Sounds
@onready var equipSound = $Sounds/equipSound
@onready var footstepSounds = $Sounds/footsteps
##Onready
@onready var footstepMaterialChecker = $Misc/footstepMaterialChecker
@onready var componentHolder = $Components
@onready var boneAttatchementHolder = $BoneAttatchments
@onready var interactRaycast = $Mesh/interactRaycast

##IK
@onready var bodyIK = $Mesh/MaleSkeleton/Skeleton3D/bodyIK
@onready var bodyIKMarker = $Mesh/Marker3D
@onready var leftHandIK = $Mesh/MaleSkeleton/Skeleton3D/LeftHandIK
@onready var leftHandIKMarker = $Mesh/MaleSkeleton/Skeleton3D/LeftHandIK/leftHandMarker
@onready var rightHandIK = $Mesh/MaleSkeleton/Skeleton3D/RightHandIK
@onready var rightHandIKMarker = $Mesh/MaleSkeleton/Skeleton3D/LeftHandIK/leftHandMarker
@onready var rightHandBone = $BoneAttatchments/rightHand
@onready var leftHandBone = $BoneAttatchments/leftHand
@onready var neckBone = $BoneAttatchments/Neck
@onready var chestBone = $BoneAttatchments/Stomach

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
@onready var downCheck = $Mesh/downCheck
@onready var aimBlockRaycast = $Mesh/aimDetect
@onready var floorcheck = $Mesh/floorCast
@onready var freeAimTimer = $freeAimTimer
@onready var pawnSkeleton = $Mesh/MaleSkeleton/Skeleton3D
@onready var animationTree = $AnimationTree
@onready var collisionShape = $CollisionShape3D
@onready var clothingHolder = $Mesh/MaleSkeleton/Skeleton3D/Clothing
@onready var pawnMesh = $Mesh
@onready var itemHolder = $BoneAttatchments/rightHand/Weapons
@onready var animationPlayer = $AnimationPlayer
##Internal Variables
var direction = Vector3.ZERO
var meshRotation : float = 0.0
##Component Setup
@export_category("Pawn")
var raycaster : RayCast3D
#Base Components - Components required for this entity to even be used
@export_subgroup("Base Components")
@export var velocityComponent : VelocityComponent
@export var healthComponent : HealthComponent
@export_subgroup("Sub-Components")
@export var inputComponent : Node:
	set(value):
		inputComponent = value
		if value == InputComponent:
			emit_signal("controllerAssigned")
	get:
		return inputComponent

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
@export var attachedCam : PlayerCamera:
	set(value):
		attachedCam = value
		emit_signal("cameraAttached")
	get:
		return attachedCam
@export_subgroup("Behavior")
@export var forceAnimation = false:
	set(value):
		emit_signal("forcingAnimation")
		forceAnimation = value
		if value == false:
			if animationTree:
				animationTree.active = false
		else:
			if animationTree:
				animationTree.active = true
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
var preventWeaponFire = false
@export var isPawnDead = false:
	set(value):
		isPawnDead = value
	get:
		return isPawnDead
@export var isMoving = false
@export_subgroup("Movement")
var goingUpHill : bool = false
var goingDownHill : bool = false
var oldPos : float = 0.0
@export var canRun : bool = true
@export var isRunning : bool = false
@export var JUMP_VELOCITY = 4.5
@export var defaultWalkSpeed = 3.0
@export var defaultRunSpeed = 6.0
@export var canJump = true
@export var isJumping = false
@export_subgroup("Inventory")
var lastItem
var itemNames : Array
@export var itemInventory : Array
var currentItem = null
@export var currentItemIndex = 0:
	set(value):
		currentItemIndex = clamp(value, 0, itemInventory.size()-1)
		currentItem = itemInventory[currentItemIndex]
		if !currentItem == null:
			equipWeapon(currentItemIndex)
			emit_signal("itemChanged")
		if attachedCam:
			attachedCam.resetCamCast()
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
@export_subgroup("Misc")
## First-person, just for shits and giggles
var isFirstperson = false
var hitboxes : Array
@export_subgroup("Staircase Handling")
@export var step_check_distance : float = 1.0
@export var step_max_distance : float = 0.5
@export var step_height_max : float = 1.0
@export var step_depth_min : float = 1


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	hitboxes = hitboxes.duplicate()
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

	fixRot()
	if animationTree:
		var dup = animationTree.tree_root.duplicate()
		animationTree.tree_root = dup
	#getAllHitboxes()
func _physics_process(delta):
	if forceAnimation:
		animationTree.active = false
		if !animationPlayer.is_playing():
			animationPlayer.play(animationToForce)
	else:
		animationTree.active = true

	if pawnEnabled:
		if !isPawnDead:
			##Debug

#region FirstPerson
			if isFirstperson:
				meshLookAt = true
				freeAim = true
#endregion


#region AimBlocking
			if aimBlockRaycast.is_colliding():
				preventWeaponFire = true
			else:
				preventWeaponFire = false
#endregion


#region FreeAim
			if freeAim:
				if !isFirstperson:
					meshLookAt = true
					bodyIK.start()
					bodyIK.interpolation = lerpf(bodyIK.interpolation, 1, turnSpeed * delta)
				else:
					meshLookAt = true
					if currentItem:
						bodyIK.start()
						bodyIK.interpolation = lerpf(bodyIK.interpolation, 1, turnSpeed * delta)
					else:
						bodyIK.interpolation = lerpf(bodyIK.interpolation, 0, turnSpeed * delta)
#endregion
			##Movement Code
			#TODO - AI Stuff here I think
			if !isMoving and footstepSounds.playing:
				footstepSounds.stop()

#region Item Equipping
			if !currentItem == null:
				#Add equipanimation here, once it it finishes, enable the hand IKs and lerp
				if currentItem:
					##Camera set
					if attachedCam:
						if currentItem.weaponResource.useCustomCrosshairSize:
							attachedCam.hud.getCrosshair().crosshairSize = currentItem.weaponResource.crosshairSizeOverride
						else:
							attachedCam.hud.getCrosshair().crosshairSize = attachedCam.hud.getCrosshair().defaultCrosshairSize
						if !UserConfig.game_simple_crosshairs:
							if currentItem.weaponResource.forcedCrosshair != null:
								attachedCam.hud.getCrosshair().setCrosshair(currentItem.weaponResource.forcedCrosshair)
							else:
								attachedCam.hud.getCrosshair().setCrosshair(attachedCam.hud.getCrosshair().defaultCrosshair)


						attachedCam.itemEquipOffsetToggle = true
						Dialogic.VAR.set('playerHasWeaponEquipped',true)

					#Weapon Aiming
					if meshLookAt and !freeAim:
						currentItem.isAiming = true
					else:
						currentItem.isAiming = false

					#Weapon Animations
					#await setupWeaponAnimations()

					#Set filters
					if currentItem.weaponResource.useLeftHand:
						setLeftHandFilter(true)
					else:
						setLeftHandFilter(false)

					if currentItem.weaponResource.useRightHand:
						setRightHandFilter(true)
					else:
						setRightHandFilter(false)

					#Set Parent Hands
					if currentItem.weaponResource.leftHandParent:
						itemHolder.reparent(leftHandBone)
						itemHolder.position = Vector3.ZERO

					if currentItem.weaponResource.rightHandParent:
						itemHolder.reparent(rightHandBone)
						itemHolder.position = Vector3.ZERO

					if !currentItem.weaponResource.useWeaponSprintAnim:
						if isMoving and isRunning and is_on_floor() and !meshLookAt:
							animationTree.set("parameters/weaponBlend/blend_amount", lerpf(animationTree.get("parameters/weaponBlend/blend_amount"), 0, 4*delta))
						else:
							animationTree.set("parameters/weaponBlend/blend_amount", lerpf(animationTree.get("parameters/weaponBlend/blend_amount"), 1, 12*delta))
			else:
				for weapon in itemHolder.get_children():
					weapon.hide()
				if attachedCam:
						Dialogic.VAR.set('playerHasWeaponEquipped',false)
						attachedCam.itemEquipOffsetToggle = false
						attachedCam.hud.getCrosshair().setCrosshair(null)
						attachedCam.resetCamCast()

				animationTree.set("parameters/weaponBlend/blend_amount", lerpf(animationTree.get("parameters/weaponBlend/blend_amount"), 0, 12*delta))
#endregion

#region Mesh Rotation
			if !is_on_wall():
				pawnMesh.rotation.x = clamp(lerp_angle(pawnMesh.rotation.x, (Vector3(velocity.x, 0.0, velocity.z) * pawnMesh.global_transform.basis).z * 0.01, delta * 256), -PI/6, PI/6)
				pawnMesh.rotation.z = clamp(lerpf(pawnMesh.rotation.z, -(Vector3(velocity.x, 0.0, velocity.z) * pawnMesh.global_transform.basis).x * 0.030, 256 * delta), -PI/6, PI/6)
			else:
				pawnMesh.rotation.x = lerpf(pawnMesh.rotation.x, 0, 12*delta)
				pawnMesh.rotation.z = lerpf(pawnMesh.rotation.z, 0, 12*delta)
			if !meshLookAt:
				if isMoving:
					if !is_on_wall():
						pawnMesh.rotation.y = lerp_angle(pawnMesh.rotation.y, atan2(-velocity.x,-velocity.z), 8 * delta)
					else:
						direction = Vector3.ZERO
						isMoving = false
			if meshLookAt:
				canJump = false
				bodyIKMarker.rotation.x = turnAmount
				pawnMesh.rotation.y = lerp_angle(pawnMesh.rotation.y, meshRotation, 23 * delta)
#endregion

			# Add the gravity
			if !is_on_floor():
				canJump = false
				velocity.y -= gravity * delta
				if !isJumping:
					animationTree.set("parameters/fallBlend/blend_amount", lerpf(animationTree.get("parameters/fallBlend/blend_amount"), 1.0, delta * 12))
			if is_on_floor():
				if !meshLookAt:
					canJump = true
				elif meshLookAt and isFirstperson:
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

			animationTree.set("parameters/aimSprintStrafe/blend_position",Vector2(-velocity.x, -velocity.z).rotated(meshRotation))
			animationTree.set("parameters/strafeSpace/blend_position",Vector2(-velocity.x, -velocity.z).rotated(meshRotation))
			if meshLookAt:
				bodyIK.start()
				bodyIK.interpolation = lerpf(bodyIK.interpolation, 1, turnSpeed * delta)
				if is_on_floor():
					animationTree.set("parameters/aimTransition/transition_request", "aiming")
					if !isRunning:
						animationTree.set("parameters/strafeType/transition_request", "walking")
					else:
						animationTree.set("parameters/strafeType/transition_request", "running")
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
				if inputComponent is Component:
					if inputComponent.movementEnabled:
						if Dialogic.current_timeline == null:
							direction = inputComponent.getInputDir().rotated(Vector3.UP, meshRotation)
						else:
							direction = Vector3.ZERO
##Checks to see if any required components (Base components) Are null
func checkComponents():
	if inputComponent:
		if inputComponent is AIComponent:
			inputComponent.pawnOwner = self
			await get_tree().process_frame
			inputComponent.aimCast.add_exception(self)
			inputComponent.aimCast.add_exception(getAllHitboxes())
			raycaster = inputComponent.aimCast
			healthComponent.connect("onDamaged",inputComponent.instantDetect.bind())
			#inputComponent.position = self.position

		if inputComponent is Component:
			inputComponent.controllingPawn = self
			if globalGameManager.activeCamera == null:
				var cam = load("res://assets/entities/camera/camera.tscn")
				var _cam = cam.instantiate()
				_cam.global_position = self.global_position
				await get_tree().process_frame
				globalGameManager.world.worldMisc.add_child(_cam)
				_cam.posessObject(self, followNode)
				_cam.camCast.add_exception(self)
				_cam.interactCast.add_exception(self)
				raycaster = _cam.camCast



	if velocityComponent == null or healthComponent == null:
		return null
	else:
		return OK

func die():
	if !attachedCam == null:
		globalGameManager.getEventSignal("playerDied").emit()
		attachedCam.lowHP = false
		attachedCam.hud.hudEnabled = false
		attachedCam.resetCamCast()
		Dialogic.end_timeline()
	var ragdoll = await createRagdoll(lastHitPart)
	await get_tree().process_frame
	removeComponents()
	dropWeapon()
	if currentItem:
		currentItem.weaponOwner = null
	currentItemIndex = 0
	currentItem = null
	pawnEnabled = false
	collisionEnabled = false
	isPawnDead = true
	$remover.start()
	footstepSounds.queue_free()

func _on_health_component_health_depleted():
	await get_tree().process_frame
	die()


func createRagdoll(impulse_bone : int = 0):
	#await get_tree().process_frame
	if !ragdollScene == null:
		collisionEnabled = false
		self.hide()
		var ragdoll = ragdollScene.instantiate()
		moveDecalsToRagdoll(ragdoll)
		ragdoll.global_transform = pawnMesh.global_transform
		ragdoll.rotation = pawnMesh.rotation
		ragdoll.targetSkeleton = pawnSkeleton
		globalGameManager.world.worldMisc.add_child(ragdoll)
		for bones in ragdoll.ragdollSkeleton.get_bone_count():
			ragdoll.ragdollSkeleton.set_bone_pose_position(bones, pawnSkeleton.get_bone_pose_position(bones))
			ragdoll.ragdollSkeleton.set_bone_pose_rotation(bones, pawnSkeleton.get_bone_pose_rotation(bones))

		for bones in ragdoll.ragdollSkeleton.get_child_count():
			var child = ragdoll.ragdollSkeleton.get_child(bones)
			if child is RagdollBone:
				child.linear_velocity = velocity
				child.angular_velocity = velocity
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
			await get_tree().process_frame
			await cam.unposessObject()
			await cam.posessObject(ragdoll, ragdoll.rootCameraNode)
			ragdoll.removeTime = 99999999
			ragdoll.removeTimer.stop()
			for bones in ragdoll.ragdollSkeleton.get_child_count():
				if ragdoll.ragdollSkeleton.get_child(bones) is RagdollBone:
					cam.camSpring.add_excluded_object(ragdoll.ragdollSkeleton.get_child(bones).get_rid())
			attachedCam = null
		collisionShape.queue_free()

		if ragdoll.activeRagdollEnabled:
			if impulse_bone == 41:
				ragdoll.activeRagdollEnabled = false
			forceAnimation = true
			animationToForce = "PawnAnim/WritheRightKneeBack"
		return ragdoll


func checkItems():
	for items in itemHolder.get_children():
		items.freeze = true
		items.collisionObject.disabled = true
		items.collisionEnabled = false
		if !items.isEquipped:
			items.visible = false
		items.position = Vector3.ZERO
		items.rotation = Vector3.ZERO
		if !itemInventory.has(items):
			itemInventory.append(items)
		if !itemNames.has(items.objectName):
			itemNames.append(items.objectName)

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

func moveDecalsToRagdoll(ragdoll):
	#Decal reparent..
	for decalBones in boneAttatchementHolder.get_children():
		var boneID = decalBones.bone_idx
		for decals in decalBones.get_children():
			pass
			#Console.add_console_message("For %s, %s" %[self,getCurrentDecalBones()])

func getAllHitboxes():
	for index in hitboxes.size()-1:
		return hitboxes[index]

func getCurrentDecalBones():
	#Decal reparent..
	for decalBones in boneAttatchementHolder.get_children():
		var boneID = decalBones.bone_idx
		for decals in decalBones.get_children():
			return decals
func jump():
	playFootstepAudio()
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
			if animationPlayer != null:
				animationPlayer.remove_animation_library("weaponAnims")
				if currentItem.animationPlayer != null:
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

func checkFootstepMateral():
	if footstepMaterialChecker.is_colliding():
		return
func playFootstepAudio(soundprofile : AudioStream = null):
	if !footstepSounds == null:
		if is_on_floor() and isMoving:
			if !soundprofile == null:
				footstepSounds.stream = soundprofile

			if !footstepSounds.playing:
				footstepSounds.play()


func _on_footsteps_finished():
	footstepSounds.stop()

func dropWeapon():
	if !isPawnDead:
		animationTree.set("parameters/weaponBlend/blend_amount", 0)
	if currentItem:
		currentItem.resetToDefault()
		currentItem.collisionEnabled = true
		currentItem.weaponAnimSet = false
		currentItem.isEquipped = false
		currentItem.show()
		currentItem.setInteractable()
		currentItem.apply_impulse(velocity)
		currentItem = null
		return true

func setFirstperson():
	isFirstperson = true
	rootCameraNode = $BoneAttatchments/Neck
	pawnCameraData = load("res://assets/resources/pawnRelated/pawnFPSCam.tres")
	attachedCam.posessObject(self,rootCameraNode)
	head.hide()
	upperChest.hide()

func setThirdperson():
	if freeAim and isFirstperson:
		freeAim = false
		isFirstperson = false
	isFirstperson = false
	rootCameraNode = $BoneAttatchments/Stomach
	pawnCameraData = load("res://assets/resources/pawnRelated/pawnDefaultCamData.tres")
	attachedCam.posessObject(self,rootCameraNode)
	head.show()
	upperChest.show()

func fixRot():
	pawnMesh.rotation = self.rotation
	self.rotation = Vector3.ZERO

func playAnimation(animation:String):
	if !forceAnimation:
		forceAnimation = true
	animationPlayer.play(animation)

func do_stairs() -> void:
	#Does staircase stuff
	#TODO : Integrate this guys Staircase Stuff
	if !floorcheck.is_colliding() or Vector3(velocity.x, 0, velocity.z).length() <= 1.0 or direction.length() <= 0.1:
		return
	#Check multiple directions
	var flat_vel = Vector3(velocity.x, 0.0, velocity.z).normalized()
	var check_directions : Array[Vector3] = [
		flat_vel,
		flat_vel.rotated(Vector3.UP, PI/3),
		flat_vel.rotated(Vector3.UP, -PI/3),
		]
	for direction in check_directions:
		var step_ray_dir := direction * step_check_distance
		if step_ray_dir.dot(Vector3(velocity.x, 0, velocity.z).normalized()) < 0.5:
			continue
		var direct_state = get_world_3d().direct_space_state
		var obs_ray_info : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
		obs_ray_info.exclude = [RID(self)]
		obs_ray_info.from = global_position + Vector3.UP * 0.1
		obs_ray_info.to = obs_ray_info.from + step_ray_dir
		#First check : Is a flat wall found?
		var first_collision = direct_state.intersect_ray(obs_ray_info)
		if !first_collision.is_empty():
			if not first_collision["collider"] is StaticBody3D:
				continue
			#TODO : Instead of using a while loop, figure out a better way
			#to get the wall above a slope.
			if first_collision["normal"].angle_to(Vector3.UP) < 1.39626:
				var remain_length = step_check_distance - first_collision["position"].distance_to(obs_ray_info.from)
				obs_ray_info.from = first_collision["position"]
				obs_ray_info.to = obs_ray_info.from + (remain_length * step_ray_dir.slide(first_collision["normal"]))
				obs_ray_info.to.y += 0.05
				first_collision = direct_state.intersect_ray(obs_ray_info)
				if first_collision.is_empty():
					return
				if first_collision["normal"].angle_to(Vector3.UP) < 1.39626:
					return
#			print("Ready to climb up step.")
			#From that first collision point, we now check if 'min_stair_depth' is met
			#at the the 'max_step_height'
			var depth_check : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
			depth_check.exclude = obs_ray_info.exclude
			depth_check.from = global_position + Vector3(0, step_height_max, 0)
			depth_check.to = depth_check.from + (step_ray_dir * (step_depth_min + global_position.distance_to(first_collision.position)))
			if !direct_state.intersect_ray(depth_check).is_empty():
				continue
			#The step is deep enough.
			#Last we need to find the top of the step so we can stand on it.
			#Inch the initial collision up by step_max and forward a tiny bit.
			#The to-position is just the initial position minus the step_max.
			var top_check : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
			top_check.exclude = obs_ray_info.exclude
			top_check.from = first_collision.position + Vector3(step_ray_dir.x, step_height_max, step_ray_dir.z)
			top_check.to = top_check.from - Vector3(0, step_height_max, 0)
			var stair_top_collision = direct_state.intersect_ray(top_check)
			if !stair_top_collision.is_empty():
					#move player up above step
					position.y += stair_top_collision.position.y - global_position.y
					#move player forward onto step
					position += (step_ray_dir * 0.1)
					return
#			print("Couldn't climb up the step.")

func getInteractionObject():
	if interactRaycast.is_colliding():
		var col = interactRaycast.get_collider()
		if col != null:
			if col.is_in_group("Interactable"):
				globalGameManager.getEventSignal("interactableFound").emit()
				return col

func getClothes():
	for clothes in clothingHolder.get_children():
		return clothes

func moveItemToWeapons(item:Weapon):
	item.reparent(itemHolder)
	item.position = Vector3.ZERO
	item.rotation = Vector3.ZERO
	checkItems()

