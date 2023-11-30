extends Node3D
class_name PawnRagdoll

##Pawn Parts
@onready var head = $Mesh/Male/MaleSkeleton/Skeleton3D/MaleHead
@onready var upperChest = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_UpperBody
@onready var shoulders = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_Shoulders
@onready var leftUpperArm = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_LeftArm
@onready var rightUpperArm = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_RightArm
@onready var leftForearm = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_LeftForearm
@onready var rightForearm = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_RightForearm
@onready var lowerBody = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_LowerBody
@onready var leftUpperLeg = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_LeftThigh
@onready var rightUpperLeg = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_RightThigh
@onready var leftLowerLeg = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_LeftKnee
@onready var rightLowerLeg = $Mesh/Male/MaleSkeleton/Skeleton3D/Male_RightKnee

@onready var clothingHolder = $Mesh/Male/MaleSkeleton/Skeleton3D/Clothing
@onready var ragdollSkeleton = $Mesh/Male/MaleSkeleton/Skeleton3D
@onready var ragdollMesh = $Mesh
@onready var soundQueue : SoundQueue = $"Mesh/Male/MaleSkeleton/Skeleton3D/Physical Bone Neck/SoundQueue"
var physicsBones : Array[PhysicalBone3D]
@export_category("Ragdoll")
@export_subgroup("Active Ragdoll")
var targetSkeleton : Skeleton3D
@export var activeRagdollEnabled = false
@export var linearSpringStiffness: float = 1200.0
@export var linearSpringDamping: float = 40.0
@export var maxLinearForce: float = 9999.0

@export var angularSpringStiffness: float = 4000.0
@export var angularSpringDamping: float = 80.0
@export var maxAngularForce: float = 9999.0
@export_subgroup("Behavior")
##Start simulation on create
@export var canTwitch = true
@export var healthComponent : HealthComponent
@export var startOnInstance = true
@export_subgroup("Camera Behavior")
##Root Follow Node
@export var rootCameraNode : Node3D
##Camera Data for a camera to follow
@export var pawnCameraData : CameraData
##If a camera were to be attached to this node, it would follow this.
@export var followNode : Node3D
##The current attached camera (if there is one)
signal cameraAttached
@export var attachedCam : CharacterBody3D:
	set(value):
		attachedCam = value
		emit_signal("cameraAttached")
	get:
		return attachedCam
# Called when the node enters the scene tree for the first time.
func _ready():
	for bones in ragdollSkeleton.get_children().filter(func(x): return x is PhysicalBone3D):
		physicsBones.append(bones)
	for pb in physicsBones:
		if pb.get_script() != null:
			for b in physicsBones:
				pb.exclusionArray.append(RID(b))

	soundQueue.playSound()
	if startOnInstance:
		ragdollSkeleton.physical_bones_start_simulation()

	checkClothingHider()

func _physics_process(delta):
	if activeRagdollEnabled:
		if !targetSkeleton == null:
			for b in physicsBones:
				if !b.get_bone_id() == 0 or !b.get_bone_id() == 1 or !b.get_bone_id() == 2 or !b.get_bone_id() == 41 or !b.get_bone_id() == 42:
					var target_transform: Transform3D = targetSkeleton.global_transform * targetSkeleton.get_bone_global_pose(b.get_bone_id())
					var current_transform: Transform3D = ragdollSkeleton.global_transform * ragdollSkeleton.get_bone_global_pose(b.get_bone_id())
					var rotation_difference: Basis = (target_transform.basis * current_transform.basis.inverse())

					var position_difference:Vector3 = target_transform.origin - current_transform.origin

					if position_difference.length_squared() > 1.0:
						b.global_position = target_transform.origin
					else:
						var force: Vector3 = hookes_law(position_difference, b.linear_velocity, linearSpringStiffness, linearSpringDamping)
						force = force.limit_length(maxLinearForce)
						b.linear_velocity += (force * delta)

					var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, angularSpringStiffness, angularSpringDamping)
					torque = torque.limit_length(maxAngularForce)
					b.angular_velocity += torque * delta
					print(b.get_bone_id())

	if canTwitch:
		pass

func startRagdoll():
	ragdollSkeleton.physical_bones_start_simulation()
	checkClothingHider()

func ragTwitch(convulsionAmount : float = 10.0, bodyPartIDX : int = 0):
	pass

func checkClothingHider():
	for clothes in self.get_children():
		if clothes is ClothingItem:
			if clothes.head:
				head.hide()
			if clothes.rightUpperarm:
				rightUpperArm.hide()
			if clothes.leftUpperarm:
				leftUpperArm.hide()
			if clothes.shoulders:
				shoulders.hide()
			if clothes.leftForearm:
				leftForearm.hide()
			if clothes.rightForearm:
				rightForearm.hide()
			if clothes.upperChest:
				upperChest.hide()
			if clothes.lowerBody:
				lowerBody.hide()
			if clothes.leftUpperLeg:
				leftUpperLeg.hide()
			if clothes.rightUpperLeg:
				rightUpperLeg.hide()
			if clothes.rightLowerLeg:
				rightLowerLeg.hide()
			if clothes.leftLowerLeg:
				leftLowerLeg.hide()

func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)
