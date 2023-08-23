extends Node3D
@onready var ragdollSkeleton = $Mesh/Male/MaleSkeleton/Skeleton3D
@onready var ragdollMesh = $Mesh
@onready var soundQueue : SoundQueue = $"Mesh/Male/MaleSkeleton/Skeleton3D/Physical Bone Neck/SoundQueue"
@export_category("Ragdoll")
@export_subgroup("Behavior")
##Start simulation on create
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startRagdoll():
	ragdollSkeleton.physical_bones_start_simulation()
	

