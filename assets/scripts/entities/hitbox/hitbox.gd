extends Area3D
class_name Hitbox
var setup = false
signal damaged(amount,impulse,vector)
@export_category("Hitbox")
@export var healthComponent : HealthComponent
@export var hitboxDamageMult = 1.0
var boneId
# Called when the node enters the scene tree for the first time.
func _ready():
	healthComponent.componentOwner.hitboxes.append(self)
	if !get_parent() == null:
		if get_parent() is BoneAttachment3D:
			boneId = get_parent().get_bone_idx()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if healthComponent:
		if !setup:
			addException(self)
			setup = true

	if healthComponent.isDead:
		queue_free()

func hit(dmg, dealer=null, hitImpulse:Vector3 = Vector3.ZERO, hitPoint:Vector3 = Vector3.ZERO):
	emit_signal("damaged",dmg,hitImpulse,hitPoint)
	healthComponent.damage(dmg * hitboxDamageMult, dealer)
	healthComponent.componentOwner.lastHitPart = boneId
	healthComponent.componentOwner.hitImpulse = hitImpulse
	healthComponent.componentOwner.hitVector = hitPoint

	if dealer:
		if dealer.attachedCam:
			dealer.attachedCam.hud.getCrosshair().tintCrosshair(Color.LIGHT_CORAL)
			dealer.attachedCam.hud.getCrosshair().addTilt(randf_range(-1,1))
			dealer.attachedCam.camera.fov += 1.1

	if healthComponent.componentOwner:
		if healthComponent.componentOwner.attachedCam:
			healthComponent.componentOwner.attachedCam.fireRecoil(0,randf_range(1,4),randf_range(9,13))
			healthComponent.componentOwner.attachedCam.fireVignette(1.2)

func getCollisionObject():
	if get_child(0) is CollisionObject3D:
		return get_child(0)
	else:
		return null

func addException(exception):
	if healthComponent.componentOwner:
		if healthComponent.componentOwner.attachedCam:
			healthComponent.componentOwner.attachedCam.camCast.add_exception(exception)
		else:
			if healthComponent.componentOwner.raycaster:
				healthComponent.componentOwner.raycaster.add_exception(exception)
