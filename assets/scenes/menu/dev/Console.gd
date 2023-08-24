extends Node


var usercommand_list : Array[String]
var command_copy_idx = -1
@onready var input_field = $window/control/panel/lineEdit
@onready var scroll : ScrollContainer = $window/control/panel/panel/scrollContainer
@onready var msgbox : VBoxContainer = $window/control/panel/panel/scrollContainer/ConsoleMessageContainer
@onready var console : Window = $window
@onready var cvars : Node = $cvars
var expression = Expression.new()


func _ready():
	console.hide()


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text != "":
		usercommand_list.push_front(new_text)
	if usercommand_list.size() > 100:
		usercommand_list.pop_back()
	input_field.text = ""
	command_copy_idx = -1
	expression.parse(new_text)
	expression.execute([], cvars, false)
	if expression.get_error_text() != "":
		add_console_message(expression.get_error_text(), Color.YELLOW)


func add_console_message(message : String, color : Color = Color.WHITE) -> void:
	var new_label = Label.new()
	new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	new_label.text = message
	new_label.modulate = color
	msgbox.add_child(new_label)
	if msgbox.get_child_count() > 300:
		msgbox.get_child(0).queue_free()
	await get_tree().process_frame
	scroll.scroll_vertical = 50000


func add_rich_console_message(message : String) -> void:
	var new_label = RichTextLabel.new()
	new_label.fit_content = true
	new_label.bbcode_enabled = true
	new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	new_label.text = message
	msgbox.add_child(new_label)
	if msgbox.get_child_count() > 300:
		msgbox.get_child(0).queue_free()
	await get_tree().process_frame
	scroll.scroll_vertical = 50000


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("devConsole"):
		console.hide()
		await get_tree().process_frame
		console.show()
		console.grab_focus()
		input_field.grab_focus()


func _on_window_window_input(event: InputEvent) -> void:
	if event.is_action_pressed("devConsole"):
		console.hide()
	if input_field.has_focus() and event.is_pressed():
		if event.as_text() == "Up" and usercommand_list.size() > 0:
			command_copy_idx += 1
			command_copy_idx = clamp(command_copy_idx, 0, usercommand_list.size() - 1)
			input_field.text = usercommand_list[command_copy_idx]
			await get_tree().process_frame
			input_field.caret_column = input_field.text.length()
			return
		if event.as_text() == "Down" and usercommand_list.size() > 0:
			command_copy_idx -= 1
			command_copy_idx = clamp(command_copy_idx, 0, usercommand_list.size() - 1)
			input_field.text = usercommand_list[command_copy_idx]
			await get_tree().process_frame
			input_field.caret_column = input_field.text.length()
			return


func clear() -> void:
	for i in msgbox.get_children():
		i.queue_free()
	add_console_message("Console cleared.", Color.DIM_GRAY)


func _on_window_focus_entered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
