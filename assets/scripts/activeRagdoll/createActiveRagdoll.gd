@tool
extends Skeleton3D

"""
	Active Ragdolls - Ragdoll Creator
		by Nemo Czanderlitch/Nino Čandrlić
			@R3X-G1L       (godot assets store)
			R3X-G1L6AME5H  (github)

	This is the script that reads through all the bones on a Skeleton and creates
	RigidBodies in their exact positions, with their exact rotations. This does
	not scale the bones. That part is left to the user.
"""

const ragdollBone = preload("res://assets/scripts/activeRagdoll/activeRagdollBone.gd")
const activeRagdollJoint = preload("res://assets/scripts/activeRagdoll/activeRagdollJoint.gd")

### Setting up the buttons
@export var createRagdoll : bool = false:
	set(value):
		_set_createRagdoll(value)
@export var createJoints : bool  = false:
	set(value):
		_set_createJoints(value)
@export var debugMeshes : bool  = false:
	set(value):
		_set_debugMeshes(value)

## The white list
@export var boneWhitelist : String = ""
var whitelist : PackedInt32Array = []

signal trace_animation_skeleton(value)


"""
	GOES THROUGH THE LIST OF BONES AND CREATES THE RIGIDBODIES
"""
func _set_createRagdoll(value):
	if value:
		## WHITELIST
		if boneWhitelist:
			whitelist.resize(0)  ## Clear whitelist
			if self._interpretwhitelist():  ## get a new whitelist
				for bone_id in whitelist:
					_add_ragdollBone(bone_id)

		## BLACKLIST
		else:
			for bone_id in range(self.get_bone_count()):
				_add_ragdollBone(bone_id)

"""
	CREATE THE RIGID BODIES FROM THE SKELETON
"""
func _add_ragdollBone( bone_id : int ):
	var BONE = ragdollBone.new()
	BONE.boneName = self.get_bone_name(bone_id)
	BONE.name = get_clean_bone_name(bone_id)
	BONE.transform = self.get_bone_global_pose(bone_id)

	## Create the collisions for the rigid bodies
	var collision := CollisionShape3D.new()
	collision.shape = CapsuleShape3D.new()
	collision.shape.radius = .1
	collision.shape.height = .1
	collision.rotate_x(PI/2)
	BONE.add_child(collision)

	self.add_child(BONE)

	## Magic runes that please our lord Godot
	BONE.set_owner(owner)
	collision.set_owner(owner)


"""
	CREATION OF ALL THE JOINTS INBETWEEN THE BONES
"""
func _set_createJoints(value):
	if value:
		## WHITELST
		if boneWhitelist:
			whitelist.resize(0)   ## Clear list
			if _interpretwhitelist():
				if whitelist.size() > 1:
					for bone_id in whitelist:
						_add_joint_for(bone_id)
				else:
					push_error("Too few bones whitelisted. Need at least two.")
		## BLACKLIST
		else:
			for bone_id in range(1, self.get_bone_count()):
				_add_joint_for(bone_id)

"""
	CREATES THE 6DOF JOINT ON THE SKELETON
"""
func _add_joint_for( bone_id : int ):
	### CHECK THAT THIS BONE ISN'T A ROOT BONE
	if get_bone_parent(bone_id) >= 0:
		### CHECK THAT BOTH BONES EXIST
		var node_a : ragdollBone = get_node_or_null(get_clean_bone_name(get_bone_parent(bone_id)))
		var node_b : ragdollBone = get_node_or_null(get_clean_bone_name(bone_id))
		if node_a and node_b:
			var JOINT := activeRagdollJoint.new()
			JOINT.transform = get_bone_global_pose(bone_id)
			JOINT.name = "JOINT_" + node_a.name + "_" + node_b.name

			JOINT.boneAIndex = find_bone(node_a.boneName)
			JOINT.boneBIndex = find_bone(node_b.boneName)

			add_child(JOINT)
			JOINT.set_owner(owner)

			JOINT.set("nodes/node_a", JOINT.get_path_to(node_a) )
			JOINT.set("nodes/node_b", JOINT.get_path_to(node_b) )

			## For enabling and disabling animation tracing
			trace_animation_skeleton.connect(JOINT.trace_skeleton)

"""
CREATION OF MESHES THAT ARE THE VISUAL REPRESENTATION OF BONES FOR DEBUG
	(FOR DEBUGGNG)
"""
func _set_debugMeshes( value ):
	debugMeshes = value
	if debugMeshes:
		for bone_id in range(self.get_bone_count()):
			var ragdollBone = get_node_or_null(get_clean_bone_name(bone_id))
			if ragdollBone: ## DOES BONE EXIST
				var collision = ragdollBone.get_node("CollisionShape3D")
				if collision: ## DOES IT HAVE A COLLISION
					if not collision.has_node("DEBUG_MESH"):
						## FIGURE OUT WHICH MESH SHOULD MASK THE COLLISION SHAPE
						if collision.shape is BoxShape3D:
							var box = MeshInstance3D.new()
							box.name = "DEBUG_MESH"   ## THIS NAME IS IMPORTANT IDENTIFIER FOR LATER DELETION
							box.mesh = BoxShape3D.new()
							box.mesh.size.x = collision.shape.extents.x * 2
							box.mesh.size.y = collision.shape.extents.y * 2
							box.mesh.size.z = collision.shape.extents.z * 2
							collision.add_child(box)
							box.set_owner(owner)
						elif collision.shape is CapsuleShape3D:
							var capsule := MeshInstance3D.new()
							capsule.name = "DEBUG_MESH"  ## THIS NAME IS IMPORTANT IDENTIFIER FOR LATER DELETION
							capsule.mesh = CapsuleMesh.new()
							capsule.mesh.radius = collision.shape.radius
							capsule.mesh.mid_height = collision.shape.height
							collision.add_child(capsule)
							capsule.set_owner(owner)
	else:
		for bone_id in range(self.get_bone_count()):
			var ragdollBone = get_node_or_null(get_clean_bone_name(bone_id))
			if ragdollBone:  ## DOES BONE EXIST
				var collision = ragdollBone.get_node("CollisionShape3D")
				if collision:   ## DOES COLLISON EXIST
					if collision.has_node("DEBUG_MESH"):
						collision.get_node("DEBUG_MESH").queue_free()


"""
PARSE THE BONE LIST(turns the string ranges into numbers and appends them to whitelist)
"""
func _interpretwhitelist() -> bool:
	var l = boneWhitelist.split(",")
	for _range in l:
		var num = _range.split("-")
		if num.size() == 1:
			whitelist.push_back(int(num[0]))
		elif num.size() == 2:
			for i in range(int(num[0]), int(num[1]) + 1):
				whitelist.push_back(i)
		elif num.size() > 2:
			push_error("Incorrect entry in blacklist")
			return false
	return true


"""
NAME THE RIGID BODIES APPROPRIATELY
"""
func get_clean_bone_name( bone_id : int ) -> String:
	return self.get_bone_name(bone_id).replace(".", "_")



"""
DISABLE JOINT CONSTRANTS, AND APPLY FORCES TO MATCH THE TARGET ROTATION
"""
func start_tracing():
	call_deferred("emit_signal", "trace_animation_skeleton", true)

"""
GO LIMP, AND APPLY ALL JOINT CONSTRAINTS
"""
func stop_tracing():
	call_deferred("emit_signal", "trace_animation_skeleton", false)
