extends Node3D
class_name AIComponent
@onready var immediateMesh = $pawnGrabber/meshInstance3d
@onready var visionCast = $pawnGrabber/rayCast3d
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
var lastDirection : Vector3
var lookDirection
var pawnPosition
func _ready():
	var losDraw = ImmediateMesh.new()
	immediateMesh.mesh = losDraw
	#Get all states in state machine and add them to the available states array
	getStates()
	visionTimer.start()

	await get_tree().process_frame
	if immediateMesh.get_material_override():
		var losDrawMat = immediateMesh.get_material_override().duplicate()
		immediateMesh.set_material_override(losDrawMat)

	pawnOwner.healthComponent.healthDepleted.connect(navAgent.queue_free)


func getStates():
	for state in stateMachine.get_children():
		availableStates.append(state)

	return availableStates

func _process(delta):
	pawnPosition = pawnOwner.pawnMesh.position
func _on_vision_timer_timeout():
	lookForPawn()

func lookForPawn():
	if pawnGrabber.get_overlapping_bodies().size() >=1:
		for pawn in pawnGrabber.get_overlapping_bodies():
			var posVect = self.position
			var pawnVect = pawn.global_position
			var dist = self.global_position.direction_to(pawnVect)
			var dotProd = dist.dot(-pawnOwner.pawnMesh.global_transform.basis.z)
			if dotProd > 0:
				pawnHasTarget = true
				overlappingObject = pawn
				overlappingObjectPosition = pawn.position
				visionCast.look_at(overlappingObjectPosition)
			# LOS Debug
				if globalGameManager.visionConesEnabled:
						immediateMesh.show()
						immediateMesh.mesh.clear_surfaces()
						immediateMesh.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
						immediateMesh.mesh.surface_add_vertex(self.position)
						immediateMesh.mesh.surface_add_vertex(dist)
						immediateMesh.mesh.surface_end()
			else:
				pawnHasTarget = false
				overlappingObject = null
				overlappingObjectPosition = Vector3.ZERO
				immediateMesh.hide()
