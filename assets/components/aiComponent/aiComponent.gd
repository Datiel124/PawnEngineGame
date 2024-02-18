extends Node3D
class_name AIComponent
@onready var pawnDebugLabel = $debugPawnStats
@onready var immediateMesh = $pawnGrabber/meshInstance3d
@onready var visionCast = $pawnGrabber/rayCast3d
@export_category("AI Component")
@export var pawnOwner : BasePawn
@export var aiTree : BTPlayer
@export_subgroup("Identification")
@export var pawnName : String
@export_enum("Idle","Wander","Patrol") var aiType = 0
@export_enum("Friendly","Neutral","Hostile","Vendor") var aiMindState = 1
@export var availableStates : Array
@export_subgroup("Nodes")
@export var moveTo : Marker3D
@export var navAgent : NavigationAgent3D
@export var navPointGrabber : Area3D
@export var visionTimer : Timer
@export var pawnGrabber : Area3D
@export_subgroup("Overlap")
@export var pawnHasTarget : bool = false
@export var overlappingObject : Node
@export var overlappingObjectPosition : Vector3
@export_subgroup("Detection")
@export var hatedPawnGroups : Array[StringName]
@export var detectionRange = 10.0
@export var detectionAngle = 90.0
var lastDirection : Vector3
var lookDirection
var pawnPosition

func _ready():
	var losDraw = ImmediateMesh.new()
	immediateMesh.mesh = losDraw
	visionTimer.start()
	await get_tree().process_frame
	if immediateMesh.get_material_override():
		var losDrawMat = immediateMesh.get_material_override().duplicate()
		immediateMesh.set_material_override(losDrawMat)
	aiTree.blackboard.set_var("pawnType",aiType)
	if aiTree:
		setupBlackboardObjects()
	if pawnOwner:
		pawnOwner.healthComponent.healthDepleted.connect(ceaseAI)



func _process(delta):
	if aiTree != null:
		if aiTree.blackboard.get_var("pawnDetection") >= 90:
			aiTree.blackboard.set_var("hasDetectedPawn", true)
		elif aiTree.blackboard.get_var("pawnDetection") < 90:
			aiTree.blackboard.set_var("hasDetectedPawn", false)

		if aiTree.blackboard.get_var("hasTarget"):
			aiTree.blackboard.set_var("pawnDetection",lerpf(aiTree.blackboard.get_var("pawnDetection"),100,delta*aiTree.blackboard.get_var("pawnDetectionRate")))
		else:
			aiTree.blackboard.set_var("pawnDetection",lerpf(aiTree.blackboard.get_var("pawnDetection"),0,delta*aiTree.blackboard.get_var("pawnDetectionRate")))

	if globalGameManager.pawnDebug and aiTree != null:
		pawnDebugLabel.offset.y = 450
		pawnDebugLabel.text = "Pawn Name - %s\n
		Pawn Type - %s\n
		Pawn Detection Amount - %s\n
		Has Target - %s\n
		Has Detected - %s\n
		"%[pawnOwner.name,aiType,aiTree.blackboard.get_var("pawnDetection"),aiTree.blackboard.get_var("hasTarget"),aiTree.blackboard.get_var("hasDetectedPawn")]
		pawnDebugLabel.position.x = pawnOwner.head.position.x
		pawnDebugLabel.position.y = pawnOwner.head.position.y * 200
		pawnDebugLabel.visible = true
	else:
		pawnDebugLabel.visible = false

	if pawnOwner:
		pawnPosition = pawnOwner.pawnMesh.position
func _on_vision_timer_timeout():
	lookForPawn()

func lookForPawn():
	if pawnGrabber.get_overlapping_bodies().size() >=1:
		for pawn in pawnGrabber.get_overlapping_bodies():
			for groups in hatedPawnGroups.size()-1:
				if pawn.is_in_group(hatedPawnGroups[groups]):
					var posVect = self.position
					var pawnVect = pawn.global_position
					var dist = self.global_position.direction_to(pawnVect)
					var dotProd = dist.dot(-pawnOwner.pawnMesh.global_transform.basis.z)
					if dotProd > 0:
						pawnHasTarget = true
						overlappingObject = pawn
						overlappingObjectPosition = pawn.position
						visionCast.look_at(overlappingObjectPosition)
						if aiTree != null:
							aiTree.blackboard.set_var("hasTarget",true)
							aiTree.blackboard.set_var("pawnTarget",overlappingObject)
							aiTree.blackboard.set_var("pawnTargetPos",overlappingObjectPosition)
					# LOS Debug
						if globalGameManager.pawnDebug:
								immediateMesh.show()
								immediateMesh.mesh.clear_surfaces()
								immediateMesh.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
								immediateMesh.mesh.surface_add_vertex(self.position)
								immediateMesh.mesh.surface_add_vertex(dist)
								immediateMesh.mesh.surface_end()
					else:
						undetectPawn()
				else:
					undetectPawn()

func ceaseAI():
	navAgent.queue_free()
	aiTree.queue_free()

func setupBlackboardObjects():
	var bbplan = load("res://assets/components/aiComponent/aiPlan.tres").duplicate()
	aiTree.blackboard_plan = bbplan
	aiTree.blackboard.set_var("navPointGrabber",navPointGrabber)
	aiTree.blackboard.set_var("moveToObject",moveTo)
	aiTree.blackboard.set_var("navAgent",navAgent)
	aiTree.blackboard.set_var("pawnOwner",pawnOwner)

func undetectPawn():
	if aiTree != null:
		aiTree.blackboard.set_var("hasTarget",false)
		aiTree.blackboard.set_var("hasDetectedPawn",false)
		aiTree.blackboard.set_var("pawnTarget",null)
		aiTree.blackboard.set_var("pawnTargetPos",Vector3.ZERO)
	pawnHasTarget = false
	overlappingObject = null
	overlappingObjectPosition = Vector3.ZERO
	immediateMesh.hide()
