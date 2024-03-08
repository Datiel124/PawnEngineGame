extends RigidBody3D
class_name InteractiveObject
signal objectUsed(user)
@onready var useSound = $useSound
@onready var useSound3D = $useSound3D
@export_category("Interactive Object")
@export var objectName : String
var beenUsed = false
@export_subgroup("Object")
@export_enum("Equippable","Interactive") var interactType = 0
@export var canBePickedUp : bool = true
@export var canBeUsed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

