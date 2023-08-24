extends Node


const HELP_DICT := {
	"world":"The current World, which is the root of the level.",
	"hit":"The collider the camera ray is colliding with, is null if none is found.",
	"hitPos":"The point the camera ray is colliding, is null if none is found.",
	"userDir":"Opens the user:// directory.",
	"echo(var)":"Displays the variable input on the console.",
	"load(path)":"Loads the resource at the given filepath.",
	"spawnPawn(position)":"Spawns a pawn at the given position. If none is given, defaults to hitPos.",
	"spawnNode(node, parent)":"Adds the node as a child of parent. If no parent is given, it defaults to world.",
	"setTimescale(value)":"Sets the timescale or speed of the engine. 0.5 is half speed, 2.0 is double speed. Capped to 10.",
	"clear()":"Clears the console output."
}


var userDir:
	get:
		OS.shell_open(ProjectSettings.globalize_path("user://"))
var help:
	get:
		Console.add_console_message("-- Help Menu --", Color.DIM_GRAY)
		Console.add_console_message("-- Available vars --", Color.LIGHT_CORAL)
		for key in HELP_DICT:
			if (key as String).contains("("):
				continue
			Console.add_rich_console_message("[color=light_coral]%s[/color]: %s" % [key, HELP_DICT[key]])
		Console.add_console_message("-- Available methods --", Color.LIGHT_SKY_BLUE)
		for key in HELP_DICT:
			if !(key as String).contains("("):
				continue
			Console.add_rich_console_message("[color=light_sky_blue]%s[/color]: %s" % [key, HELP_DICT[key]])
		Console.add_console_message("For detailed help on a specific method, type _help(\"method\")", Color.DIM_GRAY)
var world:
	get:
		return globalGameManager.world
var hit:
	get:
		if globalGameManager.activeCamera.camCast.is_colliding:
			return globalGameManager.activeCamera.camCast.get_collider()
		return null
var hitPos:
	get:
		if globalGameManager.activeCamera.camCast.is_colliding:
			return globalGameManager.activeCamera.camCast.get_collision_point()
		return null


func echo(variable):
	Console.add_console_message(str(variable))
	return variable


func load(path : String):
	var res = load(path)
	if res == null:
		Console.add_console_message("Failed to load %s" % path, Color.RED)
		return res
	Console.add_console_message("Loaded %s" % path, Color.GREEN)
	return res


func spawnPawn(position : Vector3 = Vector3.INF) -> void:
	var pawn : BasePawn = load("res://assets/entities/pawnEntity/pawnEntity.tscn").instantiate()
	globalGameManager.world.worldPawns.add_child(pawn)
	var cast : RayCast3D = globalGameManager.activeCamera.camCast
	if cast.is_colliding() and !position.is_finite():
		pawn.global_position = cast.get_collision_point()
		pawn.global_position.y = pawn.global_position.y * 3
	if position.is_finite():
		pawn.global_position = position
	Console.add_console_message("spawned %s at %s" % [pawn, pawn.global_position])


func spawnNode(node : Node, parent : Node = null) -> Node:
	if parent == null:
		parent = world
	parent.add_child(node)
	return node


func setTimescale(value : float = 1.0) -> void:
	Engine.time_scale = clamp(value, 0.0, 10.0)


func clear() -> void:
	Console.clear()


func _help(method : String = "") -> void:
	match method:
		"spawnNode":
			Console.add_rich_console_message("[color=light_coral]func [/color][color=light_sky_blue]spawnNode[/color](node : [color=medium_spring_green]Node[/color], parent : [color=medium_spring_green]Node[/color]) -> [color=medium_spring_green]Node[/color]:")
			Console.add_console_message("Calls 'add_child' on the 'parent' node, passing in the 'node'.\nIf no 'parent' node is provided, it defaults to 'world'.\nReturns the provided 'node'.", Color.GRAY)
			return
		"":
			Console.add_console_message("Please provide a method. Example : help(\"spawnNode\")", Color.RED)
			return
	#Detailed help wasn't provided for this.
	Console.add_console_message("Detailed help for this method not found, or the method doesn't exist.", Color.RED)
