extends Node3D
class_name AIComponent
@export_category("AI Component")
@export var pawnOwner : BasePawn
@export_subgroup("Identification")
@export var pawnName : String
@export_subgroup("State Machine")
@export var stateMachine : StateMachine
@export_subgroup("Nodes")
@export var moveTo : Marker3D
@export var navAgent : NavigationAgent3D
@export var navPointGrabber : Area3D

func _ready():
	pass
