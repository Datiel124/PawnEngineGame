@tool
extends Node
class_name duplicatorComponent


##Duplicates its parent and sets parameters

##Instead of duplicating parent node, instantiate a packedscene.
@export_subgroup("Parent of Duplicate")
##What node becomes the parent of the duplicate (Leave blank for parent of parent)
@export var parent : Node
##Choose a specific path to become parent- useful for absolute paths. Overrides parent.
@export var parent_nodepath : String = ""
##Choose a node specified under in a Singleton ( {"/root/Singleton/":"parameter"} ). Overrides parent_nodepath and parent.
@export var parent_singleton : Dictionary = {}
@export_subgroup("Duplication parameters")
## Place it in the worldMisc instead of Specified Parent
@export var useWorldMiscAsParent = false
##Copy global transforms from original to duplicate after creating
@export var copy_global_transforms : bool = true
##Offset the duplicate's position by this amount
@export var position_offset : Vector3 = Vector3.ZERO
##Offset the duplicate's rotation by this amount
@export var rotation_offset : Vector3 = Vector3.ZERO
##Offset the duplicate's scale by this amount
@export var scale_mult : Vector3 = Vector3.ONE
##The parameters to set on the duplicated node ( {"param":value} )
@export var set_params : Dictionary = {}
##Optionally remove after a lifetime (-1 is infinite)
@export var dup_lifetime : float = -1.0:#(sets to -1 if < 0)
	set(value):
		if value <= 0:
			value = -1.0
		dup_lifetime = value
##Lastly, you can use a custom script to handle the nodes behavior.
##You must have a static function called "execute" which takes the duplicated Node as an argument.
@export var advanced_behavior_script : GDScript
@export_subgroup("Pooling")
##Use 'pooling' to optimize.
@export var use_pooling : bool = false
##Set the initial size of the pool, creating this many instances on load.
@export var pool_initial_size : int = 5
##Expands the pool by instancing a new node when a node is requested and all pooled objects are in use.
@export var expand_pool_when_empty : bool = true

var dup_pool : Array[Node]

func _ready() -> void:
	if use_pooling:
		for i in pool_initial_size:
			dup_pool.append(get_parent().duplicate())
	if !expand_pool_when_empty:
		dup_pool.make_read_only()


func duplicate_node() -> void:
	var node_dup = get_parent().duplicate() if !use_pooling else recycle_pooled()
	if node_dup == null:
		#Pool was empty, a new dup can't be created. Return.
		return
	var dup_parent = parent if parent != null else get_parent().get_parent()
	#A parent_nodepath was specified, use that.
	if !parent_nodepath.is_empty():
		dup_parent = get_node(parent_nodepath)
	#A parent_singleton was specified, use that.
	if !parent_singleton.is_empty():
		var singleton = parent_singleton.keys()[0]
		dup_parent = get_node(singleton).get(parent_singleton[singleton])
	#Add the duplicate and set values.
	if !useWorldMiscAsParent:
		dup_parent.add_child(node_dup)
	else:
		globalGameManager.world.worldMisc.add_child(node_dup)
	apply_sets(node_dup)
	#Apply parameters
	if copy_global_transforms:
		node_dup.global_transform = get_parent().global_transform

	if node_dup is Node3D or node_dup is Node2D:
		apply_transform_offset(node_dup)

	if dup_lifetime > 0:
		if use_pooling:
			#using pooling, orphan node when finished
			get_tree().create_timer(dup_lifetime, false).timeout.connect(func():
				if node_dup != null:
					node_dup.get_parent().remove_child(node_dup)
				)
		else:
			#not using pooling, delete node when finished
			get_tree().create_timer(dup_lifetime, false).timeout.connect(node_dup.queue_free)

	if advanced_behavior_script != null:
		advanced_behavior_script.execute(node_dup)


func recycle_pooled() -> Node:
	#Get first node that is ready (outside of tree)
	for node in dup_pool:
		if node.is_inside_tree():
			continue
		return node
	#No available nodes found
	if expand_pool_when_empty:
		var new_dup = get_parent().duplicate()
		dup_pool.append(new_dup)
		return new_dup
	return null


##Apply the specified set_params.
func apply_sets(node : Node) -> void:
	for key in set_params.keys():
		node.set(key, set_params[key])


func apply_transform_offset(node : Node) -> void:
	node.global_position += position_offset
	node.global_rotation += rotation_offset
	node.scale *= scale_mult
