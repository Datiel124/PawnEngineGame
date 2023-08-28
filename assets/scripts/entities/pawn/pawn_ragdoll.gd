extends Node3D

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
@export_category("Ragdoll")
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
	soundQueue.playSound()
	
	if startOnInstance:
		ragdollSkeleton.physical_bones_start_simulation()
	
	checkClothingHider()

func _physics_process(delta):
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
