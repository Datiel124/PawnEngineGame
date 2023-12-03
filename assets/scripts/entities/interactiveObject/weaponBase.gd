extends InteractiveObject
class_name Weapon

@onready var weaponMesh = $Mesh
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
@export_subgroup("Behavior")
var defaultBulletTrail = load("res://assets/entities/bulletTrail/bulletTrail.tscn")
@export var muzzlePoint : Marker3D
@export var collisionEnabled = true
@export var isEquipped : bool = false
@export var isFiring = false
@export var isAiming = false
@export var isBusy = false
@export_subgroup("Stats")
## How much damage does the weapon do?
@export var weaponDamage = 5.0
## How fast does the weapon fire?
@export var weaponFireRate = 0.4
## Determines how much impulse is applied towards physics objects.
@export var weaponImpulse = 5.0
## How many bullets are shot out? Useful for shotguns. Default is 1.
@export var weaponShots = 1
@export_subgroup("Recoil")
@export var weaponRecoil : Vector3 = Vector3(5 ,1 , 0.25)
@export var weaponRecoilStrength : float = 8.0
@export var weaponSpread = 0.25
@export_subgroup("Aiming Recoil")
@export var weaponRecoilStrengthAim : float = 4.0
@export var weaponSpreadAim = 0.25
@export_category("Weapon Animations")
var useLeftHand = false
var useRightHand = true
@export var leftHandParent = false
@export var rightHandParent = true
@export var useWeaponSprintAnim = false
@export_subgroup("Idle Weapon Handling")
@export var useLeftHandIdle = true
@export var useRightHandIdle = true
@export_subgroup("Aim Weapon Handling")
@export var useLeftHandAiming = true
@export var useRightHandAiming = true
@export_subgroup("FreeAim Weapon Handling")
@export var useLeftHandFreeAiming = true
@export var useRightHandFreeAiming = true
@export_subgroup("Weapon Orientation")
@export var weaponPositionOffset = Vector3.ZERO
@export var weaponRotationOffset = Vector3.ZERO

signal shot_fired

# Called when the node enters the scene tree for the first time.
func _ready():
		animationTree.tree_root = animationTree.tree_root.duplicate(true)
		weaponState = (animationTree.get("parameters/weaponState/playback") as AnimationNodeStateMachinePlayback)
		if get_parent().name == "Weapons":
			set("gravity_scale", 0)
			weaponMesh.position = weaponPositionOffset
			weaponMesh.rotation = weaponRotationOffset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !weaponOwner == null:
		if isEquipped:
			set("gravity_scale", 0)
			#Weapon Orientation
			weaponMesh.position = lerp(weaponMesh.position, weaponPositionOffset, 24 * delta)
			weaponMesh.rotation = lerp(weaponMesh.rotation, weaponRotationOffset, 24 * delta)

			if weaponOwner.attachedCam:
				weaponOwner.attachedCam.camRecoil = weaponRecoil

			if weaponAnimSet:
				if !weaponOwner == null:
					if useWeaponSprintAnim:
							if weaponOwner.isRunning:
								if !weaponRemoteState.get_current_node() == "sprint":
									weaponRemoteState.travel("sprint")

				if !isFiring and !isAiming and !weaponOwner.freeAim:
					if !weaponRemoteState.get_current_node() == "idle":
						weaponRemoteState.travel("idle")
						if useLeftHandIdle:
							useLeftHand = true
						else:
							useLeftHand = false
						if useRightHandIdle:
							useRightHand = true
						else:
							useRightHand = false
				if isAiming:
					if useLeftHandAiming:
						useLeftHand = true
					else:
						useLeftHand = false
					if useRightHandAiming:
						useRightHand = true
					else:
						useRightHand = false



					if !weaponOwner.meshLookAt:
						weaponOwner.meshLookAt = true
					if !weaponRemoteState.get_current_node() == "aim":
						weaponRemoteState.travel("aim")
				if weaponOwner.freeAim:
					if !weaponRemoteState.get_current_node() == "aim":
						if useLeftHandFreeAiming:
							useLeftHand = true
						else:
							useLeftHand = false
						if useRightHandFreeAiming:
							useRightHand = true
						else:
							useRightHand = false
						weaponRemoteState.travel("aim")

			collisionEnabled = false

		if collisionEnabled:
			collisionObject.disabled = false
		else:
			collisionObject.disabled = true


func fire():
	if !isFiring:
		if isAiming:
			if weaponOwner.attachedCam:
					weaponOwner.attachedCam.camRecoilStrength = weaponRecoilStrengthAim
					weaponOwner.attachedCam.applyWeaponSpread(weaponSpreadAim)
		else:
			if weaponOwner.attachedCam:
				weaponOwner.attachedCam.camRecoilStrength = weaponRecoilStrength
				weaponOwner.attachedCam.applyWeaponSpread(weaponSpread)

		shot_fired.emit()
		if weaponRemoteState:
			weaponRemoteState.start("fire")
		if weaponOwner.attachedCam:
			weaponOwner.attachedCam.fireRecoil()
		isFiring = true
		#Bullet Creation/Raycast Bullet Creation
		for bullet in weaponShots:
			bullet = createMuzzle()
			if weaponShots > 1:
				bullet.position.x += randf_range(-0.09,0.09)
				bullet.position.y += randf_range(-0.05,0.05)
			if checkShooter():
				if weaponOwner.attachedCam.camCast.is_colliding():
					raycastHit()
					var pt = globalParticles.createParticle(globalParticles.detectMaterial(getHitObject()), getRayColPoint())
					if !pt == null:
						pt.look_at(getRayColPoint() + getRayNormal())
			else:
				if weaponCast.is_colliding():
					raycastHit(weaponCast)
					var pt = globalParticles.createParticle(globalParticles.detectMaterial(getHitObject(weaponCast)), getRayColPoint(weaponCast))
					if !pt == null:
						pt.look_at(getRayColPoint(weaponCast) + getRayNormal(weaponCast))


		await get_tree().create_timer(weaponFireRate).timeout
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
		if colliding.is_in_group("Flesh"):
			var spurtChance = randi_range(0,1)
			globalParticles.spawnBulletHole("Flesh",colliding,hitPoint,randf_range(0, 2),hitNormal)
			if spurtChance == 1:
				var bloodStream = globalParticles.createParticle("BloodStream",hitPoint,Vector3.ZERO,colliding)
				bloodStream.look_at(hitPoint+hitNormal/2)
		else:
			globalParticles.spawnBulletHole("default",colliding,hitPoint,randf_range(0, 2),hitNormal)

		if colliding.has_method("hit"):
			colliding.hit(weaponDamage,weaponOwner,global_position.direction_to(hitPoint).normalized() * randf_range(1,weaponImpulse),to_global(to_local(hitPoint)-position))

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
	weaponAnimSet = false
	weaponOwner = null
	isFiring = false
	isAiming = false
	isEquipped = false

