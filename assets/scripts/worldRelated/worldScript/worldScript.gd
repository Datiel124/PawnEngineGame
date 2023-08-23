extends Node
class_name WorldScene
signal worldLoaded

@onready var worldSpawns = $Spawns
@onready var playerWorldSpawns = $Spawns/playerSpawns
@onready var pawnWorldSpawns = $Spawns/pawnSpawns
@onready var worldEnvironment = $Environment
@onready var worldGeometry = $Geometry
@onready var worldPawns = $Pawns
@onready var worldProps = $Props
@onready var worldMisc = $Misc
@onready var worldParticles = $Misc/Particles
@onready var worldWaypoints = $Misc/WaypointNodes
@onready var playerPawns = $Pawns/Players
##Set the name for this specific scene
@export_category("World Identity")
##What is this worlds name?
@export var worldName = ""
##Describe the world..
@export var worldDescription = ""
## What type of world is this scene? If its a general area the player can explore to find things like items or quests, it'd be an area. If its a zone where the player can save the game or restock on items it'd be a safehouse. If its a sector full of enemies, arena.
@export_enum("Area", "Shop", "Safehouse", "Arena") var worldType = 0

@export_category("Debug Parameters")
## Spawn Type to use when loading the scene
@export_enum("Player","Camera","None") var spawnType = 0 
##Spawn AI pawns at their respective positions when loading the world.
@export var spawnPawnsOnLoad : bool = true
func _enter_tree():
	globalGameManager.world = self

func _ready():
	emit_signal("worldLoaded")
	##Spawn a player at a point.
	if !globalGameManager.isMultiplayerGame:
		pass
		#globalGameManager.add_player(getPlayerSpawnPoints(Vector3.ZERO,true).global_position)
	else:
		spawnPawnsOnLoad = false
		
		
	##Spawn pawns at their respective points.
	if spawnPawnsOnLoad == true:
		pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getSpawnPoints(offset:Vector3 = Vector3(0,0,0), pickRandom:bool = true, spawn_idx:int = 0):
	pass
	
	
#
#func getPlayerSpawnPoints(offset:Vector3 = Vector3(0,0,0), pickRandom:bool = true, spawn_idx:int = 0):
#	if pickRandom:
#		var spawnZone = playerWorldSpawns.get_children().pick_random()
#		if spawnZone is SpawnPoint:
#			if spawnZone.spawnType == 1:
#				return spawnZone
#	else:
#		pass
		
		
##Comment out for now, not yet implemented

#func spawnPawns():
#	var pawnSpawns = pawnWorldSpawns.get_children()
#	for spawns in pawnSpawns:
#		if spawns is SpawnPoint:
#			if spawns.spawnType == 0:
#				var tospawn = load("res://assets/entities/pawn/character_pawn.tscn")
#				var pawn = tospawn.duplicate().instantiate()
#				pawn.position = spawns.global_position
#				if spawns.pawnAIType == 0:
#					#pawn.rotation.y = randf_range(0,360)
#					worldPawns.add_child(pawn, true)
#
#				if spawns.pawnAIType == 1:
#					#pawn.rotation.y = randf_range(0,360)
#					worldPawns.add_child(pawn, true)
#
#				if spawns.pawnAIType == 2:
#					var aiController = load("res://assets/resources/controllers/ai/baseAIController.tscn")
#					var controller = aiController.duplicate().instantiate()
#					#awn.rotation.y = randf_range(0,360)
#					worldPawns.add_child(pawn, true)
#					pawn.setMasterController(controller)
#					pawn.character_pawn.add_child(controller)
#					controller.set_owner(pawn)
#
#				if spawns.spawnWithWeapon:
#					pawn.character_pawn.summon_item(Weapondb.SpawnableWeapons[spawns.spawnWeapon])
#					pawn.character_pawn.current_equipped_index = 1
#
#				if spawns.randomizePawnColor:
#					pawn.character_pawn.randomizePawnColor()
#	return	
