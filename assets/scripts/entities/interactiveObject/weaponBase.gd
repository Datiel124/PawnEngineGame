extends InteractiveObject
class_name Weapon

@onready var collisionObject = $collisionObject
@onready var animationTree = $AnimationTree
@onready var animationPlayer = $AnimationPlayer
var weaponCast : RayCast3D
var weaponCastEnd
var weaponState
var weaponRemoteState
var weaponAnimSet = false
var weaponOwner = null
@export_category("Weapon")
@export var weaponMesh : Node3D
@export var weaponResource : ItemData
@export_subgroup("Behavior")
var defaultBulletTrail = load("res://assets/entities/bulletTrail/bulletTrail.tscn")
@export var muzzlePoint : Marker3D
@export var collisionEnabled = true
@export var isEquipped : bool = false
@export var isFiring = false
@export var isAiming = false
@export var isBusy = false
@export var isWeaponBlocked = false
signal shot_fired

# Called when the node enters the scene tree for the first time.
func _ready():
		objectUsed.connect(equipToPawn)
		animationTree.tree_root = animationTree.tree_root.duplicate(true)
		weaponState = (animationTree.get("parameters/weaponState/playback") as AnimationNodeStateMachinePlayback)
		if get_parent().name == "Weapons":
			set("gravity_scale", 0)
			if weaponMesh:
				weaponMesh.position = weaponResource.weaponPositionOffset
				weaponMesh.rotation = weaponResource.weaponRotationOffset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if weaponResource:
		if !weaponOwner == null:
			if isEquipped:
				if is_in_group("Interactable"):
					remove_from_group("Interactable")
				canBeUsed = false
				collisionEnabled = false
				#Weapon Orientation
				weaponMesh.position = weaponResource.weaponPositionOffset
				weaponMesh.rotation = weaponResource.weaponRotationOffset

				if weaponOwner.attachedCam:
					weaponOwner.attachedCam.camRecoil = weaponResource.weaponRecoil

				if weaponAnimSet:
					if !weaponOwner == null:
						if weaponResource.useWeaponSprintAnim:
								if weaponOwner.isRunning:
									if !weaponRemoteState.get_current_node() == "sprint":
										weaponRemoteState.travel("sprint")

					if !isFiring and !isAiming and !weaponOwner.freeAim:
						if !weaponRemoteState.get_current_node() == "idle":
							weaponRemoteState.travel("idle")
							if weaponResource.useLeftHandIdle:
								weaponResource.useLeftHand = true
							else:
								weaponResource.useLeftHand = false
							if weaponResource.useRightHandIdle:
								weaponResource.useRightHand = true
							else:
								weaponResource.useRightHand = false
					if isAiming:
						if weaponResource.useLeftHandAiming:
							weaponResource.useLeftHand = true
						else:
							weaponResource.useLeftHand = false
						if weaponResource.useRightHandAiming:
							weaponResource.useRightHand = true
						else:
							weaponResource.useRightHand = false


						if !weaponOwner.meshLookAt:
							weaponOwner.meshLookAt = true
						if !weaponRemoteState.get_current_node() == "aim" and !weaponOwner.preventWeaponFire:
								weaponRemoteState.travel("aim")
						elif weaponOwner.preventWeaponFire:
							weaponRemoteState.travel("idle")
					if weaponOwner.freeAim:
						if !weaponRemoteState.get_current_node() == "aim" and !weaponOwner.preventWeaponFire:
							weaponRemoteState.travel("aim")
							if weaponResource.useLeftHandFreeAiming:
								weaponResource.useLeftHand = true
							else:
								weaponResource.useLeftHand = false
							if weaponResource.useRightHandFreeAiming:
								weaponResource.useRightHand = true
							else:
								weaponResource.useRightHand = false
						elif weaponOwner.preventWeaponFire:
							weaponRemoteState.travel("idle")

				collisionEnabled = false

	if collisionEnabled:
		collisionObject.disabled = false
	else:
		collisionObject.disabled = true


func fire():
	if !weaponOwner.preventWeaponFire:
		if !isFiring:
			if isAiming:
				if weaponOwner.attachedCam:
						weaponOwner.attachedCam.camRecoilStrength = weaponResource.weaponRecoilStrengthAim
						weaponOwner.attachedCam.applyWeaponSpread(weaponResource.weaponSpreadAim)
			else:
				if weaponOwner.attachedCam:
					weaponOwner.attachedCam.camRecoilStrength = weaponResource.weaponRecoilStrength
					weaponOwner.attachedCam.applyWeaponSpread(weaponResource.weaponSpread)
			if weaponCast:
				weaponCast.rotation -= Vector3(randf_range(-weaponResource.weaponSpread, weaponResource.weaponSpread),randf_range(-weaponResource.weaponSpread, weaponResource.weaponSpread),0) * randf_range(1.6,2.5)
			shot_fired.emit()
			if weaponRemoteState:
				weaponRemoteState.start("fire")
			if weaponOwner.attachedCam:
				weaponOwner.attachedCam.fireRecoil()

			isFiring = true
			#Bullet Creation/Raycast Bullet Creation
			for bullet in weaponResource.weaponShots:
				bullet = createMuzzle()
				if weaponResource.weaponShots > 1:
					bullet.position.x += randf_range(-0.09,0.09)
					bullet.position.y += randf_range(-0.05,0.05)
				if checkShooter():
					if weaponOwner.attachedCam.camCast.is_colliding():
						raycastHit()
						var hit = globalParticles.detectMaterial(getHitObject())
						if hit != null:
							var pt = globalParticles.createParticle(globalParticles.detectMaterial(getHitObject()), getRayColPoint())
							if !pt == null:
								pt.look_at(getRayColPoint() + getRayNormal())
				else:
					if weaponCast.is_colliding():
						raycastHit(weaponCast)
						var hit = globalParticles.detectMaterial(getHitObject(weaponCast))
						if hit != null:
							var pt = globalParticles.createParticle(globalParticles.detectMaterial(getHitObject(weaponCast)), getRayColPoint(weaponCast))
							if !pt == null:
								pt.look_at(getRayColPoint(weaponCast) + getRayNormal(weaponCast))


			await get_tree().create_timer(weaponResource.weaponFireRate).timeout
			isFiring = false


func createMuzzle():
	var bulletTrail = defaultBulletTrail.instantiate()
	#var btInstance = bulletTrail.instantiate()
	if !muzzlePoint == null:
		if checkShooter():
			if weaponOwner.attachedCam.camCast.is_colliding():
				bulletTrail.initTrail(muzzlePoint.global_position, getRayColPoint())
			else:
				bulletTrail.initTrail(muzzlePoint.global_position, weaponOwner.attachedCam.camCastEnd.global_position)
			globalGameManager.world.worldMisc.add_child(bulletTrail)
			return bulletTrail
		else:
			if weaponCast.is_colliding():
				bulletTrail.initTrail(muzzlePoint.global_position, getRayColPoint(weaponCast))
			else:
				bulletTrail.initTrail(muzzlePoint.global_position, weaponCastEnd.global_position)
			globalGameManager.world.worldMisc.add_child(bulletTrail)
			return bulletTrail
	else:
		print_rich("[color=red]This weapon doesn't have a muzzle point! Add one now fucker.[/color]")

func checkShooter():
	if weaponOwner.attachedCam:
		return true
	else:
		return false

func raycastHit(raycaster : RayCast3D = null):
		var colliding
		var hitPoint
		var hitNormal
		var raycast : RayCast3D
		if raycaster != null:
			raycast = raycaster
		else:
			raycast = weaponOwner.attachedCam.camCast
		colliding = raycast.get_collider()
		hitPoint = raycast.get_collision_point()
		hitNormal = raycast.get_collision_normal()
		if colliding:
			if colliding.is_in_group("Flesh"):
				var spurtChance = randi_range(0,1)
				var fleshHole = globalParticles.spawnBulletHole("Flesh",colliding,hitPoint,randf_range(0, 2),hitNormal)
				if hitNormal == Vector3.DOWN:
					fleshHole.rotation_degrees.x = 90
				elif hitNormal != Vector3.UP:
					fleshHole.look_at(hitPoint - hitNormal, Vector3(0,1,0))
				if spurtChance == 1:
					var bloodStream = globalParticles.createParticle("BloodStream",hitPoint,Vector3.ZERO,colliding)
					bloodStream.look_at(hitPoint+hitNormal/2)
			else:
				var bhole = globalParticles.spawnBulletHole("default",colliding,hitPoint,randf_range(0, 2),hitNormal)
				if hitNormal == Vector3.DOWN:
					bhole.rotation_degrees.x = 90
				elif hitNormal != Vector3.UP:
					bhole.look_at(hitPoint - hitNormal, Vector3(0,1,0))
				#bhole.particles.look_at(muzzlePoint.global_position)
			if colliding.has_method("hit"):
				colliding.hit(weaponResource.weaponDamage,weaponOwner,global_position.direction_to(hitPoint).normalized() * weaponResource.weaponImpulse,to_global(to_local(hitPoint)-position))

func getHitObject(raycaster : RayCast3D = null):
	var raycast : RayCast3D
	if raycaster:
		raycast = raycaster
	else:
		raycast = weaponOwner.attachedCam.camCast
	var hitObject = raycast.get_collider()
	if raycast.is_colliding():
		return hitObject

func getRayNormal(raycaster : RayCast3D = null):
	var raycast : RayCast3D
	if raycaster:
		raycast = raycaster
	else:
		raycast = weaponOwner.attachedCam.camCast
	var hitNormal = raycast.get_collision_normal()
	if raycast.is_colliding():
		return hitNormal

func getRayColPoint(raycaster : RayCast3D = null):
	var raycast : RayCast3D
	if raycaster:
		raycast = raycaster
	else:
		raycast = weaponOwner.attachedCam.camCast
	var hitPoint = raycast.get_collision_point()
	if raycast.is_colliding():
		return hitPoint

func resetToDefault():
	if weaponMesh:
		weaponMesh.position = position
		weaponMesh.rotation = rotation
		collisionObject.rotation = weaponMesh.rotation
	weaponAnimSet = false
	weaponOwner = null
	isFiring = false
	isAiming = false
	isEquipped = false
	collisionEnabled = false

func equipToPawn(pawn:BasePawn):
	if !pawn.itemInventory.has(self):
		collisionEnabled = false
		collisionObject.disabled = true
		pawn.moveItemToWeapons(self)
		if objectUsed.is_connected(equipToPawn):
			objectUsed.disconnect(equipToPawn)
		if pawn.attachedCam:
			globalGameManager.notifyFade("%s Added to inventory." %objectName)
			pawn.equipSound.play()
			pawn.attachedCam.fireRecoil(0,0.7,0.4)

func setInteractable():
		reparent(globalGameManager.world.worldProps)
		set("gravity_scale", 1)
		add_to_group("Interactable")
		interactType = 0
		canBeUsed = true
		freeze = false
