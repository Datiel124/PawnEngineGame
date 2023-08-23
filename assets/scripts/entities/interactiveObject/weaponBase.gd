extends InteractiveObject
class_name Weapon

@onready var weaponMesh = $Mesh
@onready var collisionObject = $collisionObject
@onready var animationTree = $AnimationTree
@onready var animationPlayer = $AnimationPlayer

var weaponState
var weaponRemoteState
var weaponAnimSet = false
var weaponOwner = null
@export_category("Weapon")
@export_subgroup("Behavior")
@export var muzzlePoint : Marker3D
@export var collisionEnabled = true
@export var isEquipped : bool = false
@export var isFiring = false
@export var isAiming = false
@export var isBusy = false
@export_subgroup("Stats")
@export var weaponDamage = 5.0
@export var weaponFireRate = 0.4
@export var weaponImpulse = 5.0
@export_subgroup("Recoil")
@export var weaponRecoil : Vector3 = Vector3(5 ,1 , 0.25)
@export var weaponRecoilStrength : float = 8.0
@export var weaponSpread = 0.25
@export_subgroup("Aiming Recoil")
@export var weaponRecoilStrengthAim : float = 4.0
@export var weaponSpreadAim = 0.25
@export_subgroup("Weapon Animations")
@export var useLeftHand = false
@export var useRightHand = true
@export var leftHandParent = false
@export var rightHandParent = true
@export var useWeaponSprintAnim = false
@export_subgroup("Weapon Orientation")
@export var itemRot = Vector3.ZERO
@export var itemPos = Vector3.ZERO
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
	if isEquipped:
		set("gravity_scale", 0)
		#Weapon Orientation
		weaponMesh.position = lerp(weaponMesh.position, weaponPositionOffset, 24 * delta)
		weaponMesh.rotation = lerp(weaponMesh.rotation, weaponRotationOffset, 24 * delta)
		if weaponAnimSet:
			if !weaponOwner == null:
				if useWeaponSprintAnim:
						if weaponOwner.isRunning:
							if !weaponRemoteState.get_current_node() == "sprint":
								weaponRemoteState.travel("sprint")

			if !isFiring and !isAiming:
				if !weaponRemoteState.get_current_node() == "idle":
					weaponRemoteState.travel("idle")
			if isAiming:
				if !weaponOwner.meshLookAt:
					weaponOwner.meshLookAt = true
				if !weaponRemoteState.get_current_node() == "aim":
					weaponRemoteState.travel("aim")



		collisionEnabled = false

	if collisionEnabled:
		collisionObject.disabled = false
	else:
		collisionObject.disabled = true


func fire():
	if !isFiring:
		isFiring = true
		shot_fired.emit()
		weaponRemoteState.start("fire")
		if weaponOwner.attachedCam:
			weaponOwner.attachedCam.camRecoil = weaponRecoil
			if isAiming:
				weaponOwner.attachedCam.camRecoilStrength = weaponRecoilStrengthAim
				weaponOwner.attachedCam.applyWeaponSpread(weaponSpreadAim)
			else:
				weaponOwner.attachedCam.camRecoilStrength = weaponRecoilStrength
				weaponOwner.attachedCam.applyWeaponSpread(weaponSpread)
			weaponOwner.attachedCam.fireRecoil()
			createMuzzle()

		#Bullet Creation/Raycast Bullet Creation
		if checkShooter():
			if weaponOwner.attachedCam.camCast.is_colliding():
				raycastHit()

		await get_tree().create_timer(weaponFireRate).timeout
		isFiring = false


func createMuzzle():
	if !muzzlePoint == null:
		pass
	else:
		print_rich("[color=red]This weapon doesn't have a muzzle point! Add one now fucker.[/color]")

func unequip():
	pass

func checkShooter():
	if weaponOwner.attachedCam:
		return true
	else:
		return false

func raycastHit():
		var colliding
		var hitPoint
		var hitNormal
		var raycast : RayCast3D = weaponOwner.attachedCam.camCast
		colliding = raycast.get_collider()
		hitPoint = raycast.get_collision_point()
		hitNormal = raycast.get_collision_normal()
		if colliding.has_method("hit"):
			colliding.hit(weaponDamage,weaponOwner,weaponImpulse,hitPoint)

