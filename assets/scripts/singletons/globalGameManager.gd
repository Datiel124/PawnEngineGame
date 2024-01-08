extends Node
## Global Game Manager Start

#Misc
var richPresenceEnabled = false
var activeCamera = null
var debugEnabled = false
var visionConesEnabled : bool = false

#Settings
var userDir = DirAccess.open("user://")

#Ingame
var mouseSens = 0.0020
var defaultFOV = 90

#World
var world : WorldScene

#Multiplayer
var isMultiplayerGame = false

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if richPresenceEnabled:
		pass


func _input(_event):
	if Input.is_action_just_pressed("aFullscreen"):
		pass

	if Input.is_action_just_pressed("dRestartScene"):
		restartScene()

	if debugEnabled:
		if Input.is_action_pressed("dFreecam"):
			globalGameManager.activeCamera.unposessObject(true)

		if Input.is_action_pressed("dPosess"):
			var cast : RayCast3D = globalGameManager.activeCamera.debugCast
			if cast:
				if cast.is_colliding():
					if cast.get_collider().is_in_group("Posessable"):
						globalGameManager.activeCamera.unposessObject(true)
						globalGameManager.activeCamera.posessObject(cast.get_collider(),cast.get_collider().followNode)
					else:
						Console.add_console_message("Cannot posess %s, Its not possessable" %cast.get_collider())
			else:
				Console.add_console_message("You can't posess nothing dipshit. Look at a pawn.")



func takeScreenshot() -> String:
	print("Initializing screenshot!")
	var screenshot_count = 0
	var screenshot = get_viewport().get_texture().get_image()

	var savedfilepath
	if userDir.dir_exists("user://screenshots"):
		var _screenshot_dir = DirAccess.open("user://screenshots/")
		print(_screenshot_dir.get_current_dir())
		screenshot_count = _screenshot_dir.get_files().size() + 1
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		savedfilepath = "user://screenshots/screenshot_" + str(screenshot_count) + ".png"
		screenshot_count = screenshot_count + 1
	else:
		userDir.make_dir("screenshots")
		var _screenshot_dir = DirAccess.open("user://screenshots/")
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		savedfilepath = "user://screenshots/screenshot_" + str(screenshot_count) + ".png"
		screenshot_count = screenshot_count + 1
	print("Saved screenshot!")
	return savedfilepath

func restartScene():
	await Fade.fade_out(0.3, Color(0,0,0,1),"GradientVertical",false,true).finished
	get_tree().reload_current_scene()


func strip_bbcode(bbcode_text : String) -> String:
	var regex := RegEx.new()
	regex.compile("\\[(.+?)\\]")
	return regex.sub(bbcode_text, "", true)

