extends Control
var fadeSpeed = 4
@onready var soundPlayer = $audioStreamPlayer
@onready var secondSound = $audioStreamPlayer2
@onready var gradientBG = $gradientBG

func _ready() -> void:
	gradientBG.self_modulate = Color.TRANSPARENT
	self_modulate = Color.TRANSPARENT
	hide()

func _process(delta):
	if get_tree().paused:
		self_modulate = lerp(self_modulate,Color.WHITE,fadeSpeed*delta)
		gradientBG.self_modulate = lerp(gradientBG.self_modulate,Color.WHITE,fadeSpeed*delta)
	else:
		self_modulate = Color.TRANSPARENT
		gradientBG.self_modulate = lerp(gradientBG.self_modulate,Color.TRANSPARENT,fadeSpeed*delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("gEscape"):
		if visible:
			Dialogic.end_timeline()
			soundPlayer.play()
			globalGameManager.set_meta(&"stored_mouse_mode", Input.mouse_mode)
			globalGameManager.hideMouse()
			hide()
			get_tree().paused = false
		else:
			Dialogic.end_timeline()
			secondSound.play()
			Input.mouse_mode = globalGameManager.get_meta(&"stored_mouse_mode", Input.MOUSE_MODE_CAPTURED)
			globalGameManager.showMouse()
			show()
			get_tree().paused = true


func _on_resume_button_pressed():
	get_tree().paused = false
	hide()
	globalGameManager.hideMouse()


func _on_menu_button_pressed():
	await Fade.fade_out(0.3, Color(0,0,0,1),"GradientVertical",false,true).finished
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://assets/scenes/menu/menu.tscn")
