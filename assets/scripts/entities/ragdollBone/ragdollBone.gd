extends PhysicalBone3D
class_name RagdollBone
@export_category("Ragdoll Bone")
@export_subgroup("Collision Information")
@export var collisionSound : AudioStream
@export_subgroup("Information")
@export var currentVelocity : Vector3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	currentVelocity = state.get_linear_velocity()


func hit(dmg, dealer=null, hitImpulse:Vector3 = Vector3.ZERO, hitPoint:Vector3 = Vector3.ZERO):
	apply_impulse(hitImpulse, hitPoint)
