extends Node
## Global Game Manager Start

#Misc
var richPresenceEnabled = false
var activeCamera = null
var debugEnabled = false

#Settings
var userDir = DirAccess.open("user://")
var isFullscreen = false
var gameConfigFile = ConfigFile.new()
var gameSettingsVars = gameConfigFile.load("user://settings/settings.sav")
			
#Ingame
var mouseSens = 0.0020
var defaultFOV = 90

#World
var world

#Multiplayer
var isMultiplayerGame = false

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	if richPresenceEnabled:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isFullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	if isFullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
func _input(event):
	if Input.is_action_just_pressed("aFullscreen"):
		fullscreenToggle()
		
	if Input.is_action_just_pressed("dRestartScene"):
		restartScene()

func load_settings():
	print("Loading Settings!")
	if gameSettingsVars != OK:
		print("Couldn't find any setting save data, creating..")
		save_settings()
	else:
		print("Found settings config! Loading now..")
		for setting in gameConfigFile.get_sections():
			isFullscreen = gameConfigFile.get_value(setting, "fullscreen")

func save_settings():
	if !userDir.dir_exists("user://settings"):
		userDir.make_dir("user://settings")
		save_settings()
	gameConfigFile.set_value("Setting_1", "fullscreen", isFullscreen)
	print("Saved configs!")
	gameConfigFile.save("user://settings/settings.sav")
	
func fullscreenToggle():
	if isFullscreen:
		isFullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		isFullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		
func debugToggle():
	if debugEnabled:
		debugEnabled = false
	else:
		debugEnabled = true

func screenshot() -> String:
	print("Initializing screenshot!")
	var screenshot_count = 0
	var screenshot = get_viewport().get_texture().get_image()

	var savedfilepath
	if userDir.dir_exists("user://screenshots"):
		var screenshot_dir = DirAccess.open("user://screenshots/")
		print(screenshot_dir.get_current_dir())
		screenshot_count = screenshot_dir.get_files().size() + 1
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		savedfilepath = "user://screenshots/screenshot_" + str(screenshot_count) + ".png"
		screenshot_count = screenshot_count + 1
	else:
		userDir.make_dir("screenshots")
		var screenshot_dir = DirAccess.open("user://screenshots/")
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		savedfilepath = "user://screenshots/screenshot_" + str(screenshot_count) + ".png"
		screenshot_count = screenshot_count + 1
	print("Saved screenshot!")
	return savedfilepath

func restartScene():
	await Fade.fade_out(0.3, Color(0,0,0,1),"GradientVertical",false,true).finished
	get_tree().reload_current_scene()
