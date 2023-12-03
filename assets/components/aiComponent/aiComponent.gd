extends Node3D
class_name AIComponent
@export_category("AI Component")
@export var pawnOwner : BasePawn
@export_subgroup("Identification")
@export var pawnName : String
@export_enum("Default","Vendor","Patrol") var aiType = 0
@export_enum("Friendly","Neutral","Hostile") var aiMindState = 1
@export var availableStates : Array
@export_subgroup("State Machine")
@export var stateMachine : StateMachine
@export_subgroup("Nodes")
@export var moveTo : Marker3D
@export var navAgent : NavigationAgent3D
@export var navPointGrabber : Area3D
@export var visionTimer : Timer
@export var coneOfVision : Area3D
@export_subgroup("Overlap")
@export var pawnHasTarget : bool = false
@export var overlappingObject : Node
@export var overlappingObjectPosition : Vector3

var visionOverlaps
func _ready():

	#Get all states in state machine and add them to the available states array
	getStates()
	visionTimer.start()


func getStates():
	for state in stateMachine.get_children():
		availableStates.append(state)

	return availableStates

func _process(delta):
	if globalGameManager.visionConesEnabled:
		if !$lineOfSight/visionCol/viewCone.visible:
			$lineOfSight/visionCol/viewCone.show()
	else:
		$lineOfSight/visionCol/viewCone.hide()

	if pawnOwner:
		coneOfVision.global_transform.origin = pawnOwner.neckBone.global_transform.origin
		if !pawnHasTarget:
			coneOfVision.rotation = pawnOwner.pawnMesh.rotation
		else:
			coneOfVision.look_at(overlappingObjectPosition,Vector3.UP)

func _on_vision_timer_timeout():
	visionOverlaps = coneOfVision.get_overlapping_bodies()
	if visionOverlaps.size()-1 > 0:
		for overlappingPawn in visionOverlaps:
			if overlappingPawn != pawnOwner:
				if overlappingPawn.is_in_group("Pawn"):
					pawnHasTarget = true
					overlappingObject = overlappingPawn
					overlappingObjectPosition = overlappingPawn.global_transform.origin
					$lineOfSight/visionCol/viewCone.material_override.albedo_color = Color("00950160")

				else:
					overlappingObject = null
					overlappingObjectPosition = Vector3.ZERO
					$lineOfSight/visionCol/viewCone.material_override.albedo_color = Color("dc2c1f60")
					pawnHasTarget = false
	else:
		overlappingObject = null
		overlappingObjectPosition = Vector3.ZERO
		$lineOfSight/visionCol/viewCone.material_override.albedo_color = Color("dc2c1f60")
		pawnHasTarget = false
