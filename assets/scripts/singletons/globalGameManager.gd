extends Node
## Global Game Manager Start

#Misc
var richPresenceEnabled = false
var activeCamera = null
var debugEnabled = false

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



func debugToggle():
	if debugEnabled:
		debugEnabled = false
	else:
		debugEnabled = true

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


