extends Node3D
class_name AIComponent
signal interactSpeakTrigger

@onready var aimCast = $aiAimcast
@onready var aimCastEnd = $aiAimcast/aiAimcastEnd
@onready var pawnDebugLabel = $debugPawnStats
@onready var immediateMesh = $pawnGrabber/meshInstance3d
@onready var visionCast = $pawnGrabber/rayCast3d
@onready var detectionShape = $pawnGrabber/collisionShape3d
@export_category("AI Component")
@export var pawnOwner : BasePawn
@export var aiTree : BTPlayer
@export_category("Interaction")
@export_enum("Dialogue") var interactType = 0
@export var isInteractable : bool = false
@export_category("Dialogue")
@export var dialogueStartingCamera : Marker3D
@export var dialogueString : String
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
@onready var pawnGrabber : Area3D = $pawnGrabber
@export_subgroup("Overlap")
@export var pawnHasTarget : bool = false
@export var overlappingObject : Node
@export var overlappingObjectPosition : Vector3
@export_subgroup("Detection")
@export var hatedPawnGroups : Array[StringName]
@export var detectionRadius = 10.0
@export var detectionAngle = 90.0
@export var aimSpeed = 9.0
var lastDirection : Vector3
var lookDirection
var pawnPosition
var debugDist

func _ready():
	var losDraw = ImmediateMesh.new()
	immediateMesh.mesh = losDraw
	visionTimer.start()
	await get_tree().process_frame
	if isInteractable:
		setInteractablePawn(true)

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
		detectionShape.shape.radius = lerpf(detectionShape.shape.radius,detectionRadius,12*delta)
		pawnOwner.turnAmount = -aimCast.rotation.x
		aimCast.position = lerp(aimCast.position,visionCast.position,aimSpeed*delta)
		aimCast.rotation = lerp(aimCast.rotation,visionCast.rotation,aimSpeed*delta)

		if pawnHasTarget:
			if !overlappingObject == null:
				if overlappingObject is BasePawn:
					overlappingObjectPosition = overlappingObject.chestBone.global_position
				visionCast.look_at(overlappingObjectPosition)

				# LOS Debug
				if globalGameManager.pawnDebug:
					debugDist = self.global_position.direction_to(overlappingObject.global_position)
					immediateMesh.show()
					immediateMesh.mesh.clear_surfaces()
					immediateMesh.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
					immediateMesh.mesh.surface_add_vertex(self.position)
					immediateMesh.mesh.surface_add_vertex(debugDist)
					immediateMesh.mesh.surface_end()

		if aiTree.blackboard.get_var("pawnDetection") >= 90:
			aiTree.blackboard.set_var("hasDetectedPawn", true)
			aiTree.blackboard.set_var("isAttacking", true)
		elif aiTree.blackboard.get_var("pawnDetection") < 90:
			aiTree.blackboard.set_var("hasDetectedPawn", false)
			aiTree.blackboard.set_var("isAttacking", false)

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
		"%[pawnName,aiType,aiTree.blackboard.get_var("pawnDetection"),aiTree.blackboard.get_var("hasTarget"),aiTree.blackboard.get_var("hasDetectedPawn")]
		pawnDebugLabel.position.x = pawnOwner.head.position.x
		pawnDebugLabel.position.y = pawnOwner.head.position.y * 200
		pawnDebugLabel.visible = true
	else:
		pawnDebugLabel.visible = false

	if pawnOwner:
		pawnPosition = pawnOwner.pawnMesh.position
func _on_vision_timer_timeout():
	#lookForPawn()
	pass

func lookForPawn():
	if pawnGrabber.get_overlapping_bodies().size()-1 >=1:
		for pawn in pawnGrabber.get_overlapping_bodies():
			for groups in hatedPawnGroups.size()-1:
				if pawn.is_in_group(hatedPawnGroups[groups]):
					var posVect = self.position
					var pawnVect = pawn.global_position
					var dist = self.global_position.direction_to(pawnVect)
					var dotProd = dist.dot(-pawnOwner.pawnMesh.global_transform.basis.z)
					if dotProd > 0:
						overlappingObject = pawn
						pawnHasTarget = true
						if aiTree != null:
							aiTree.blackboard.set_var("hasTarget",true)
							aiTree.blackboard.set_var("visionCastRotation",visionCast.rotation)
							aiTree.blackboard.set_var("pawnTarget",overlappingObject)
							aiTree.blackboard.set_var("pawnTargetPos",overlappingObjectPosition)
					else:
						undetectPawn()
				else:
					undetectPawn()
	else:
		undetectPawn()

func ceaseAI():
	navAgent.queue_free()
	aiTree.queue_free()

func setupBlackboardObjects():
	var bbplan = load("res://assets/components/aiComponent/aiPlan.tres").duplicate()
	var btree = aiTree.behavior_tree.duplicate()
	var naver = navAgent.duplicate()
	var dupshape = detectionShape.shape.duplicate()
	detectionShape.shape = dupshape
	aiTree.blackboard_plan = bbplan
	aiTree.behavior_tree = btree
	aiTree.blackboard.set_var("navPointGrabber",navPointGrabber)
	aiTree.blackboard.set_var("moveToObject",moveTo)
	aiTree.blackboard.set_var("navAgent",navAgent)
	aiTree.blackboard.set_var("visionCast",visionCast)
	aiTree.blackboard.set_var("pawnOwner",pawnOwner)
	aiTree.blackboard.set_var("aimCast",aimCast)
	aiTree.blackboard.set_var("aimCastEnd",aimCastEnd)
	aimCast.add_exception(pawnOwner)
	#aimCast.add_exception(pawnOwner.getAllHitboxes().get_children())

func undetectPawn():
	if aiTree != null:
		aiTree.blackboard.set_var("hasTarget",false)
		aiTree.blackboard.set_var("hasDetectedPawn",false)
		aiTree.blackboard.set_var("pawnTarget",null)
		aiTree.blackboard.set_var("isAttacking",false)
		aiTree.blackboard.set_var("pawnTargetPos",Vector3.ZERO)
	pawnHasTarget = false
	overlappingObject = null
	overlappingObjectPosition = Vector3.ZERO
	immediateMesh.hide()

func addRaycastException(object):
	aimCast.add_exception(object)
	$pawnGrabber/rayCast3d.add_exception(object)

func instantDetect(pawn:BasePawn):
		if pawn:
			overlappingObject = pawn
			overlappingObjectPosition = pawn.chestBone.global_position
			visionCast.look_at(overlappingObjectPosition)
		aiTree.blackboard.set_var("hasTarget",true)
		aiTree.blackboard.set_var("hasDetectedPawn",true)
		aiTree.blackboard.set_var("pawnTarget",pawn)
		aiTree.blackboard.set_var("pawnDetection",100.0)
		aiTree.blackboard.set_var("visionCastRotation",visionCast.rotation)
		aiTree.blackboard.set_var("pawnTarget",pawn)
		aiTree.blackboard.set_var("pawnTargetPos",overlappingObjectPosition)
		aiTree.blackboard.set_var("isAttacking",true)

func _on_pawn_grabber_area_entered(area):
	lookForPawn()

func _on_pawn_grabber_body_entered(body):
	lookForPawn()

func _on_pawn_grabber_body_exited(body):
	if pawnHasTarget:
		if body == overlappingObject:
			undetectPawn()


func speakTrigger(dialogue):
	if pawnOwner:
		if !pawnOwner.isPawnDead:
			if dialogue != "":
				if Dialogic.current_timeline != null:
					return
				Dialogic.start(dialogue)
				if dialogueStartingCamera != null:
					var dialogue_cam : Node3D = globalGameManager.create_dialogue_camera()
					globalGameManager.world.add_child(dialogue_cam)
					dialogue_cam.activate(get_viewport().get_camera_3d(), dialogueStartingCamera.position,dialogueStartingCamera.rotation)
					Dialogic.timeline_ended.connect(dialogue_cam.remove)
				get_viewport().set_input_as_handled()

func setInteractablePawn(value:bool = false):
	if value == true:
		if pawnOwner:
			pawnOwner.add_to_group("Interactable")
			interactSpeakTrigger.connect(speakTrigger.bind(dialogueString))
	else:
		if pawnOwner:
			pawnOwner.remove_from_group("Interactable")
			interactSpeakTrigger.disconnect(speakTrigger)
