extends Control
var fadeSpeed = 8
@onready var soundPlayer = $audioStreamPlayer
@onready var secondSound = $audioStreamPlayer2
@onready var gradientBG = $gradientBG

func _ready() -> void:
	gradientBG.self_modulate = Color.TRANSPARENT
	modulate = Color.TRANSPARENT
	hide()

func _process(delta):
	if get_tree().paused:
		modulate = lerp(modulate,Color.WHITE,fadeSpeed*delta)
		gradientBG.self_modulate = lerp(gradientBG.self_modulate,Color.WHITE,fadeSpeed*delta)
	else:
		modulate = Color.TRANSPARENT
		gradientBG.self_modulate = lerp(gradientBG.self_modulate,Color.TRANSPARENT,fadeSpeed*delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("gEscape"):
		if Dialogic.current_timeline == null:
			if visible:
				unpauseGame()
			else:
				pauseGame()
		else:
			Dialogic.end_timeline()

func _on_resume_button_pressed():
	unpauseGame()


func _on_menu_button_pressed():
	MusicManager.change_song_to(null,0.5)
	await Fade.fade_out(0.3, Color(0,0,0,1),"GradientVertical",false,true).finished
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://assets/scenes/menu/menu.tscn")

func unpauseGame():
	MusicManager.resumeMusic()
	soundPlayer.play()
	globalGameManager.set_meta(&"stored_mouse_mode", Input.mouse_mode)
	globalGameManager.hideMouse()
	hide()
	get_tree().paused = false

func pauseGame():
	MusicManager.pauseMusic()
	Dialogic.end_timeline()
	secondSound.play()
	Input.mouse_mode = globalGameManager.get_meta(&"stored_mouse_mode", Input.MOUSE_MODE_CAPTURED)
	globalGameManager.showMouse()
	show()
	get_tree().paused = true
