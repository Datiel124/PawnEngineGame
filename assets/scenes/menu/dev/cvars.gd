extends Node


static func echo(message) -> void:
	Console.add_console_message(str(message))


static func spawnPawn() -> void:
	var pawn = load("res://assets/entities/pawnEntity/pawnEntity.tscn").instantiate()
	globalGameManager.world.worldPawns.add_child(
		pawn
	)
	var cast : RayCast3D = globalGameManager.activeCamera.camCast
	if cast.is_colliding():
		pawn.global_position = cast.get_collision_point()


static func setTimescale(value : float) -> void:
	Engine.time_scale = clamp(value, 0.1, 20.0)
