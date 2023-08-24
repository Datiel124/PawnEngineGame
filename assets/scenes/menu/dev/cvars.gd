extends Node


var world:
	get:
		return globalGameManager.world
var hit:
	get:
		if globalGameManager.activeCamera.camCast.is_colliding:
			return globalGameManager.activeCamera.camCast.get_collider()
		return null


static func echo(message) -> void:
	Console.add_console_message(str(message))


static func spawnPawn() -> void:
	var pawn = load("res://assets/entities/pawnEntity/pawnEntity.tscn").instantiate()
	globalGameManager.world.worldPawns.add_child(pawn)
	var cast : RayCast3D = globalGameManager.activeCamera.camCast
	if cast.is_colliding():
		pawn.global_position = cast.get_collision_point()
		pawn.global_position.y = pawn.global_position.y * 3


static func setTimescale(value : float) -> void:
	Engine.time_scale = clamp(value, 0.1, 20.0)
