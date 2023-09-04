extends Area3D
class_name Hitbox
var setup = false
@export_category("Hitbox")
@export var healthComponent : HealthComponent
@export var hitboxDamageMult = 1.0
var boneId
# Called when the node enters the scene tree for the first time.
func _ready():

	if !get_parent() == null:
		if get_parent() is BoneAttachment3D:
			boneId = get_parent().get_bone_idx()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if healthComponent:
		if !setup:
			addException()
			setup = true

	if healthComponent.isDead:
		queue_free()

func hit(dmg, dealer=null, hitImpulse:Vector3 = Vector3.ZERO, hitPoint:Vector3 = Vector3.ZERO):
	healthComponent.damage(dmg * hitboxDamageMult, dealer)
	healthComponent.componentOwner.lastHitPart = boneId
	healthComponent.componentOwner.hitImpulse = hitImpulse
	healthComponent.componentOwner.hitVector = hitPoint


func getCollisionObject():
	if get_child(0) is CollisionObject3D:
		return get_child(0)
	else:
		return null

func addException():
	if healthComponent.componentOwner:
		if healthComponent.componentOwner.attachedCam:
			healthComponent.componentOwner.attachedCam.camCast.add_exception(self)
