extends Control


func _ready() -> void:
	hide()


func _on_main_menubtn_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/menu/menuUI.tscn")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("gEscape"):
		if visible:
			globalGameManager.set_meta(&"stored_mouse_mode", Input.mouse_mode)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			hide()
			get_tree().paused = false
		else:
			Input.mouse_mode = globalGameManager.get_meta(&"stored_mouse_mode", Input.MOUSE_MODE_CAPTURED)
			show()
			get_tree().paused = true
