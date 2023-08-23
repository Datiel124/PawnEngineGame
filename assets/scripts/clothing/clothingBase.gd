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
@export_category("Skeleton")
@export var itemSkeleton : NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	remapSkeleton()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func remapSkeleton():
	clothingMesh.skeleton = itemSkeleton
