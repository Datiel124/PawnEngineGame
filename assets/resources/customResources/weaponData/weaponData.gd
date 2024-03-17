extends Resource
class_name ItemData

@export_category("Weapon")
@export_subgroup("Behavior")
var defaultBulletTrail = load("res://assets/entities/bulletTrail/bulletTrail.tscn")
@export_subgroup("Stats")
## Can this weapon explode heads?
@export var headDismember = false
## How much damage does the weapon do?
@export var weaponDamage = 5.0
## How fast does the weapon fire?
@export var weaponFireRate = 0.4
## Determines how much impulse is applied towards physics objects.
@export var weaponImpulse = 5.0
## How many bullets are shot out? Useful for shotguns. Default is 1.
@export var weaponShots = 1
## What crosshair should the weapon force?
@export_subgroup("Crosshair")
@export var useCustomCrosshairSize = false
@export var crosshairSizeOverride : Vector2 = Vector2(0.8,0.8)
@export var forcedCrosshair : Texture2D
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
@export_subgroup("Misc")
@export var bulletColor : Color = Color(255,255,0,255)
