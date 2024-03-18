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
	if hitImpulse:
		var splatterState = get_world_3d().direct_space_state
		var splatterParams = PhysicsRayQueryParameters3D.new()
		splatterParams.from = hitPoint
		splatterParams.to = self.position
		splatterState.intersect_ray(splatterParams)
	emit_signal("damaged",dmg,hitImpulse,hitPoint)
	healthComponent.damage(dmg * hitboxDamageMult, dealer)
	healthComponent.componentOwner.lastHitPart = boneId
	healthComponent.componentOwner.hitImpulse = hitImpulse
	healthComponent.componentOwner.hitVector = hitPoint

	if dealer:
		if dealer.attachedCam:
			dealer.attachedCam.hud.getCrosshair().tintCrosshair(Color.RED)
			dealer.attachedCam.hud.getCrosshair().addTilt(randf_range(-1,1))
			dealer.attachedCam.camera.fov += 1.5

	if healthComponent.componentOwner:
		if healthComponent.componentOwner.attachedCam:
			healthComponent.componentOwner.attachedCam.camera.fov -= randf_range(1.8,4.8)
			healthComponent.componentOwner.attachedCam.fireRecoil(randf_range(8,14),randf_range(1,4),randf_range(9,13),true)
			healthComponent.componentOwner.attachedCam.fireVignette(1.2,Color.RED)
			Dialogic.end_timeline()

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
