extends Area3D
class_name Hitbox
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
func _process(delta):
	pass
func hit(dmg, dealer=null, hitImpulse:float = 0, hitPoint:Vector3 = Vector3.ZERO):
	healthComponent.damage(dmg * hitboxDamageMult, dealer)
	healthComponent.componentOwner.lastHitPart = boneId
	healthComponent.componentOwner.hitImpulse = hitImpulse
	healthComponent.componentOwner.hitVector = hitPoint
