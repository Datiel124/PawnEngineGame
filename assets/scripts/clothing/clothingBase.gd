extends Node3D
class_name ClothingItem

@onready var clothingMesh : MeshInstance3D = $clothingMesh

@export_category("Clothing Item")
@export_subgroup("Item")
@export var itemName = ""
@export var equippedPawn : BasePawn
@export_subgroup("Hidden Parts")
@export var head = false
@export var shoulders = false
@export var leftUpperarm = false
@export var rightUpperarm = false
@export var rightForearm = false
@export var leftForearm = false
@export var upperChest = false
@export var lowerBody = false
@export var leftUpperLeg = false
@export var rightUpperLeg = false
@export var leftLowerLeg = false
@export var rightLowerLeg = false
@export_category("Skeleton")
@export var itemSkeleton : NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	remapSkeleton()

func remapSkeleton():
	clothingMesh.skeleton = itemSkeleton
