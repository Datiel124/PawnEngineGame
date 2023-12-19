extends Node3D
class_name AIComponent
@export_category("AI Component")
@export var pawnOwner : BasePawn
@export_subgroup("Identification")
@export var pawnName : String
@export_enum("Default","Vendor","Patrol") var aiType = 0
@export_enum("Friendly","Neutral","Hostile") var aiMindState = 1
@export var availableStates : Array
@export var hatedPawns : Array
@export_subgroup("State Machine")
@export var stateMachine : StateMachine
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
@export var detectionRange = 10.0
@export var detectionAngle = 90.0
var lookatAngle
var visionOverlaps
var pawnPosition
var direction
func _ready():
	if globalGameManager.visionConesEnabled:
		var override = $lineOfSight/visionCol/viewCone.material_override.duplicate()
		$lineOfSight/visionCol/viewCone.material_override = override

	#Get all states in state machine and add them to the available states array
	getStates()
	visionTimer.start()


func getStates():
	for state in stateMachine.get_children():
		availableStates.append(state)

	return availableStates

func _process(delta):
	pawnPosition = pawnOwner.pawnMesh.position
	direction = pawnPosition

func _on_vision_timer_timeout():
	lookForPawn()

func lookForPawn():
	if pawnGrabber.get_overlapping_bodies().size()-1 >=1:
		for pawn in pawnGrabber.get_overlapping_bodies():
			var distanceToPawn : float = pawnOwner.position.distance_to(pawn.position)
			if distanceToPawn <= detectionRange:
				var angleTo = self.position.direction_to(pawn.position)
				var dotProd = self.rotation.dot(angleTo)
				Console.add_console_message("%s can see %s" %[pawnOwner,pawn])
				Console.add_console_message(str(dotProd))
