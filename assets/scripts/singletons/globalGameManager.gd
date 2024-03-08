extends Node
## Global Game Manager Start
var menuScenes = [preload("res://assets/scenes/menu/menuScenes/menuscene1.tscn"),preload("res://assets/scenes/menu/menuScenes/menuScene2.tscn")]

#Global Sound Player
var soundPlayer = AudioStreamPlayer.new()
var sounds : Dictionary = {"healSound" = preload("res://assets/sounds/ui/rareItemFound.wav"),
			"alertSound" = preload("res://assets/sounds/ui/uialert.wav")
			}

#Misc
var richPresenceEnabled = false
var activeCamera = null
var debugEnabled = false
var pawnDebug : bool = false

#Notification Hud


#Settings
var userDir = DirAccess.open("user://")

#Ingame
var mouseSens = 0.0020
var defaultFOV = 90

#World
var dialogueCamLerpSpeed = 5.0
var world : WorldScene

#Multiplayer
var isMultiplayerGame = false

const dialogue_cam : PackedScene = preload("res://assets/entities/camera/DialogueCamera.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	soundPlayer.bus = "Sounds"
	if richPresenceEnabled:
		pass


func create_dialogue_camera() -> Node3D:
	var new_cam = dialogue_cam.instantiate()
	return new_cam


func _input(_event):
	if Input.is_action_just_pressed("aFullscreen"):
		pass

	if Input.is_action_just_pressed("dReloadGame"):
		restartGame()

	if Input.is_action_just_pressed("dRestartScene"):
		if get_tree().paused == false:
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

func restartGame():
	get_tree().unload_current_scene()
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://assets/scenes/menu/logo.tscn")


func strip_bbcode(bbcode_text : String) -> String:
	var regex := RegEx.new()
	regex.compile("\\[(.+?)\\]")
	return regex.sub(bbcode_text, "", true)

enum NOTIF_POSITION{topleft, topcenter, topright, bottomleft, bottomcenter, bottomright}
func notifyFade(text : String, position : NOTIF_POSITION = 2, fade_time : float = 3.0):
	var new_notif
	var container = Notifications.hudPositions[position]

	new_notif = Notifications.notif_fade.instantiate()
	container.add_child(new_notif)
	set_notif_flags(new_notif, position)

	new_notif.set_text(text)
	if fade_time > 0:
		new_notif.timer.start(fade_time)
	return new_notif

func notifyCheck(text : String, position : NOTIF_POSITION = 2, fade_time : float = -1, texture : Texture = Notifications.checkmarkTexture):
	var new_notif
	var container = Notifications.hudPositions[position]

	new_notif = Notifications.notifCheck.instantiate()
	container.add_child(new_notif)
	set_notif_flags(new_notif, position)

	new_notif.set_text(text)
	new_notif.set_warn_params.call(texture, fade_time)
	if fade_time > 0:
		new_notif.timer.start(fade_time)
	return new_notif

func notify_warn(text : String, position : NOTIF_POSITION = 2, fade_time : float = -1, texture : Texture = Notifications.warning_texture):
	var new_notif
	var container = Notifications.hudPositions[position]

	new_notif = Notifications.notif_warn.instantiate()
	container.add_child(new_notif)
	set_notif_flags(new_notif, position)

	new_notif.set_text(text)
	new_notif.set_warn_params.call(texture, fade_time)
	if fade_time > 0:
		new_notif.timer.start(fade_time)
	return new_notif


func notify_click(text : String, call_on_click : Callable, position : NOTIF_POSITION = 2, fade_time : float = -1, binds : Array = []):
	var new_notif : Control
	var container = Notifications.hudPositions[position]

	new_notif = Notifications.notif_click.instantiate()
	container.add_child(new_notif)
	set_notif_flags(new_notif, position)

	new_notif.set_text(text)
	new_notif.set_click_params.call(call_on_click, binds, fade_time)
	if fade_time > 0:
		new_notif.timer.start(fade_time)
	return new_notif


func set_notif_flags(new_notif, position) -> void:
	match position % 3:
		0:
			new_notif.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		1:
			new_notif.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		2:
			new_notif.size_flags_horizontal = Control.SIZE_SHRINK_END


func notify_custom(node : Control, position : NOTIF_POSITION) -> Control:
	var container = Notifications.hudPositions[position]
	container.add_child(node)
	set_notif_flags(node, position)
	return node

func castRay(cam : Camera3D, range : float = 50000, mask := 0b10111, exceptions : Array[RID] = [], hit_areas : bool = false) -> Dictionary:
	var state = cam.get_world_3d().direct_space_state
	var transform = cam.global_transform
	var params := PhysicsRayQueryParameters3D.create(transform.origin, transform.origin - (transform.basis.z * range), 23, exceptions)
	params.collide_with_areas = hit_areas
	return state.intersect_ray(params)


func getEventSignal(event : StringName) -> Signal:
	event = &"__gameEventSignals__" + str(event)
	if !has_user_signal(event):
		add_user_signal(event)
	return Signal(self, event)

func showMouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hideMouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func playSound(stream):
	soundPlayer.stream = stream
	soundPlayer.play()

func getGlobalSound(soundname: String):
	if sounds.get(soundname) != null:
		return sounds.get(soundname)
