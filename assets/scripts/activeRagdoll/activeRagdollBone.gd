extends RigidBody3D
class_name ActiveRagdollBone
"""
	Active Ragdolls - Ragdoll Bone
		by Nemo Czanderlitch/Nino Čandrlić
			@R3X-G1L       (godot assets store)
			R3X-G1L6AME5H  (github)

	This is the script which transfers the rotation from the RigidBody
	to the Skeleton3D.
"""

@export var boneName : String
var boneIndex : int = -1

"""
	INIT
"""
func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
	else:
		assert(get_parent() is Skeleton3D, "The Ragdoll Bone[%s] is supposed to be a child of a Skeleton3D" % [self.name])
		assert(boneName != "", "The Ragdoll Bone[%s] needs to have its bone name defined" % [self.name])
		boneIndex = get_parent().find_bone(boneName)
		assert(boneIndex >= 0, "The Ragdoll Bone's[%s] bone name[%s] does not match any bone in the Skeleton3D" % [self.name, boneName])


"""
	APPLY OWN ROTATION TO THE RESPECTIVE BONE IN PARENT Skeleton3D
"""
func _physics_process(_delta: float) -> void:
	var bone_global_rotation : Basis = get_parent().global_transform.basis * get_parent().get_bone_global_pose(boneIndex).basis
	var b2t_rotation : Basis = bone_global_rotation.inverse() * self.transform.basis
	#get_parent().set_bone_pose_rotation(boneIndex,Quaternion(bone_global_rotation).normalized().inverse())
